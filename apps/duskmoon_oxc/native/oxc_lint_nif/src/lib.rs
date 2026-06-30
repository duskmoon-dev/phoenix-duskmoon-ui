use std::path::Path;
use std::sync::Arc;

use oxc_allocator::Allocator;
use oxc_linter::{
    AllowWarnDeny, ConfigStore, ConfigStoreBuilder, ExternalPluginStore, FixKind, LintFilter,
    LintFilterKind, LintOptions, LintPlugins, Linter, ModuleRecord,
};
use oxc_parser::{ParseOptions, Parser};
use oxc_semantic::SemanticBuilder;
use oxc_span::SourceType;
use rustler::{Binary, Encoder, Env, Error, NifMap, NifResult, Term};

mod atoms {
    rustler::atoms! {
        ok,
        error,
        warn,
        deny,
        allow,
    }
}

#[derive(NifMap)]
struct Diagnostic {
    rule: String,
    message: String,
    severity: rustler::Atom,
    span: (u32, u32),
    labels: Vec<(u32, u32)>,
    help: Option<String>,
}

fn parse_plugins(plugin_strs: &[String]) -> LintPlugins {
    let mut plugins = LintPlugins::empty();
    for plugin in plugin_strs {
        match plugin.as_str() {
            "react" => plugins |= LintPlugins::REACT,
            "unicorn" => plugins |= LintPlugins::UNICORN,
            "typescript" => plugins |= LintPlugins::TYPESCRIPT,
            "oxc" => plugins |= LintPlugins::OXC,
            "import" => plugins |= LintPlugins::IMPORT,
            "jsdoc" => plugins |= LintPlugins::JSDOC,
            "jest" => plugins |= LintPlugins::JEST,
            "vitest" => plugins |= LintPlugins::VITEST,
            "jsx_a11y" | "jsx-a11y" => plugins |= LintPlugins::JSX_A11Y,
            "nextjs" | "next" => plugins |= LintPlugins::NEXTJS,
            "react_perf" | "react-perf" => plugins |= LintPlugins::REACT_PERF,
            "promise" => plugins |= LintPlugins::PROMISE,
            "node" => plugins |= LintPlugins::NODE,
            "vue" => plugins |= LintPlugins::VUE,
            _ => {}
        }
    }
    plugins
}

fn severity_atom(_env: Env<'_>, severity: AllowWarnDeny) -> rustler::Atom {
    match severity {
        AllowWarnDeny::Allow => atoms::allow(),
        AllowWarnDeny::Warn => atoms::warn(),
        AllowWarnDeny::Deny => atoms::deny(),
    }
}

fn parse_severity(s: &str) -> AllowWarnDeny {
    match s {
        "deny" | "error" => AllowWarnDeny::Deny,
        "warn" => AllowWarnDeny::Warn,
        "allow" | "off" => AllowWarnDeny::Allow,
        _ => AllowWarnDeny::Warn,
    }
}

struct LintConfig {
    config_store: ConfigStore,
    rule_severity_map: std::collections::HashMap<String, AllowWarnDeny>,
}

fn build_lint_config(plugins: &[String], rules: &[(String, String)]) -> Result<LintConfig, String> {
    let lint_plugins = if plugins.is_empty() {
        LintPlugins::default()
    } else {
        parse_plugins(plugins)
    };

    let mut external_plugin_store = ExternalPluginStore::default();
    let mut builder = ConfigStoreBuilder::default().with_builtin_plugins(lint_plugins);

    for (rule_name, severity_str) in rules {
        let severity = parse_severity(severity_str.as_str());
        let filter_kind = LintFilterKind::parse(std::borrow::Cow::Owned(rule_name.clone()))
            .map_err(|e| format!("Invalid rule filter '{rule_name}': {e}"))?;
        let filter = LintFilter::new(severity, filter_kind)
            .map_err(|e| format!("Invalid lint filter '{rule_name}': {e}"))?;
        builder = builder.with_filters([&filter]);
    }

    let config = builder
        .build(&mut external_plugin_store)
        .map_err(|e| format!("Failed to build linter config: {e}"))?;

    let rule_severity_map = config
        .rules()
        .iter()
        .map(|(rule, severity)| (format_rule_enum_name(rule), *severity))
        .collect();

    Ok(LintConfig {
        config_store: ConfigStore::new(config, Default::default(), external_plugin_store),
        rule_severity_map,
    })
}

fn format_rule_enum_name(rule: &oxc_linter::rules::RuleEnum) -> String {
    let name = rule.name();
    let plugin = rule.plugin_name();
    if plugin == "eslint" {
        format!("eslint({name})")
    } else {
        format!("{plugin}({name})")
    }
}

fn format_rule_name(code: &oxc_diagnostics::OxcCode) -> String {
    let scope = code.scope.as_deref().unwrap_or("");
    let number = code.number.as_deref().unwrap_or("");
    if scope.is_empty() {
        number.to_string()
    } else if number.is_empty() {
        scope.to_string()
    } else {
        format!("{scope}({number})")
    }
}

fn source_from_term<'a>(term: Term<'a>) -> NifResult<Binary<'a>> {
    term.decode_as_binary()
}

fn binary_to_str<'a, 'b>(binary: &'b Binary<'a>) -> NifResult<&'b str> {
    std::str::from_utf8(binary).map_err(|_| Error::BadArg)
}

#[rustler::nif(schedule = "DirtyCpu")]
fn lint<'a>(
    env: Env<'a>,
    source_term: Term<'a>,
    filename: &str,
    plugins: Vec<String>,
    rules: Vec<(String, String)>,
    fix: bool,
) -> NifResult<Term<'a>> {
    let source_binary = source_from_term(source_term)?;
    let source = binary_to_str(&source_binary)?;
    let path = Path::new(filename);
    let source_type = SourceType::from_path(path).unwrap_or_default();

    let allocator = Allocator::default();
    let ret = Parser::new(&allocator, source, source_type)
        .with_options(ParseOptions {
            parse_regular_expression: true,
            ..ParseOptions::default()
        })
        .parse();

    if !ret.errors.is_empty() {
        let error_msgs: Vec<String> = ret.errors.iter().map(|e| e.message.to_string()).collect();
        return Ok((atoms::error(), error_msgs).encode(env));
    }

    let lint_config = match build_lint_config(&plugins, &rules) {
        Ok(v) => v,
        Err(e) => return Ok((atoms::error(), vec![e]).encode(env)),
    };

    let fix_kind = if fix { FixKind::SafeFix } else { FixKind::None };

    let linter = Linter::new(
        LintOptions {
            fix: fix_kind,
            ..LintOptions::default()
        },
        lint_config.config_store,
        None,
    );

    let semantic = SemanticBuilder::new()
        .with_cfg(true)
        .build(&ret.program)
        .semantic;

    let module_record = Arc::new(ModuleRecord::default());
    let ctx_host = oxc_linter::ContextSubHost::new(semantic, module_record, 0, Default::default());
    let messages = linter.run(path, vec![ctx_host], &allocator);

    let diagnostics: Vec<Diagnostic> = messages
        .iter()
        .map(|msg| {
            let full_rule = format_rule_name(&msg.error.code);
            let severity = lint_config
                .rule_severity_map
                .get(&full_rule)
                .copied()
                .unwrap_or(AllowWarnDeny::Warn);

            Diagnostic {
                rule: full_rule,
                message: msg.error.message.to_string(),
                severity: severity_atom(env, severity),
                span: (msg.span.start, msg.span.end),
                labels: msg
                    .error
                    .labels
                    .as_ref()
                    .map(|labels| {
                        labels
                            .iter()
                            .map(|l| (l.offset() as u32, (l.offset() + l.len()) as u32))
                            .collect()
                    })
                    .unwrap_or_default(),
                help: msg.error.help.as_ref().map(|h| h.to_string()),
            }
        })
        .collect();

    Ok((atoms::ok(), diagnostics).encode(env))
}

rustler::init!("Elixir.OXC.Lint.Native");

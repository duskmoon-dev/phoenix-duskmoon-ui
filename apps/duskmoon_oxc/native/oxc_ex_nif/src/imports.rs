use oxc_allocator::Allocator;
use oxc_ast::ast::{
    Argument, ArrayExpressionElement, Expression, ImportOrExportKind, TemplateLiteral,
};
use oxc_ast_visit::walk;
use oxc_ast_visit::Visit;
use oxc_parser::Parser;
use oxc_span::SourceType;
use rustler::{Atom, Encoder, Env, NifResult, Term};
use rustler_match_spec::{MatchEvent, Selector, ValueRef};

use crate::atoms;
use crate::error::{error_to_term, format_errors};
use crate::parse::{binary_to_str, source_from_term};

struct ImportInfo {
    specifier: String,
    r#type: rustler::Atom,
    kind: rustler::Atom,
    start: u32,
    r#end: u32,
}

struct AssetUrlInfo {
    specifier: String,
    start: u32,
    r#end: u32,
}

struct WorkerInfo {
    specifier: String,
    kind: rustler::Atom,
    start: u32,
    r#end: u32,
}

struct GlobImportInfo {
    patterns: Vec<String>,
    start: u32,
    r#end: u32,
}

struct ImportMetaEnvInfo {
    start: u32,
    r#end: u32,
}

struct DynamicImportTemplateInfo {
    pattern: String,
    start: u32,
    r#end: u32,
    template_start: u32,
    template_end: u32,
}

struct RequireCallInfo {
    specifier: String,
    start: u32,
    r#end: u32,
}

struct ImportCollector {
    imports: Vec<ImportInfo>,
    asset_urls: Vec<AssetUrlInfo>,
    workers: Vec<WorkerInfo>,
    glob_imports: Vec<GlobImportInfo>,
    import_meta_env: Vec<ImportMetaEnvInfo>,
    dynamic_import_templates: Vec<DynamicImportTemplateInfo>,
    require_calls: Vec<RequireCallInfo>,
}

impl<'a> MatchEvent<'a> for &'a AssetUrlInfo {
    fn tag(&self) -> Atom {
        atoms::asset_url()
    }

    fn arity(&self) -> usize {
        4
    }

    fn positional_field(&self, index: usize) -> Option<ValueRef<'a>> {
        match index {
            1 => Some(ValueRef::Str(self.specifier.as_str())),
            2 => Some(ValueRef::U64(self.start.into())),
            3 => Some(ValueRef::U64(self.r#end.into())),
            _ => None,
        }
    }

    fn field(&self, name: Atom) -> Option<ValueRef<'a>> {
        if name == atoms::specifier() {
            Some(ValueRef::Str(self.specifier.as_str()))
        } else if name == atoms::start() {
            Some(ValueRef::U64(self.start.into()))
        } else if name == atoms::r#end() {
            Some(ValueRef::U64(self.r#end.into()))
        } else {
            None
        }
    }
}

impl<'a> MatchEvent<'a> for &'a WorkerInfo {
    fn tag(&self) -> Atom {
        atoms::worker()
    }

    fn arity(&self) -> usize {
        5
    }

    fn positional_field(&self, index: usize) -> Option<ValueRef<'a>> {
        match index {
            1 => Some(ValueRef::Str(self.specifier.as_str())),
            2 => Some(ValueRef::Atom(self.kind)),
            3 => Some(ValueRef::U64(self.start.into())),
            4 => Some(ValueRef::U64(self.r#end.into())),
            _ => None,
        }
    }

    fn field(&self, name: Atom) -> Option<ValueRef<'a>> {
        if name == atoms::specifier() {
            Some(ValueRef::Str(self.specifier.as_str()))
        } else if name == atoms::kind() {
            Some(ValueRef::Atom(self.kind))
        } else if name == atoms::start() {
            Some(ValueRef::U64(self.start.into()))
        } else if name == atoms::r#end() {
            Some(ValueRef::U64(self.r#end.into()))
        } else {
            None
        }
    }
}

impl<'a> MatchEvent<'a> for &'a GlobImportInfo {
    fn tag(&self) -> Atom {
        atoms::glob_import()
    }

    fn arity(&self) -> usize {
        4
    }

    fn positional_field(&self, index: usize) -> Option<ValueRef<'a>> {
        match index {
            1 => Some(ValueRef::StringList(self.patterns.as_slice())),
            2 => Some(ValueRef::U64(self.start.into())),
            3 => Some(ValueRef::U64(self.r#end.into())),
            _ => None,
        }
    }

    fn field(&self, name: Atom) -> Option<ValueRef<'a>> {
        if name == atoms::patterns() {
            Some(ValueRef::StringList(self.patterns.as_slice()))
        } else if name == atoms::start() {
            Some(ValueRef::U64(self.start.into()))
        } else if name == atoms::r#end() {
            Some(ValueRef::U64(self.r#end.into()))
        } else {
            None
        }
    }
}

impl<'a> MatchEvent<'a> for &'a ImportMetaEnvInfo {
    fn tag(&self) -> Atom {
        atoms::import_meta_env()
    }

    fn arity(&self) -> usize {
        3
    }

    fn positional_field(&self, index: usize) -> Option<ValueRef<'a>> {
        match index {
            1 => Some(ValueRef::U64(self.start.into())),
            2 => Some(ValueRef::U64(self.r#end.into())),
            _ => None,
        }
    }

    fn field(&self, name: Atom) -> Option<ValueRef<'a>> {
        if name == atoms::start() {
            Some(ValueRef::U64(self.start.into()))
        } else if name == atoms::r#end() {
            Some(ValueRef::U64(self.r#end.into()))
        } else {
            None
        }
    }
}

impl<'a> MatchEvent<'a> for &'a DynamicImportTemplateInfo {
    fn tag(&self) -> Atom {
        atoms::dynamic_import_template()
    }

    fn arity(&self) -> usize {
        6
    }

    fn positional_field(&self, index: usize) -> Option<ValueRef<'a>> {
        match index {
            1 => Some(ValueRef::Str(self.pattern.as_str())),
            2 => Some(ValueRef::U64(self.start.into())),
            3 => Some(ValueRef::U64(self.r#end.into())),
            4 => Some(ValueRef::U64(self.template_start.into())),
            5 => Some(ValueRef::U64(self.template_end.into())),
            _ => None,
        }
    }

    fn field(&self, name: Atom) -> Option<ValueRef<'a>> {
        if name == atoms::pattern() {
            Some(ValueRef::Str(self.pattern.as_str()))
        } else if name == atoms::start() {
            Some(ValueRef::U64(self.start.into()))
        } else if name == atoms::r#end() {
            Some(ValueRef::U64(self.r#end.into()))
        } else if name == atoms::template_start() {
            Some(ValueRef::U64(self.template_start.into()))
        } else if name == atoms::template_end() {
            Some(ValueRef::U64(self.template_end.into()))
        } else {
            None
        }
    }
}

impl<'a> MatchEvent<'a> for &'a RequireCallInfo {
    fn tag(&self) -> Atom {
        atoms::require_call()
    }

    fn arity(&self) -> usize {
        4
    }

    fn positional_field(&self, index: usize) -> Option<ValueRef<'a>> {
        match index {
            1 => Some(ValueRef::Str(self.specifier.as_str())),
            2 => Some(ValueRef::U64(self.start.into())),
            3 => Some(ValueRef::U64(self.r#end.into())),
            _ => None,
        }
    }

    fn field(&self, name: Atom) -> Option<ValueRef<'a>> {
        if name == atoms::specifier() {
            Some(ValueRef::Str(self.specifier.as_str()))
        } else if name == atoms::start() {
            Some(ValueRef::U64(self.start.into()))
        } else if name == atoms::r#end() {
            Some(ValueRef::U64(self.r#end.into()))
        } else {
            None
        }
    }
}

impl<'a> MatchEvent<'a> for &'a ImportInfo {
    fn tag(&self) -> Atom {
        atoms::import_source()
    }

    fn arity(&self) -> usize {
        6
    }

    fn positional_field(&self, index: usize) -> Option<ValueRef<'a>> {
        match index {
            1 => Some(ValueRef::Str(self.specifier.as_str())),
            2 => Some(ValueRef::Atom(self.r#type)),
            3 => Some(ValueRef::Atom(self.kind)),
            4 => Some(ValueRef::U64(self.start.into())),
            5 => Some(ValueRef::U64(self.r#end.into())),
            _ => None,
        }
    }

    fn field(&self, name: Atom) -> Option<ValueRef<'a>> {
        if name == atoms::specifier() {
            Some(ValueRef::Str(self.specifier.as_str()))
        } else if name == atoms::r#type() {
            Some(ValueRef::Atom(self.r#type))
        } else if name == atoms::kind() {
            Some(ValueRef::Atom(self.kind))
        } else if name == atoms::start() {
            Some(ValueRef::U64(self.start.into()))
        } else if name == atoms::r#end() {
            Some(ValueRef::U64(self.r#end.into()))
        } else {
            None
        }
    }
}

impl<'a> Visit<'a> for ImportCollector {
    fn visit_static_member_expression(&mut self, expr: &oxc_ast::ast::StaticMemberExpression<'a>) {
        if is_import_meta_member(expr, "env") {
            self.import_meta_env.push(ImportMetaEnvInfo {
                start: expr.span.start,
                r#end: expr.span.end,
            });
        }

        walk::walk_static_member_expression(self, expr);
    }

    fn visit_import_declaration(&mut self, decl: &oxc_ast::ast::ImportDeclaration<'a>) {
        if decl.import_kind != ImportOrExportKind::Type {
            self.imports.push(ImportInfo {
                specifier: decl.source.value.to_string(),
                r#type: atoms::atom_static(),
                kind: atoms::import(),
                start: decl.source.span.start,
                r#end: decl.source.span.end,
            });
        }
    }

    fn visit_export_named_declaration(&mut self, decl: &oxc_ast::ast::ExportNamedDeclaration<'a>) {
        if decl.export_kind != ImportOrExportKind::Type {
            if let Some(source) = &decl.source {
                self.imports.push(ImportInfo {
                    specifier: source.value.to_string(),
                    r#type: atoms::atom_static(),
                    kind: atoms::export(),
                    start: source.span.start,
                    r#end: source.span.end,
                });
            }
        }
        walk::walk_export_named_declaration(self, decl);
    }

    fn visit_export_all_declaration(&mut self, decl: &oxc_ast::ast::ExportAllDeclaration<'a>) {
        if decl.export_kind != ImportOrExportKind::Type {
            self.imports.push(ImportInfo {
                specifier: decl.source.value.to_string(),
                r#type: atoms::atom_static(),
                kind: atoms::export_all(),
                start: decl.source.span.start,
                r#end: decl.source.span.end,
            });
        }
    }

    fn visit_call_expression(&mut self, expr: &oxc_ast::ast::CallExpression<'a>) {
        if is_import_meta_glob_call(&expr.callee) {
            if let Some(patterns) = expr.arguments.first().and_then(glob_patterns_from_argument) {
                self.glob_imports.push(GlobImportInfo {
                    patterns,
                    start: expr.span.start,
                    r#end: expr.span.end,
                });
            }
        }

        if is_require_call(&expr.callee) {
            if let Some(Argument::StringLiteral(lit)) = expr.arguments.first() {
                self.require_calls.push(RequireCallInfo {
                    specifier: lit.value.to_string(),
                    start: lit.span.start,
                    r#end: lit.span.end,
                });
            }
        }

        walk::walk_call_expression(self, expr);
    }

    fn visit_new_expression(&mut self, expr: &oxc_ast::ast::NewExpression<'a>) {
        if let Some(lit) = url_literal_from_new_url_expression(expr) {
            self.asset_urls.push(AssetUrlInfo {
                specifier: lit.value.to_string(),
                start: lit.span.start,
                r#end: lit.span.end,
            });
        }

        if let Some(kind) = worker_constructor_kind(&expr.callee) {
            if let Some(Argument::NewExpression(url)) = expr.arguments.first() {
                if let Some(lit) = url_literal_from_new_url_expression(url) {
                    self.workers.push(WorkerInfo {
                        specifier: lit.value.to_string(),
                        kind,
                        start: lit.span.start,
                        r#end: lit.span.end,
                    });
                }
            }
        }

        walk::walk_new_expression(self, expr);
    }

    fn visit_import_expression(&mut self, expr: &oxc_ast::ast::ImportExpression<'a>) {
        match &expr.source {
            Expression::StringLiteral(lit) => {
                self.imports.push(ImportInfo {
                    specifier: lit.value.to_string(),
                    r#type: atoms::dynamic(),
                    kind: atoms::import(),
                    start: lit.span.start,
                    r#end: lit.span.end,
                });
            }
            Expression::TemplateLiteral(template) if expr.options.is_none() => {
                if let Some(pattern) = dynamic_import_pattern(template) {
                    self.dynamic_import_templates
                        .push(DynamicImportTemplateInfo {
                            pattern,
                            start: expr.span.start,
                            r#end: expr.span.end,
                            template_start: template.span.start,
                            template_end: template.span.end,
                        });
                }
            }
            _ => {}
        }
        walk::walk_import_expression(self, expr);
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn select<'a>(
    env: Env<'a>,
    source_term: Term<'a>,
    filename: &str,
    spec: Term<'a>,
) -> NifResult<Term<'a>> {
    let selector = Selector::from_term(spec)?;
    let source_binary = source_from_term(source_term)?;
    let source = binary_to_str(&source_binary)?;
    let allocator = Allocator::default();
    let source_type = SourceType::from_path(filename).unwrap_or_default();
    let ret = Parser::new(&allocator, source, source_type).parse();

    if !ret.errors.is_empty() {
        return error_to_term(env, &format_errors(&ret.errors));
    }

    let mut collector = ImportCollector {
        imports: Vec::new(),
        asset_urls: Vec::new(),
        workers: Vec::new(),
        glob_imports: Vec::new(),
        import_meta_env: Vec::new(),
        dynamic_import_templates: Vec::new(),
        require_calls: Vec::new(),
    };
    collector.visit_program(&ret.program);

    let mut out = Vec::new();

    for import in &collector.imports {
        selector.run_event(env, &import, &mut out)?;
    }

    for asset_url in &collector.asset_urls {
        selector.run_event(env, &asset_url, &mut out)?;
    }

    for worker in &collector.workers {
        selector.run_event(env, &worker, &mut out)?;
    }

    for glob_import in &collector.glob_imports {
        selector.run_event(env, &glob_import, &mut out)?;
    }

    for import_meta_env in &collector.import_meta_env {
        selector.run_event(env, &import_meta_env, &mut out)?;
    }

    for dynamic_import_template in &collector.dynamic_import_templates {
        selector.run_event(env, &dynamic_import_template, &mut out)?;
    }

    for require_call in &collector.require_calls {
        selector.run_event(env, &require_call, &mut out)?;
    }

    Ok((atoms::ok(), out).encode(env))
}

fn dynamic_import_pattern(template: &TemplateLiteral<'_>) -> Option<String> {
    if template.expressions.is_empty() {
        return None;
    }

    let mut pattern = String::new();

    for (index, quasi) in template.quasis.iter().enumerate() {
        match &quasi.value.cooked {
            Some(cooked) => pattern.push_str(cooked.as_str()),
            None => pattern.push_str(quasi.value.raw.as_str()),
        }

        if index + 1 < template.quasis.len() {
            pattern.push('*');
        }
    }

    Some(pattern)
}

fn is_import_meta_glob_call(expr: &Expression<'_>) -> bool {
    matches!(expr, Expression::StaticMemberExpression(member) if is_import_meta_member(member, "glob"))
}

fn is_require_call(expr: &Expression<'_>) -> bool {
    matches!(expr, Expression::Identifier(identifier) if identifier.name == "require")
}

fn glob_patterns_from_argument(argument: &Argument<'_>) -> Option<Vec<String>> {
    match argument {
        Argument::StringLiteral(lit) => Some(vec![lit.value.to_string()]),
        Argument::ArrayExpression(array) => array
            .elements
            .iter()
            .map(|element| match element {
                ArrayExpressionElement::StringLiteral(lit) => Some(lit.value.to_string()),
                _ => None,
            })
            .collect(),
        _ => None,
    }
}

fn url_literal_from_new_url_expression<'a>(
    expr: &'a oxc_ast::ast::NewExpression<'a>,
) -> Option<&'a oxc_ast::ast::StringLiteral<'a>> {
    if !(is_url_constructor(&expr.callee) && expr.arguments.len() >= 2) {
        return None;
    }

    match (expr.arguments.first(), expr.arguments.get(1)) {
        (Some(Argument::StringLiteral(lit)), Some(base)) if is_import_meta_url_argument(base) => {
            Some(lit)
        }
        _ => None,
    }
}

fn worker_constructor_kind(expr: &Expression<'_>) -> Option<Atom> {
    match expr {
        Expression::Identifier(identifier) if identifier.name == "Worker" => Some(atoms::worker()),
        Expression::Identifier(identifier) if identifier.name == "SharedWorker" => {
            Some(atoms::shared_worker())
        }
        _ => None,
    }
}

fn is_url_constructor(expr: &Expression<'_>) -> bool {
    matches!(expr, Expression::Identifier(identifier) if identifier.name == "URL")
}

fn is_import_meta_url_argument(argument: &Argument<'_>) -> bool {
    matches!(argument, Argument::StaticMemberExpression(member) if is_import_meta_url(member))
}

fn is_import_meta_url(member: &oxc_ast::ast::StaticMemberExpression<'_>) -> bool {
    is_import_meta_member(member, "url") || is_generated_import_meta_url(member)
}

fn is_generated_import_meta_url(member: &oxc_ast::ast::StaticMemberExpression<'_>) -> bool {
    member.property.name == "url"
        && matches!(&member.object, Expression::ObjectExpression(object) if object.properties.is_empty())
}

fn is_import_meta_member(
    member: &oxc_ast::ast::StaticMemberExpression<'_>,
    property: &str,
) -> bool {
    member.property.name == property
        && matches!(
            &member.object,
            Expression::MetaProperty(meta) if meta.meta.name == "import" && meta.property.name == "meta"
        )
}

use std::collections::BTreeSet;
use std::fs;
use std::io::Write;
use std::path::{Component, Path, PathBuf};

use rolldown::{
    AddonOutputOption, Bundler, BundlerOptions, BundlerTransformOptions, Either as RolldownEither,
    InputItem, IsExternal, JsxOptions as RolldownJsxOptions, OutputExports, OutputFormat,
    PreserveEntrySignatures, RawCompressOptions, RawMangleOptions, RawMinifyOptions,
    RawMinifyOptionsDetailed, ResolveOptions as RolldownResolveOptions, SourceMapType,
    TreeshakeOptions,
};
use rolldown_common::{
    AssetFilenamesOutputOption, ChunkFilenamesOutputOption, ModuleType, Output, StrOrBytes,
};
use rustc_hash::FxHashMap;
use rustler::{Binary, Encoder, Env, Error, ListIterator, NifMap, NifResult, SerdeTerm, Term};
use serde::Serialize;
use serde_json::Value;
use tempfile::TempDir;
use tokio::runtime::Builder as RuntimeBuilder;

use crate::atoms;
use crate::error::error_to_term;
use crate::options::{BundleEntry, BundleOptions};

#[derive(Serialize)]
struct CodeWithSourcemap {
    code: String,
    sourcemap: String,
}

#[derive(NifMap)]
struct BundleRunResult {
    outputs: Vec<BundleRunOutput>,
    warnings: Vec<String>,
}

#[derive(NifMap)]
struct BundleRunOutput {
    r#type: rustler::Atom,
    name: Option<String>,
    file_name: String,
    path: Option<String>,
    code: Option<String>,
    source: Option<String>,
    sourcemap: Option<String>,
    imports: Vec<String>,
    dynamic_imports: Vec<String>,
    exports: Vec<String>,
}

fn normalize_virtual_path(path: &str) -> Result<PathBuf, String> {
    let normalized = path.replace('\\', "/");
    let mut result = PathBuf::new();

    for component in Path::new(&normalized).components() {
        match component {
            Component::CurDir => {}
            Component::ParentDir => {
                result.pop();
            }
            Component::Normal(part) => result.push(part),
            Component::RootDir | Component::Prefix(_) => {}
        }
    }

    if result.as_os_str().is_empty() {
        return Err(format!("Invalid virtual filename: {path:?}"));
    }

    Ok(result)
}

fn write_iodata(term: Term<'_>, writer: &mut impl Write) -> NifResult<()> {
    if term.is_binary() {
        let binary = Binary::from_term(term)?;
        writer.write_all(&binary).map_err(|_| Error::BadArg)?;
    } else if term.is_empty_list() {
    } else if term.is_list() {
        let iter: ListIterator = term.decode()?;
        for item in iter {
            write_iodata(item, writer)?;
        }
    } else {
        writer
            .write_all(&[term.decode::<u8>()?])
            .map_err(|_| Error::BadArg)?;
    }

    Ok(())
}

fn write_virtual_project<'a>(
    tempdir: &TempDir,
    files: &[(String, Term<'a>)],
) -> Result<Vec<String>, Vec<String>> {
    let mut written = BTreeSet::new();

    for (filename, source) in files {
        let relative_path = match normalize_virtual_path(filename) {
            Ok(path) => path,
            Err(message) => return Err(vec![message]),
        };
        let import_path = relative_path.to_string_lossy().replace('\\', "/");

        if !written.insert(import_path.clone()) {
            return Err(vec![format!(
                "Duplicate module path after normalization: {filename:?}"
            )]);
        }

        let full_path = tempdir.path().join(&relative_path);
        if let Some(parent) = full_path.parent() {
            if let Err(error) = fs::create_dir_all(parent) {
                return Err(vec![format!(
                    "Failed to create directory for {filename:?}: {error}"
                )]);
            }
        }

        let mut file = match fs::File::create(&full_path) {
            Ok(file) => file,
            Err(error) => return Err(vec![format!("Failed to write {filename:?}: {error}")]),
        };

        if write_iodata(*source, &mut file).is_err() {
            return Err(vec![format!("Invalid iodata for {filename:?}")]);
        }
    }

    Ok(written.into_iter().collect())
}

fn build_rolldown_resolve_options(opts: &BundleOptions) -> RolldownResolveOptions {
    RolldownResolveOptions {
        condition_names: (!opts.conditions.is_empty()).then(|| opts.conditions.clone()),
        main_fields: (!opts.main_fields.is_empty()).then(|| opts.main_fields.clone()),
        modules: (!opts.modules.is_empty()).then(|| opts.modules.clone()),
        extensions: Some(vec![
            ".tsx".to_string(),
            ".ts".to_string(),
            ".jsx".to_string(),
            ".js".to_string(),
            ".json".to_string(),
        ]),
        extension_alias: Some(vec![
            (
                ".js".to_string(),
                vec![
                    ".ts".to_string(),
                    ".tsx".to_string(),
                    ".js".to_string(),
                    ".jsx".to_string(),
                ],
            ),
            (
                ".jsx".to_string(),
                vec![
                    ".tsx".to_string(),
                    ".ts".to_string(),
                    ".jsx".to_string(),
                    ".js".to_string(),
                ],
            ),
        ]),
        ..RolldownResolveOptions::default()
    }
}

fn build_rolldown_transform_options(opts: &BundleOptions) -> BundlerTransformOptions {
    let jsx = (opts.jsx_runtime != "automatic"
        || !opts.jsx_factory.is_empty()
        || !opts.jsx_fragment.is_empty()
        || !opts.import_source.is_empty())
    .then(|| {
        RolldownEither::Right(RolldownJsxOptions {
            runtime: Some(opts.jsx_runtime.clone()),
            import_source: (!opts.import_source.is_empty()).then(|| opts.import_source.clone()),
            pragma: (!opts.jsx_factory.is_empty()).then(|| opts.jsx_factory.clone()),
            pragma_frag: (!opts.jsx_fragment.is_empty()).then(|| opts.jsx_fragment.clone()),
            ..RolldownJsxOptions::default()
        })
    });

    BundlerTransformOptions {
        jsx,
        target: (!opts.target.is_empty()).then(|| RolldownEither::Left(opts.target.clone())),
        ..BundlerTransformOptions::default()
    }
}

fn build_minify_options(drop_console: bool) -> RawMinifyOptions {
    if !drop_console {
        return RawMinifyOptions::Bool(true);
    }

    RawMinifyOptions::Object(RawMinifyOptionsDetailed {
        mangle: Some(RawMangleOptions {
            top_level: Some(false),
            keep_names: None,
        }),
        compress: Some(RawCompressOptions {
            drop_console: Some(true),
            ..RawCompressOptions::default()
        }),
        remove_whitespace: true,
    })
}

fn relativize_sourcemap_sources(sourcemap_json: String, cwd: &Path) -> Result<String, Vec<String>> {
    let mut json = serde_json::from_str::<Value>(&sourcemap_json)
        .map_err(|error| vec![format!("Failed to parse Rolldown source map: {error}")])?;

    if let Some(sources) = json.get_mut("sources").and_then(Value::as_array_mut) {
        for source in sources {
            if let Some(path) = source.as_str() {
                let source_path = Path::new(path);
                if let Ok(relative) = source_path.strip_prefix(cwd) {
                    *source = Value::String(relative.to_string_lossy().replace('\\', "/"));
                }
            }
        }
    }

    serde_json::to_string(&json)
        .map_err(|error| vec![format!("Failed to serialize Rolldown source map: {error}")])
}

fn inject_preamble(code: &str, preamble: &str) -> String {
    if let Some(pos) = code.find("(function") {
        if let Some(brace_offset) = code[pos..].find('{') {
            let insert_at = pos + brace_offset + 1;
            let mut result = String::with_capacity(code.len() + preamble.len() + 2);
            result.push_str(&code[..insert_at]);
            result.push('\n');
            result.push_str(preamble);
            result.push_str(&code[insert_at..]);
            return result;
        }
    }
    format!("{preamble}\n{code}")
}

fn build_bundle_options(
    cwd: &Path,
    input: Vec<InputItem>,
    opts: &BundleOptions<'_>,
    external_specifiers: Vec<String>,
    file: Option<String>,
) -> BundlerOptions {
    BundlerOptions {
        input: Some(input),
        cwd: Some(cwd.to_path_buf()),
        external: (!external_specifiers.is_empty()).then(|| IsExternal::from(external_specifiers)),
        dir: opts.outdir.clone(),
        file,
        format: Some(match opts.format.as_str() {
            "esm" => OutputFormat::Esm,
            "cjs" => OutputFormat::Cjs,
            _ => OutputFormat::Iife,
        }),
        exports: parse_output_exports(&opts.exports),
        entry_filenames: opts
            .entry_file_names
            .clone()
            .map(ChunkFilenamesOutputOption::String),
        chunk_filenames: opts
            .chunk_file_names
            .clone()
            .map(ChunkFilenamesOutputOption::String),
        asset_filenames: opts
            .asset_file_names
            .clone()
            .map(AssetFilenamesOutputOption::String),
        preserve_entry_signatures: parse_preserve_entry_signatures(&opts.preserve_entry_signatures),
        sourcemap: opts.sourcemap.then_some(SourceMapType::Hidden),
        banner: opts
            .banner
            .clone()
            .map(|s| AddonOutputOption::String(Some(s))),
        footer: opts
            .footer
            .clone()
            .map(|s| AddonOutputOption::String(Some(s))),
        define: (!opts.define.is_empty()).then(|| {
            opts.define
                .iter()
                .map(|(key, value)| (key.clone(), value.clone()))
                .collect()
        }),
        module_types: parse_module_types(&opts.module_types),
        resolve: Some(build_rolldown_resolve_options(opts)),
        transform: Some(build_rolldown_transform_options(opts)),
        treeshake: TreeshakeOptions::Boolean(opts.treeshake),
        minify: opts.minify.then(|| build_minify_options(opts.drop_console)),
        ..BundlerOptions::default()
    }
}

fn parse_module_types(
    types: &std::collections::BTreeMap<String, String>,
) -> Option<FxHashMap<String, ModuleType>> {
    if types.is_empty() {
        return None;
    }
    let mut map = FxHashMap::default();
    for (ext, loader) in types {
        if let Ok(module_type) = ModuleType::from_known_str(loader) {
            map.insert(ext.clone(), module_type);
        }
    }
    Some(map)
}

fn parse_output_exports(exports: &str) -> Option<OutputExports> {
    match exports {
        "default" => Some(OutputExports::Default),
        "named" => Some(OutputExports::Named),
        "none" => Some(OutputExports::None),
        "auto" => Some(OutputExports::Auto),
        _ => None,
    }
}

fn parse_preserve_entry_signatures(value: &str) -> Option<PreserveEntrySignatures> {
    match value {
        "allow_extension" | "allow-extension" => Some(PreserveEntrySignatures::AllowExtension),
        "strict" => Some(PreserveEntrySignatures::Strict),
        "exports_only" | "exports-only" => Some(PreserveEntrySignatures::ExportsOnly),
        "false" => Some(PreserveEntrySignatures::False),
        _ => None,
    }
}

fn explicit_external_specifiers(opts: &BundleOptions) -> Vec<String> {
    opts.external.clone()
}

fn bundle_virtual_project<'a>(
    files: Vec<(String, Term<'a>)>,
    opts: &BundleOptions,
) -> Result<(String, Option<String>), Vec<String>> {
    if files.is_empty() {
        return Err(vec!["bundle/2 requires at least one file".to_string()]);
    }
    if opts.entry.is_empty() {
        return Err(vec!["bundle/2 requires an :entry option".to_string()]);
    }

    let entry_name = normalize_virtual_path(&opts.entry)
        .map(|path| path.to_string_lossy().replace('\\', "/"))
        .map_err(|message| vec![message])?;
    let tempdir = TempDir::new()
        .map_err(|error| vec![format!("Failed to create temp directory: {error}")])?;
    let cwd = tempdir
        .path()
        .canonicalize()
        .unwrap_or_else(|_| tempdir.path().to_path_buf());
    let written_paths = write_virtual_project(&tempdir, &files)?;
    if !written_paths.iter().any(|path| path == &entry_name) {
        return Err(vec![format!(
            "bundle entry {entry_name:?} was not found in files"
        )]);
    }
    run_rolldown_single(&cwd, entry_name, opts, explicit_external_specifiers(opts))
}

fn bundle_filesystem_entry(
    entry: String,
    opts: &BundleOptions,
) -> Result<(String, Option<String>), Vec<String>> {
    if entry.is_empty() {
        return Err(vec!["bundle/2 requires a non-empty entry path".to_string()]);
    }

    let entry_path = PathBuf::from(&entry);
    let cwd = if opts.cwd.is_empty() {
        entry_path
            .parent()
            .map(Path::to_path_buf)
            .unwrap_or_else(|| PathBuf::from("."))
    } else {
        PathBuf::from(&opts.cwd)
    };

    let cwd = cwd
        .canonicalize()
        .map_err(|error| vec![format!("Failed to resolve bundle cwd: {error}")])?;

    let entry_name = relative_entry_name(&entry_path, &entry, &cwd)?;
    run_rolldown_single(&cwd, entry_name, opts, explicit_external_specifiers(opts))
}

fn relative_entry_name(entry_path: &Path, entry: &str, cwd: &Path) -> Result<String, Vec<String>> {
    if entry_path.is_absolute() {
        Ok(entry_path
            .canonicalize()
            .map_err(|error| vec![format!("Failed to resolve bundle entry: {error}")])?
            .strip_prefix(cwd)
            .map_err(|_| vec![format!("Bundle entry {entry:?} is outside cwd {cwd:?}")])?
            .to_string_lossy()
            .replace('\\', "/"))
    } else {
        Ok(entry_path.to_string_lossy().replace('\\', "/"))
    }
}

fn run_rolldown_single(
    cwd: &Path,
    entry_name: String,
    opts: &BundleOptions<'_>,
    external_specifiers: Vec<String>,
) -> Result<(String, Option<String>), Vec<String>> {
    let input = vec![InputItem {
        name: Some("bundle".to_string()),
        import: entry_name,
    }];
    let options = build_bundle_options(
        cwd,
        input,
        opts,
        external_specifiers,
        Some("bundle.js".to_string()),
    );
    let runtime = RuntimeBuilder::new_current_thread()
        .enable_all()
        .build()
        .map_err(|error| vec![format!("Failed to initialize Tokio runtime: {error}")])?;

    let mut bundler = Bundler::new(options)
        .map_err(|errors| errors.iter().map(ToString::to_string).collect::<Vec<_>>())?;

    let output = runtime
        .block_on(bundler.generate())
        .map_err(|errors| errors.iter().map(ToString::to_string).collect::<Vec<_>>())?;

    let _ = runtime.block_on(bundler.close());

    let chunk = output
        .assets
        .into_iter()
        .find_map(|asset| match asset {
            Output::Chunk(chunk) if chunk.filename == "bundle.js" => Some(chunk),
            _ => None,
        })
        .ok_or_else(|| vec!["Rolldown did not produce a JavaScript bundle".to_string()])?;

    let mut code = chunk.code.clone();

    if let Some(preamble) = &opts.preamble {
        if !preamble.is_empty() {
            code = inject_preamble(&code, preamble);
        }
    }

    let sourcemap = if opts.sourcemap {
        chunk
            .map
            .as_ref()
            .map(oxc_sourcemap::SourceMap::to_json_string)
            .map(|json| relativize_sourcemap_sources(json, cwd))
            .transpose()?
    } else {
        None
    };

    Ok((code, sourcemap))
}

fn bundle_run_project<'a>(opts: &BundleOptions<'a>) -> Result<BundleRunResult, Vec<String>> {
    if opts.entries.is_empty() {
        return Err(vec!["bundle run requires at least one entry".to_string()]);
    }

    let mut source_files: Vec<(String, Term<'a>)> = opts
        .entries
        .iter()
        .filter_map(|entry| entry.source.map(|source| (entry.import.clone(), source)))
        .collect();
    source_files.extend(
        opts.files
            .iter()
            .map(|file| (file.path.clone(), file.source)),
    );

    let tempdir;
    let cwd = if source_files.is_empty() {
        let cwd = if opts.cwd.is_empty() {
            PathBuf::from(".")
        } else {
            PathBuf::from(&opts.cwd)
        };
        cwd.canonicalize()
            .map_err(|error| vec![format!("Failed to resolve bundle cwd: {error}")])?
    } else {
        tempdir = TempDir::new()
            .map_err(|error| vec![format!("Failed to create temp directory: {error}")])?;
        write_virtual_project(&tempdir, &source_files)?;
        tempdir
            .path()
            .canonicalize()
            .unwrap_or_else(|_| tempdir.path().to_path_buf())
    };

    let input = opts
        .entries
        .iter()
        .map(|entry| input_item_for_entry(entry))
        .collect::<Result<Vec<_>, _>>()?;

    run_rolldown_outputs(&cwd, input, opts, explicit_external_specifiers(opts))
}

fn input_item_for_entry(entry: &BundleEntry<'_>) -> Result<InputItem, Vec<String>> {
    if entry.import.is_empty() {
        return Err(vec!["bundle entry import cannot be empty".to_string()]);
    }

    let import = if Path::new(&entry.import).is_absolute() {
        entry.import.replace('\\', "/")
    } else {
        normalize_virtual_path(&entry.import)
            .map(|path| path.to_string_lossy().replace('\\', "/"))
            .map_err(|message| vec![message])?
    };

    Ok(InputItem {
        name: entry.name.clone(),
        import,
    })
}

fn run_rolldown_outputs(
    cwd: &Path,
    input: Vec<InputItem>,
    opts: &BundleOptions<'_>,
    external_specifiers: Vec<String>,
) -> Result<BundleRunResult, Vec<String>> {
    let options = build_bundle_options(cwd, input, opts, external_specifiers, None);
    let runtime = RuntimeBuilder::new_current_thread()
        .enable_all()
        .build()
        .map_err(|error| vec![format!("Failed to initialize Tokio runtime: {error}")])?;

    let mut bundler = Bundler::new(options)
        .map_err(|errors| errors.iter().map(ToString::to_string).collect::<Vec<_>>())?;

    let output = runtime
        .block_on(bundler.generate())
        .map_err(|errors| errors.iter().map(ToString::to_string).collect::<Vec<_>>())?;

    let _ = runtime.block_on(bundler.close());

    let outputs = output
        .assets
        .into_iter()
        .map(|asset| output_to_term_data(cwd, opts, asset))
        .collect::<Result<Vec<_>, _>>()?;

    Ok(BundleRunResult {
        outputs,
        warnings: Vec::new(),
    })
}

fn output_to_term_data(
    cwd: &Path,
    opts: &BundleOptions<'_>,
    output: Output,
) -> Result<BundleRunOutput, Vec<String>> {
    if let Some(outdir) = &opts.outdir {
        let path = Path::new(outdir).join(output.filename());
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)
                .map_err(|error| vec![format!("Failed to create output directory: {error}")])?;
        }
        fs::write(&path, output.content_as_bytes())
            .map_err(|error| vec![format!("Failed to write bundle output: {error}")])?;
    }

    match output {
        Output::Chunk(chunk) => {
            let sourcemap = if opts.sourcemap {
                chunk
                    .map
                    .as_ref()
                    .map(oxc_sourcemap::SourceMap::to_json_string)
                    .map(|json| relativize_sourcemap_sources(json, cwd))
                    .transpose()?
            } else {
                None
            };

            Ok(BundleRunOutput {
                r#type: if chunk.is_entry {
                    atoms::entry()
                } else {
                    atoms::chunk()
                },
                name: Some(chunk.name.to_string()),
                file_name: chunk.filename.to_string(),
                path: output_path(opts, &chunk.filename),
                code: Some(chunk.code.clone()),
                source: None,
                sourcemap,
                imports: chunk.imports.iter().map(ToString::to_string).collect(),
                dynamic_imports: chunk
                    .dynamic_imports
                    .iter()
                    .map(ToString::to_string)
                    .collect(),
                exports: chunk.exports.iter().map(ToString::to_string).collect(),
            })
        }
        Output::Asset(asset) => Ok(BundleRunOutput {
            r#type: atoms::asset(),
            name: asset.names.first().cloned(),
            file_name: asset.filename.to_string(),
            path: output_path(opts, &asset.filename),
            code: None,
            source: Some(match &asset.source {
                StrOrBytes::Str(source) => source.clone(),
                StrOrBytes::Bytes(bytes) => String::from_utf8_lossy(bytes).into_owned(),
            }),
            sourcemap: None,
            imports: Vec::new(),
            dynamic_imports: Vec::new(),
            exports: Vec::new(),
        }),
    }
}

fn output_path(opts: &BundleOptions<'_>, filename: &str) -> Option<String> {
    opts.outdir.as_ref().map(|outdir| {
        Path::new(outdir)
            .join(filename)
            .to_string_lossy()
            .to_string()
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn bundle_run<'a>(env: Env<'a>, opts_term: Term<'a>) -> NifResult<Term<'a>> {
    let opts = BundleOptions::from_term(opts_term);

    match bundle_run_project(&opts) {
        Ok(result) => Ok((atoms::ok(), result).encode(env)),
        Err(errors) => error_to_term(env, &errors),
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn bundle<'a>(
    env: Env<'a>,
    files: Vec<(String, Term<'a>)>,
    opts_term: Term<'a>,
) -> NifResult<Term<'a>> {
    let opts = BundleOptions::from_term(opts_term);

    match bundle_virtual_project(files, &opts) {
        Ok((code, Some(sourcemap))) => Ok((
            atoms::ok(),
            SerdeTerm(CodeWithSourcemap { code, sourcemap }),
        )
            .encode(env)),
        Ok((code, None)) => Ok((atoms::ok(), SerdeTerm(code)).encode(env)),
        Err(errors) => error_to_term(env, &errors),
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn bundle_entry<'a>(env: Env<'a>, entry: String, opts_term: Term<'a>) -> NifResult<Term<'a>> {
    let opts = BundleOptions::from_term(opts_term);

    match bundle_filesystem_entry(entry, &opts) {
        Ok((code, Some(sourcemap))) => Ok((
            atoms::ok(),
            SerdeTerm(CodeWithSourcemap { code, sourcemap }),
        )
            .encode(env)),
        Ok((code, None)) => Ok((atoms::ok(), SerdeTerm(code)).encode(env)),
        Err(errors) => error_to_term(env, &errors),
    }
}

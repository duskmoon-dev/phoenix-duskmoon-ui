use std::collections::BTreeMap;

use rustler::{types::map::MapIterator, ListIterator, Term};

use crate::atoms;

fn get_key<'a>(term: Term<'a>, atom_key: rustler::Atom, _string_key: &str) -> Option<Term<'a>> {
    term.map_get(atom_key).ok()
}

fn get_bool(term: Term<'_>, atom_key: rustler::Atom, string_key: &str) -> Option<bool> {
    get_key(term, atom_key, string_key)?.decode::<bool>().ok()
}

fn get_string(term: Term<'_>, atom_key: rustler::Atom, string_key: &str) -> Option<String> {
    string_from_term(get_key(term, atom_key, string_key)?)
}

fn get_optional_string(
    term: Term<'_>,
    atom_key: rustler::Atom,
    string_key: &str,
) -> Option<Option<String>> {
    let value = get_key(term, atom_key, string_key)?;

    if is_nil(value) {
        Some(None)
    } else {
        string_from_term(value).map(Some)
    }
}

fn get_string_list(
    term: Term<'_>,
    atom_key: rustler::Atom,
    string_key: &str,
) -> Option<Vec<String>> {
    let value = get_key(term, atom_key, string_key)?;
    let iter = value.decode::<ListIterator>().ok()?;

    let mut strings = Vec::new();
    for item in iter {
        strings.push(string_from_term(item)?);
    }
    Some(strings)
}

fn get_term_list<'a>(
    term: Term<'a>,
    atom_key: rustler::Atom,
    string_key: &str,
) -> Option<Vec<Term<'a>>> {
    let value = get_key(term, atom_key, string_key)?;
    let iter = value.decode::<ListIterator>().ok()?;
    Some(iter.collect())
}

fn get_string_map(
    term: Term<'_>,
    atom_key: rustler::Atom,
    string_key: &str,
) -> Option<BTreeMap<String, String>> {
    let value = get_key(term, atom_key, string_key)?;
    let iter = MapIterator::new(value)?;

    let mut map = BTreeMap::new();
    for (key, value) in iter {
        map.insert(string_from_term(key)?, string_from_term(value)?);
    }
    Some(map)
}

fn string_from_term(term: Term<'_>) -> Option<String> {
    term.decode::<String>()
        .ok()
        .or_else(|| term.atom_to_string().ok())
}

fn is_nil(term: Term<'_>) -> bool {
    term.is_atom() && term.atom_to_string().ok().as_deref() == Some("nil")
}

pub fn default_jsx_runtime() -> String {
    "automatic".to_string()
}

pub fn default_format() -> String {
    "iife".to_string()
}

pub struct TransformInput {
    pub jsx_runtime: String,
    pub jsx_factory: String,
    pub jsx_fragment: String,
    pub import_source: String,
    pub target: String,
    pub sourcemap: bool,
}

impl Default for TransformInput {
    fn default() -> Self {
        Self {
            jsx_runtime: default_jsx_runtime(),
            jsx_factory: String::new(),
            jsx_fragment: String::new(),
            import_source: String::new(),
            target: String::new(),
            sourcemap: false,
        }
    }
}

impl TransformInput {
    pub fn from_term(term: Term<'_>) -> Self {
        let mut opts = Self::default();

        if let Some(value) = get_string(term, atoms::jsx(), "jsx") {
            opts.jsx_runtime = value;
        }
        if let Some(value) = get_string(term, atoms::jsx_factory(), "jsx_factory") {
            opts.jsx_factory = value;
        }
        if let Some(value) = get_string(term, atoms::jsx_fragment(), "jsx_fragment") {
            opts.jsx_fragment = value;
        }
        if let Some(value) = get_string(term, atoms::import_source(), "import_source") {
            opts.import_source = value;
        }
        if let Some(value) = get_string(term, atoms::target(), "target") {
            opts.target = value;
        }
        if let Some(value) = get_bool(term, atoms::sourcemap(), "sourcemap") {
            opts.sourcemap = value;
        }

        opts
    }
}

pub struct MinifyInput {
    pub mangle: bool,
}

impl Default for MinifyInput {
    fn default() -> Self {
        Self { mangle: true }
    }
}

impl MinifyInput {
    pub fn from_term(term: Term<'_>) -> Self {
        let mut opts = Self::default();

        if let Some(value) = get_bool(term, atoms::mangle(), "mangle") {
            opts.mangle = value;
        }

        opts
    }
}

pub struct BundleFile<'a> {
    pub path: String,
    pub source: Term<'a>,
}

impl<'a> BundleFile<'a> {
    pub fn from_term(term: Term<'a>) -> Option<Self> {
        Some(Self {
            path: get_string(term, atoms::path(), "path")?,
            source: get_key(term, atoms::source(), "source").filter(|term| !is_nil(*term))?,
        })
    }
}

#[derive(Default)]
pub struct BundleEntry<'a> {
    pub name: Option<String>,
    pub import: String,
    pub source: Option<Term<'a>>,
}

impl<'a> BundleEntry<'a> {
    pub fn from_term(term: Term<'a>) -> Option<Self> {
        let import = get_string(term, atoms::import(), "import")?;
        let name = get_optional_string(term, atoms::name(), "name").flatten();
        let source = get_key(term, atoms::source(), "source").filter(|term| !is_nil(*term));

        Some(Self {
            name,
            import,
            source,
        })
    }
}

#[derive(Default)]
pub struct BundleOptions<'a> {
    pub entries: Vec<BundleEntry<'a>>,
    pub files: Vec<BundleFile<'a>>,
    pub entry: String,
    pub cwd: String,
    pub outdir: Option<String>,
    pub format: String,
    pub exports: String,
    pub minify: bool,
    pub treeshake: bool,
    pub banner: Option<String>,
    pub footer: Option<String>,
    pub preamble: Option<String>,
    pub define: BTreeMap<String, String>,
    pub module_types: BTreeMap<String, String>,
    pub external: Vec<String>,
    pub preserve_entry_signatures: String,
    pub conditions: Vec<String>,
    pub main_fields: Vec<String>,
    pub modules: Vec<String>,
    pub sourcemap: bool,
    pub drop_console: bool,
    pub jsx_runtime: String,
    pub jsx_factory: String,
    pub jsx_fragment: String,
    pub import_source: String,
    pub target: String,
    pub entry_file_names: Option<String>,
    pub chunk_file_names: Option<String>,
    pub asset_file_names: Option<String>,
}

impl<'a> BundleOptions<'a> {
    pub fn from_term(term: Term<'a>) -> Self {
        let mut opts = Self {
            format: default_format(),
            jsx_runtime: default_jsx_runtime(),
            ..Self::default()
        };

        if let Some(value) = get_term_list(term, atoms::entries(), "entries") {
            opts.entries = value
                .into_iter()
                .filter_map(BundleEntry::from_term)
                .collect();
        }
        if let Some(value) = get_term_list(term, atoms::files(), "files") {
            opts.files = value
                .into_iter()
                .filter_map(BundleFile::from_term)
                .collect();
        }
        if let Some(value) = get_string(term, atoms::entry(), "entry") {
            opts.entry = value;
        }
        if let Some(value) = get_string(term, atoms::cwd(), "cwd") {
            opts.cwd = value;
        }
        if let Some(value) = get_optional_string(term, atoms::outdir(), "outdir") {
            opts.outdir = value;
        }
        if let Some(value) = get_string(term, atoms::format(), "format") {
            opts.format = value;
        }
        if let Some(value) = get_string(term, atoms::exports(), "exports") {
            opts.exports = value;
        }
        if let Some(value) = get_bool(term, atoms::minify(), "minify") {
            opts.minify = value;
        }
        if let Some(value) = get_bool(term, atoms::treeshake(), "treeshake") {
            opts.treeshake = value;
        }
        if let Some(value) = get_optional_string(term, atoms::banner(), "banner") {
            opts.banner = value;
        }
        if let Some(value) = get_optional_string(term, atoms::footer(), "footer") {
            opts.footer = value;
        }
        if let Some(value) = get_optional_string(term, atoms::preamble(), "preamble") {
            opts.preamble = value;
        }
        if let Some(value) = get_string_map(term, atoms::define(), "define") {
            opts.define = value;
        }
        if let Some(value) = get_string_map(term, atoms::module_types(), "module_types") {
            opts.module_types = value;
        }
        if let Some(value) = get_string_list(term, atoms::external(), "external") {
            opts.external = value;
        }
        if let Some(value) = get_string(
            term,
            atoms::preserve_entry_signatures(),
            "preserve_entry_signatures",
        ) {
            opts.preserve_entry_signatures = value;
        }
        if let Some(value) = get_string_list(term, atoms::conditions(), "conditions") {
            opts.conditions = value;
        }
        if let Some(value) = get_string_list(term, atoms::main_fields(), "main_fields") {
            opts.main_fields = value;
        }
        if let Some(value) = get_string_list(term, atoms::modules(), "modules") {
            opts.modules = value;
        }
        if let Some(value) = get_bool(term, atoms::sourcemap(), "sourcemap") {
            opts.sourcemap = value;
        }
        if let Some(value) = get_bool(term, atoms::drop_console(), "drop_console") {
            opts.drop_console = value;
        }
        if let Some(value) = get_string(term, atoms::jsx(), "jsx") {
            opts.jsx_runtime = value;
        }
        if let Some(value) = get_string(term, atoms::jsx_factory(), "jsx_factory") {
            opts.jsx_factory = value;
        }
        if let Some(value) = get_string(term, atoms::jsx_fragment(), "jsx_fragment") {
            opts.jsx_fragment = value;
        }
        if let Some(value) = get_string(term, atoms::import_source(), "import_source") {
            opts.import_source = value;
        }
        if let Some(value) = get_string(term, atoms::target(), "target") {
            opts.target = value;
        }
        if let Some(value) =
            get_optional_string(term, atoms::entry_file_names(), "entry_file_names")
        {
            opts.entry_file_names = value;
        }
        if let Some(value) =
            get_optional_string(term, atoms::chunk_file_names(), "chunk_file_names")
        {
            opts.chunk_file_names = value;
        }
        if let Some(value) =
            get_optional_string(term, atoms::asset_file_names(), "asset_file_names")
        {
            opts.asset_file_names = value;
        }

        opts
    }
}

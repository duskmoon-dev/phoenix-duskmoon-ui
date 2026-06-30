use rustler::{Env, NifStruct, ResourceArc, Term};
use std::sync::Mutex;
use tailwindcss_oxide::{ChangedContent, GlobEntry, PublicSourceEntry, Scanner};

struct ScannerResource(Mutex<Scanner>);

#[derive(NifStruct)]
#[module = "Oxide.Source"]
struct ExSourceEntry {
    base: String,
    pattern: String,
    negated: bool,
}

#[derive(NifStruct)]
#[module = "Oxide.Glob"]
struct ExGlobEntry {
    base: String,
    pattern: String,
}

#[derive(NifStruct)]
#[module = "Oxide.Changed"]
struct ExChangedContent {
    file: Option<String>,
    content: Option<String>,
    extension: String,
}

#[derive(NifStruct)]
#[module = "Oxide.Candidate"]
struct ExCandidate {
    value: String,
    position: usize,
}

impl From<ExSourceEntry> for PublicSourceEntry {
    fn from(s: ExSourceEntry) -> Self {
        PublicSourceEntry {
            base: s.base,
            pattern: s.pattern,
            negated: s.negated,
        }
    }
}

impl From<GlobEntry> for ExGlobEntry {
    fn from(g: GlobEntry) -> Self {
        ExGlobEntry {
            base: g.base,
            pattern: g.pattern,
        }
    }
}

impl From<ExChangedContent> for ChangedContent {
    fn from(c: ExChangedContent) -> Self {
        if let Some(file) = c.file {
            return ChangedContent::File(file.into(), c.extension);
        }
        if let Some(content) = c.content {
            return ChangedContent::Content(content, c.extension);
        }
        panic!("ChangedContent must have either file or content");
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn new_scanner(sources: Vec<ExSourceEntry>) -> ResourceArc<ScannerResource> {
    let sources: Vec<PublicSourceEntry> = sources.into_iter().map(Into::into).collect();
    let scanner = Scanner::new(sources);
    ResourceArc::new(ScannerResource(Mutex::new(scanner)))
}

#[rustler::nif(schedule = "DirtyCpu")]
fn scan(resource: ResourceArc<ScannerResource>) -> Vec<String> {
    let mut scanner = resource.0.lock().unwrap();
    scanner.scan()
}

#[rustler::nif(schedule = "DirtyCpu")]
fn scan_files(
    resource: ResourceArc<ScannerResource>,
    changed: Vec<ExChangedContent>,
) -> Vec<String> {
    let mut scanner = resource.0.lock().unwrap();
    let changed: Vec<ChangedContent> = changed.into_iter().map(Into::into).collect();
    scanner.scan_content(changed)
}

#[rustler::nif(schedule = "DirtyCpu")]
fn get_candidates(content: String, extension: String) -> Vec<ExCandidate> {
    let mut scanner = Scanner::new(vec![]);
    let changed = ChangedContent::Content(content.clone(), extension);
    scanner
        .get_candidates_with_positions(changed)
        .into_iter()
        .map(|(value, position)| ExCandidate { value, position })
        .collect()
}

#[rustler::nif(schedule = "DirtyCpu")]
fn get_files(resource: ResourceArc<ScannerResource>) -> Vec<String> {
    let mut scanner = resource.0.lock().unwrap();
    scanner.get_files()
}

#[rustler::nif(schedule = "DirtyCpu")]
fn get_globs(resource: ResourceArc<ScannerResource>) -> Vec<ExGlobEntry> {
    let mut scanner = resource.0.lock().unwrap();
    scanner.get_globs().into_iter().map(Into::into).collect()
}

#[allow(non_local_definitions)]
fn load(env: Env, _: Term) -> bool {
    let _ = rustler::resource!(ScannerResource, env);
    true
}

rustler::init!("Elixir.Oxide.Native", load = load);

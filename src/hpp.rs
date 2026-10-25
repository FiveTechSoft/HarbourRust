// hpp - standalone frontend over the shared preprocessor engine (pp.rs).
// The primary path is INSIDE hbc (hbc preprocesses automatically); this
// binary exists for debugging and pipeline inspection.

#[path = "pp.rs"]
mod pp;

use std::env;
use std::fs;
use std::process;

fn main() {
    let mut args = env::args().skip(1);
    let mut input = None;
    let mut output = None;
    let mut incdirs: Vec<String> = Vec::new();
    while let Some(a) = args.next() {
        match a.as_str() {
            "-o" => output = args.next(),
            "-I" => incdirs.push(args.next().expect("-I needs a directory")),
            _ if a.starts_with("-I") => incdirs.push(a[2..].to_string()),
            _ => input = Some(a),
        }
    }
    let input = match input {
        Some(x) => x,
        None => { eprintln!("usage: hpp <input.prg> [-I <dir>]... [-o <output>]"); process::exit(2); }
    };
    let mut pp = pp::Pp::new(incdirs);
    let mut out = String::new();
    if let Err(m) = pp::process(&input, &mut pp, &mut out, 0) {
        eprintln!("error: {}", m);
        process::exit(1);
    }
    match output {
        Some(f) => { fs::write(&f, out).unwrap_or_else(|e| { eprintln!("error: cannot write {}: {}", f, e); process::exit(1); }); }
        None => print!("{}", out),
    }
}

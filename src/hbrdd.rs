// --harbour-rdd link step (docs/HARBOUR-RDD-2026-11-16.md).
//
// The emitted assembly calls the DBF seam (hrdbf_app_*) and leaves through
// hr_hb_exitprocess; runtime/hrharbour_rdd.c (own MIT, embedded here)
// implements both over Harbour 3.2's VM + RDD. This step needs the tools a
// Harbour user already has: MinGW-w64 gcc (PATH, or HBC_GCC) and a Harbour
// 3.2 mingw64 install (--harbour-dir=<dir> or HB_DIR). Default hbc builds
// never reach this file.
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

const SHIM: &str = include_str!("../runtime/hrharbour_rdd.c");
const HRVALUE_C: &str = include_str!("../runtime/hrvalue.c");
const HRVALUE_H: &str = include_str!("../runtime/hrvalue.h");
const HRDYN_H: &str = include_str!("../runtime/hrdyn.h");
const HRDBF_H: &str = include_str!("../runtime/hrdbf.h");

// Minimal static set, measured by removing each library in turn: the VM,
// RTL, RDD core, the three DBF drivers, HSX/SIX (needed by the drivers),
// the macro compiler (index keys) and GTCGI. winmm: timeGetTime.
const STATIC_LIBS: &[&str] = &["hbvm", "hbrtl", "hbrdd", "rddcdx", "rddntx", "rddfpt", "hbsix", "hbmacro", "hbcommon", "gtcgi"];
const DLL_NAME: &str = "harbour-32-x64.dll";

fn run(cmd: &mut Command, what: &str) -> Result<(), String> {
    let o = cmd.output().map_err(|e| format!("cannot run {}: {}", what, e))?;
    if o.status.success() { return Ok(()); }
    let mut msg = String::from_utf8_lossy(&o.stderr).trim().to_string();
    if msg.is_empty() { msg = String::from_utf8_lossy(&o.stdout).trim().to_string(); }
    Err(format!("{} failed:\n{}", what, msg))
}

pub fn link(asm: &str, out: &str, dir: Option<&str>, dll: bool) -> Result<(), String> {
    let hb = match dir.map(str::to_string).or_else(|| env::var("HB_DIR").ok().filter(|v| !v.is_empty())) {
        Some(d) => PathBuf::from(d),
        None => return Err("no Harbour 3.2 install given: pass --harbour-dir=<dir> or set HB_DIR (the directory holding include/ and lib/win/mingw64/)".into()),
    };
    let inc = hb.join("include");
    let lib = hb.join("lib").join("win").join("mingw64");
    if !inc.join("hbapi.h").is_file() { return Err(format!("{} is not a Harbour install (missing include/hbapi.h)", hb.display())); }
    let need = if dll { "libharbour-32-x64.a" } else { "libhbvm.a" };
    if !lib.join(need).is_file() { return Err(format!("{} lacks lib/win/mingw64/{} (Harbour 3.2 mingw64 build expected)", hb.display(), need)); }
    let gcc = env::var("HBC_GCC").ok().filter(|v| !v.is_empty()).unwrap_or_else(|| "gcc".to_string());
    match Command::new(&gcc).arg("--version").output() {
        Ok(o) if o.status.success() => {}
        _ => return Err(format!("MinGW-w64 gcc not found ({}): put its bin directory on PATH or set HBC_GCC", gcc)),
    }

    let tmp = env::temp_dir().join(format!("hbc-rdd-{}", std::process::id()));
    fs::create_dir_all(&tmp).map_err(|e| format!("cannot create {}: {}", tmp.display(), e))?;
    let res = (|| {
        for (n, t) in [("hrharbour_rdd.c", SHIM), ("hrvalue.c", HRVALUE_C), ("hrvalue.h", HRVALUE_H), ("hrdyn.h", HRDYN_H), ("hrdbf.h", HRDBF_H), ("prog.s", asm)] {
            fs::write(tmp.join(n), t).map_err(|e| format!("cannot write {}: {}", tmp.join(n).display(), e))?;
        }
        let mut c = Command::new(&gcc);
        c.args(["-c", "-O2"]).arg(format!("-I{}", inc.display())).arg(format!("-I{}", tmp.display()));
        if dll { c.arg("-DHR_HB_DLL"); }
        c.arg(tmp.join("hrharbour_rdd.c")).arg("-o").arg(tmp.join("shim.o"));
        run(&mut c, "gcc (Harbour RDD shim)")?;
        run(Command::new(&gcc).arg("-c").arg(tmp.join("prog.s")).arg("-o").arg(tmp.join("prog.o")), "gcc (assembling hbc output)")?;
        let mut l = Command::new(&gcc);
        l.args(["-s", "-mconsole"]).arg("-o").arg(out).arg(tmp.join("prog.o")).arg(tmp.join("shim.o")).arg(format!("-L{}", lib.display()));
        if dll {
            l.arg("-lharbour-32-x64");
        } else {
            l.arg("-Wl,--gc-sections").arg("-Wl,--start-group");
            for x in STATIC_LIBS { l.arg(format!("-l{}", x)); }
            l.args(["-lkernel32", "-lwinmm", "-Wl,--end-group"]);
        }
        run(&mut l, "gcc (link with Harbour)")?;
        if dll {
            // The exe loads the DLL from its own directory first.
            let dst = Path::new(out).parent().filter(|p| !p.as_os_str().is_empty()).unwrap_or(Path::new(".")).join(DLL_NAME);
            if !dst.exists() {
                fs::copy(hb.join("bin").join(DLL_NAME), &dst).map_err(|e| format!("cannot copy {} next to the executable: {}", DLL_NAME, e))?;
            }
        }
        Ok(())
    })();
    let _ = fs::remove_dir_all(&tmp);
    res
}

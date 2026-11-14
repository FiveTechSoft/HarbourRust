// Portable native-manifest runner. Build with stable Rust, no Cargo crates.
// The Mac path is unverified on hardware until the user runs it there.
use std::{env, fs, path::{Path, PathBuf}, process::{Command, Stdio}, thread, time::{Duration, Instant}};

fn run(mut cmd: Command, stem: &Path, seconds: u64) -> Result<(i32, bool), String> {
    let stdout = fs::File::create(stem.with_extension("stdout")).map_err(|e|e.to_string())?;
    let stderr = fs::File::create(stem.with_extension("stderr")).map_err(|e|e.to_string())?;
    let mut child = cmd.stdin(Stdio::null()).stdout(stdout).stderr(stderr).spawn().map_err(|e|e.to_string())?;
    let start = Instant::now();
    loop {
        if let Some(status) = child.try_wait().map_err(|e|e.to_string())? {
            return Ok((status.code().unwrap_or(128), false));
        }
        if start.elapsed() > Duration::from_secs(seconds) {
            child.kill().map_err(|e|e.to_string())?;
            let _ = child.wait();
            return Ok((124, true));
        }
        thread::sleep(Duration::from_millis(10));
    }
}
fn bytes(path: &Path) -> Result<Vec<u8>, String> { fs::read(path).map_err(|e|format!("{}: {}",path.display(),e)) }
fn trim_lf(v: &[u8]) -> &[u8] { let mut n=v.len(); while n>0 && v[n-1]==10 {n-=1;} &v[..n] }
fn escaped(s: &str) -> Result<Vec<u8>, String> {
    // POSIX printf %b, the historical manifest syntax. Pass data as $1,
    // never parse source/expected text as shell code.
    let p = Command::new("/bin/sh").args(["-c", "printf '%b' \"$1\"", "manifest", s]).output().map_err(|e|e.to_string())?;
    if !p.status.success() { return Err("printf %b failed".into()); } Ok(p.stdout)
}
fn main_work() -> Result<bool, String> {
    let mut compiler=PathBuf::from("./hbc");let mut manifest=PathBuf::from("tests/manifest.txt");
    let mut output=None;let mut target=None;let mut instrument=true;
    let mut args=env::args().skip(1);
    while let Some(a)=args.next() {match a.as_str() {
        "--compiler"=>compiler=PathBuf::from(args.next().ok_or("--compiler needs a value")?),
        "--manifest"=>manifest=PathBuf::from(args.next().ok_or("--manifest needs a value")?),
        "--output"=>output=Some(PathBuf::from(args.next().ok_or("--output needs a value")?)),
        "--target"=>target=Some(args.next().ok_or("--target needs a value")?),
        "--normal"=>instrument=false,
        _=>return Err("usage: run_native_manifest [--compiler ./hbc] [--manifest tests/manifest.txt] --output NEW_DIRECTORY [--target macho|linux|windows] [--normal]".into()),
    }}
    let output=output.ok_or("--output NEW_DIRECTORY is required")?;
    if let Some(p)=output.parent() {if !p.as_os_str().is_empty(){fs::create_dir_all(p).map_err(|e|e.to_string())?;}}
    fs::create_dir(&output).map_err(|e|format!("output must be new: {}",e))?;
    let compiler=fs::canonicalize(compiler).map_err(|e|e.to_string())?;
    let content=fs::read_to_string(&manifest).map_err(|e|e.to_string())?;
    fs::write(output.join("manifest.txt"),&content).map_err(|e|e.to_string())?;
    let hash=Command::new("shasum").args(["-a","256"]).arg(&compiler).output();
    fs::write(output.join("compiler.sha256"),match hash {Ok(p)if p.status.success()=>p.stdout,_=>b"shasum unavailable; compiler hash not verified\n".to_vec()}).map_err(|e|e.to_string())?;
    let mut log=format!("compiler\t{}\nmanifest\t{}\ntarget\t{}\ninstrument\t{}\n",compiler.display(),manifest.display(),target.as_deref().unwrap_or("compiler-host-default"),instrument);
    log.push_str("index\tkind\tsource\tcompile_rc\trun_rc\tpass\tdetail\n");
    let mut total=0;let mut passed=0;
    for (index,line) in content.lines().enumerate() {
        if line.trim().is_empty() || line.starts_with('#') {continue;}
        let mut parts=line.splitn(3,' ');let kind=parts.next().unwrap();let source=parts.next().ok_or("manifest missing source")?;let spec=parts.next().unwrap_or("");
        let case=output.join(format!("{:04}",index));fs::create_dir(&case).map_err(|e|e.to_string())?;
        let exe=fs::canonicalize(&case).map_err(|e|e.to_string())?.join("program");
        let mut c=Command::new(&compiler);c.arg(source).arg(&exe);
        if let Some(t)=&target {c.arg(format!("--target={}",t));}
        if instrument {c.arg("--instrument");}
        if kind!="neg" {c.args(["-I","tests"]);}
        let (compile_rc,compile_timeout)=run(c,&case.join("compile"),30)?;
        let mut run_rc=None;let pass;let detail;
        if kind=="neg" {
            let err=bytes(&case.join("compile.stderr"))?;
            pass=compile_rc!=0 && !compile_timeout && !spec.is_empty() && err.windows(spec.len()).any(|x|x==spec.as_bytes());
            detail="expected compile rejection";
        } else if compile_rc!=0 {
            pass=false;detail=if compile_timeout {"compiler timeout"}else{"compile rejection (not a skip)"};
        } else {
            let (rc,timeout)=run(Command::new(&exe),&case.join("run"),15)?;run_rc=Some(rc);
            let stdout=bytes(&case.join("run.stdout"))?;let stderr=bytes(&case.join("run.stderr"))?;
            let (want_rc,expected,expected_err,legacy)=match kind {
                "pos"=>(0,escaped(spec)?,Vec::new(),true),
                "posx"=>{let (r,s)=spec.split_once(' ').ok_or("posx missing expectation")?;(r.parse().map_err(|_|"invalid posx rc")?,escaped(s)?,Vec::new(),true)},
                "streams"=>{let (a,b)=spec.split_once(' ').ok_or("streams missing expected files")?;(0,bytes(Path::new(a))?,bytes(Path::new(b))?,false)},
                // Mach-O compares the existing Unix/Linux contract here, not
                // a native Harbour/Darwin oracle. Preserve this in the docs.
                "pos2"=>{let(a,_)=spec.split_once(' ').ok_or("pos2 missing files")?;(0,bytes(Path::new(a))?,Vec::new(),false)},
                _=>return Err(format!("unknown manifest kind {}",kind)),
            };
            fs::write(case.join("expected.stdout"),&expected).map_err(|e|e.to_string())?;
            fs::write(case.join("expected.stderr"),&expected_err).map_err(|e|e.to_string())?;
            pass=!timeout && rc==want_rc && stderr==expected_err && if legacy {trim_lf(&stdout)==trim_lf(&expected)}else{stdout==expected};
            detail=if timeout {"runtime timeout"}else if legacy {"legacy pos trims final LF only"}else{"exact channels"};
        }
        total+=1;if pass{passed+=1;}
        println!("{} {} ({})",if pass{"PASS"}else{"FAIL"},source,detail);
        log.push_str(&format!("{}\t{}\t{}\t{}\t{}\t{}\t{}\n",index,kind,source,compile_rc,run_rc.map(|x|x.to_string()).unwrap_or_default(),pass,detail));
        fs::write(output.join("results.tsv"),&log).map_err(|e|e.to_string())?;
        let _=fs::remove_file(&exe); // channels and failure records stay intact
    }
    if total==0 {return Err("manifest contained no test cases".into());}
    println!("{} / {} passed; records: {}",passed,total,output.display());Ok(passed==total)
}
fn main(){match main_work(){Ok(true)=>{},Ok(false)=>std::process::exit(1),Err(e)=>{eprintln!("error: {}",e);std::process::exit(2);}}}

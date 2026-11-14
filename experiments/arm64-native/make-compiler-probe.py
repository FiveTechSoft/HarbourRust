"""Build a separate throwaway frontend harness. Never edits the real worktree.
The actual published hbc keeps ARM64 rejection. This binary is research-only.
"""
from pathlib import Path
import shutil,subprocess,sys
r=Path(__file__).resolve().parent
src=Path(sys.argv[1])/'src';dest=r/'probe-src';dest.mkdir(exist_ok=True)
shutil.copytree(src.parent/'generated',r/'generated',dirs_exist_ok=True)
for f in src.iterdir():
 if f.is_file():shutil.copy2(f,dest/f.name)
for name in ['arm64-ast-probe.rs','arm64-code.rs','arm64-runtime.rs','arm64-trace.rs','arm64-writer.rs','sha256-prototype.rs']:
 shutil.copy2(r/name,dest/name)
s=(dest/'hbc.rs').read_text();s='// THROWAWAY ARM64 RESEARCH HARNESS. Not production hbc.\n#[path="arm64-ast-probe.rs"]mod arm_probe;\n'+s
needle='    if macho_arm64 { eprintln!("error: Mach-O ARM64 code generation is not implemented yet; --target=macho selects Intel x86-64, not native ARM64"); process::exit(1); }'
assert s.count(needle)==1;s=s.replace(needle,'    // Research harness only: ARM64 rejection replaced in this COPY.')
needle='    // I1 supplies conservative proof to the I2 arena eligibility consumer.'
assert s.count(needle)==1
branch='''    if macho_arm64 {
        if instrument || llvm || external_as || !externs.is_empty() || prog.has_classes || THREADS.with(|v|v.get()) || CLASSES.with(|v|!v.borrow().is_empty()) || pre.has_bare_text || pos[1].ends_with(".s") {
            eprintln!("error: ARM64 scalar research harness: flags/EXTERNAL/classes/threads/TEXT/assembly not supported");process::exit(1);
        }
        match arm_probe::emit(&funcs,&sigs) {
            Ok(bytes)=>{fs::write(pos[1],bytes).unwrap();return;},
            Err(msg)=>{eprintln!("error: {}",msg);process::exit(1);}
        }
    }
'''
branch=branch.replace(' || prog.has_classes','')
s=s.replace(needle,branch+needle);(dest/'hbc.rs').write_text(s)
subprocess.run([__import__('os').environ.get('RUSTC','rustc'),'--edition=2021','-O','-C','strip=symbols',str(dest/'hbc.rs'),'-o',str(r/'hbc-arm64-research')],check=True)

#!/usr/bin/env python3
"""Own MIT cross-assembly/link/Intel x86_64 instruction checks, NOT native macOS execution."""
from pathlib import Path
import subprocess,json,os,hashlib,argparse
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--rustc',required=True);ap.add_argument('--lld',required=True);ap.add_argument('--output',required=True);ap.add_argument('--only');a=ap.parse_args();repo=Path(__file__).resolve().parents[2];gate=Path(__file__).resolve().parent;out=Path(a.output).resolve();out.mkdir(exist_ok=False);rows=[];env=dict(os.environ)
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),cwd=repo,env=env,capture_output=True,timeout=30)
 for ext,b in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(b)
 return r
harness=out/'runtime.rs';harness.write_text('#[path="'+str(repo/'src/llvm_darwin.rs')+'"] mod rt; fn main(){print!("{}",rt::intel());}\n');r=run([a.rustc,harness,'-o',out/'runtime-emitter'],out,'emitter-build');assert not r.returncode
r=run([out/'runtime-emitter'],out,'emitter-run');assert not r.returncode;(out/'runtime.s').write_bytes(r.stdout)
r=run(['python3',gate/'cross.py',out/'runtime.s',out/'runtime.o'],out,'runtime-assembly');assert not r.returncode,r.stderr
inputs=[p for p in sorted((repo/'experiments/llvm-scalar').glob('*.prg')) if p.stem not in ['corpus','perfextra','smoke']]
if a.only:inputs=[p for p in inputs if p.stem in a.only.split(',')]
wf=(repo/'.github/workflows/macos.yml').read_text();sample=wf.split("<<'PRG'\n")[1].split('\n          PRG')[0];smoke=out/'workflow-macos.prg';smoke.write_text('\n'.join(x[10:] for x in sample.splitlines())+'\n');inputs.append(smoke)
for src in inputs:
 for flag,tag in [('--experimental-llvm','traced'),('--experimental-llvm-no-trace','notrace')]:
  w=out/(src.stem+'-'+tag);w.mkdir();ir=w/'program.ll';b=run([a.compiler,src,ir,'--target=linux',flag],w,'llvm-build');row=dict(source=(str(src.relative_to(repo)) if src!=smoke else 'workflow-macos-extracted-unmodified'),source_sha256=h(src),mode=tag,llvm_build_rc=b.returncode)
  if b.returncode:row.update(kind='existing-subset-rejection',ok=True);rows.append(row);continue
  n=run([a.compiler,src,w/'native','--target=linux'],w,'native-build');assert not n.returncode,n.stderr
  nr=run([w/'native'],w,'native-run');r=run(['python3',gate/'cross.py',ir,w/'program.o'],w,'cross-ir');assert not r.returncode,r.stderr
  r=run([a.lld,'-arch','x86_64','-platform_version','macos','14.0','14.0','-e','_main',w/'program.o',out/'runtime.o','-o',w/'macho'],w,'cross-link');assert not r.returncode,r.stderr
  r=run(['python3',gate/'emulate.py',w/'macho'],w,'emulate');assert not r.returncode,r.stderr
  actual=tuple((w/('macho.'+s)).read_bytes() for s in ['rc','stdout','stderr']);expected=(str(nr.returncode).encode(),nr.stdout,nr.stderr)
  if src==smoke:assert actual==(b'0',b'\nhello\nsoma         15\nfatorial    3628800',b'')
  # Untraced fatal diagnostics intentionally have no Callstack. The native
  # control always traces, so compare its message prefix in this mode only.
  if tag=='notrace' and nr.returncode!=0:expected=(expected[0],expected[1].split(b'Callstack:\n')[0],expected[2])
  row.update(kind='cross-emulation-vs-native-linux',ok=actual==expected,binary_sha256=h(w/'macho'),native_sha256=h(w/'native'),actual_rc=actual[0].decode(),native_rc=nr.returncode);rows.append(row);print(src.stem,tag,row['ok'],flush=True)
  if not row['ok']:print(actual,expected,flush=True)
  for p in [w/'native',w/'macho',w/'program.o']:p.unlink()
report=dict(compiler_sha256=h(Path(a.compiler)),runtime_sha256=h(out/'runtime.s'),runner_sha256=h(Path(__file__)),scope='Unchanged existing LLVM experiment PRGs, two trace modes; cross Mach-O assembly+link+Intel x86_64 instructions with synthetic Darwin syscall success. Not dyld, kernel, signing, hardware, native CI, Harbour parity or faulted IO.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));assert all(x['ok'] for x in rows)

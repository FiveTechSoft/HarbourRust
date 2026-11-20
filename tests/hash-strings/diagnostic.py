#!/usr/bin/env python3
"""Own MIT explicit HValues limit ordering, not Harbour runtime parity."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all',HBC_MINGW_LIB='/tmp/toolchain/mingwroot/usr/x86_64-w64-mingw32/lib');rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for tg in ['linux','windows']:
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  w=out/(tg+'-'+mode);w.mkdir();src=w/'p.prg';src.write_text('function Main()\nlocal h:={=>},d,a:=Array(1)\nd:=Upper("value")\nh["k"]:=d\n? "before"\nOutErr("err",Chr(10))\na:=hb_HValues(h)\nOutStd("after")\nreturn nil\n');row=dict(target=tg,mode=mode,source_sha256=h(src),implementations={})
  for label,cc in [('before',a.baseline),('after',a.compiler)]:
   exe=w/(label+('.exe' if tg=='windows' else ''));b=subprocess.run([cc,str(src),str(exe),'--target='+tg,'--instrument',*flags],capture_output=True,env=env,timeout=30)
   for ext,v in [('stdout',b.stdout),('stderr',b.stderr),('rc',str(b.returncode).encode())]:(w/(label+'-build.'+ext)).write_bytes(v)
   assert not b.returncode,b.stderr
   cmd=(['wine'] if tg=='windows' else [])+[str(exe)];r=subprocess.run(cmd,capture_output=True,env=env,timeout=20);m=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,env=env,timeout=20)
   for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode()),('merged',m.stdout),('merged-rc',str(m.returncode).encode())]:(w/(label+'-run.'+ext)).write_bytes(v)
   if label=='after':
    assert r.returncode==m.returncode==1 and r.stderr==b'err \n' and b'after' not in r.stdout and r.stdout.count(b'Limit: hb_HValues with string values is not in this increment\n')==1 and b'NIL used as a number' not in r.stdout
    assert m.stdout.index(b'before')<m.stdout.index(b'err \n')<m.stdout.index(b'Limit:')<m.stdout.index(b'Callstack:')
   row['implementations'][label]=dict(build_rc=b.returncode,binary_sha256=h(exe),run_rc=r.returncode,merged_rc=m.returncode);exe.unlink()
  rows.append(row)
report=dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='Before/after same source, separate and merged channels, int/ext Linux/Wine. Explicit unsupported string HValues after diagnostic is not Harbour equality. OutErr retains its existing item separator before LF.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));print('PASS',len(rows))

#!/usr/bin/env python3
"""Own MIT: failure triples, native vs LLVM traced/untraced, not Harbour."""
from pathlib import Path
import subprocess,argparse,json,hashlib,os,sys
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--llvm-lib',required=True);p.add_argument('--output',required=True);a=p.parse_args();r=Path(__file__).resolve().parents[2];d=Path(a.output).resolve();d.mkdir();cc=str(Path(a.compiler).resolve());env=dict(os.environ,HARBOUR_LLVM_LIB=a.llvm_lib);rows=[]
def run(cmd,w,label):
 cmd=list(map(str,cmd));p=subprocess.run(cmd,cwd=base,env=env,capture_output=True,timeout=60)
 for ext,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(b)
 (w/(label+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(base),rc=p.returncode),indent=2)+'\n');return p
base=r/'experiments/llvm-scalar'
sources=[base/n for n in ['error-borrowedraw.prg', 'error-void-argument.prg', 'error-void-return.prg', 'error-void-recursive.prg', 'error-nilcompare.prg', 'error-nilcompare-left.prg', 'error-inc.prg', 'error-recursive.prg', 'error-after-call.prg', 'error-include.prg', 'error-bound.prg', 'error-bound-write.prg', 'error-logic-and.prg', 'error-logic-or.prg', 'error-loopcontrol.prg', 'error-loop-test.prg', 'error-sequence.prg', 'error-minmax.prg', 'error-bitops.prg', 'error-empty.prg', 'error-boolcalls.prg', 'error-booloutput.prg', 'error-scopedslots.prg']]
for src in sources:
 w=d/src.stem;w.mkdir();copy=w/'input.prg';copy.write_bytes(src.read_bytes());(w/'input.sha256').write_text(hashlib.sha256(copy.read_bytes()).hexdigest()+'  input.prg\n')
 want=None
 for name,flags in [('native',[]),('llvm-traced',['--experimental-llvm']),('llvm-traced-repeat',['--experimental-llvm'])]:
  if name=='native':
   exe=w/name;z=run([cc,src,exe],w,name+'-build');assert z.returncode==0,z.stderr
  else:
   ll=w/(name+'.ll');z=run([cc,src,ll,*flags],w,name+'-emit');assert z.returncode==0,z.stderr
   obj=w/(name+'.o');z=run([sys.executable,r/'experiments/llvm-scalar/llvm_aot.py',ll,obj],w,name+'-aot');assert z.returncode==0,z.stderr
   rt=Path(str(ll)+'.runtime.s');z=run([sys.executable,r/'experiments/llvm-scalar/link_runtime.py',rt],w,name+'-wrappers');assert z.returncode==0,z.stderr
   if 'hbc_aclone_alloc:' not in rt.read_text():rt.write_text(rt.read_text()+'\n.text\nhbc_aclone_alloc:\n jmp hbc_alloc\n')
   z=run(['as','-o',w/(name+'.rt.o'),rt],w,name+'-as');assert z.returncode==0,z.stderr
   exe=w/name;z=run(['ld','-o',exe,obj,w/(name+'.rt.o')],w,name+'-link');assert z.returncode==0,z.stderr
  z=run([exe],w,name+'-run');
  if want is None:
   assert z.returncode==1 and not z.stderr,(src,z.returncode,z.stdout,z.stderr)
   want=(z.returncode,z.stdout,z.stderr)
  rows.append(dict(source=src.name,mode=name,exact=(z.returncode,z.stdout,z.stderr)==want));exe.unlink()
  for item in w.iterdir():
   if item.suffix in ['.o','.s','.ll']:item.unlink()
(d/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),llvm_lib_sha256=hashlib.sha256(Path(a.llvm_lib).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows));assert all(x['exact']for x in rows)

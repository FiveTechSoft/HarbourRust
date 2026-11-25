#!/usr/bin/env python3
"""Own MIT: scan exact-output Linux manifest, execute every admitted LLVM input."""
from pathlib import Path
import subprocess,json,hashlib,argparse,sys,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--llvm-lib',required=True);p.add_argument('--output',required=True);p.add_argument('--scan-only',action='store_true');a=p.parse_args();r=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(exist_ok=False);cc=str(Path(a.compiler).resolve());env=dict(os.environ,HARBOUR_LLVM_LIB=a.llvm_lib);rows=[]
def run(cmd,w,label):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=r,capture_output=True,timeout=60,stdin=subprocess.DEVNULL,env=env)
 for ext,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(b)
 (w/(label+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(r)),indent=2)+'\n');return z
def emit(src,w,mode):
 ll=w/(mode+'.ll');z=run([cc,src,ll,'--experimental-llvm' if mode=='traced' else '--experimental-llvm-no-trace','-I','tests'],w,mode+'-emit');return ll,z
for line in (r/'tests/manifest.txt').read_text(encoding='latin1').splitlines():
 if not line.startswith(('pos2 ','streams ','streams2 ')):continue
 kind,src,exp,*rest=line.split();w=out/hashlib.sha256(src.encode()).hexdigest()[:16];w.mkdir();(w/'input.prg').write_bytes((r/src).read_bytes());row=dict(source=src,source_sha256=hashlib.sha256((r/src).read_bytes()).hexdigest());ll,z=emit(src,w,'traced');row['emit_rc']=z.returncode
 if z.returncode:
  assert z.returncode==1 and not ll.exists(),(src,z.returncode,z.stderr);row['status']='rejected';rows.append(row);continue
 row['status']='admitted-scan-only' if a.scan_only else 'pending'
 if a.scan_only:rows.append(row);continue
 errfile=rest[1] if kind=='streams2' else rest[0] if kind=='streams' else None;want=(r/exp).read_bytes();wanterr=(r/errfile).read_bytes()if errfile else b''
 for mode in ['native','traced','untraced']:
  exe=w/mode
  if mode=='native':z=run([cc,src,exe,'--target=linux','-I','tests'],w,mode+'-build');assert z.returncode==0,(src,z.stderr)
  else:
   if mode=='untraced':ll,z=emit(src,w,mode);assert z.returncode==0,(src,z.stderr)
   obj=w/(mode+'.o');z=run([sys.executable,r/'experiments/llvm-scalar/llvm_aot.py',ll,obj],w,mode+'-aot');assert z.returncode==0,(src,z.stderr)
   rt=Path(str(ll)+'.runtime.s');z=run([sys.executable,r/'experiments/llvm-scalar/link_runtime.py',rt],w,mode+'-wrappers');assert z.returncode==0,(src,z.stderr)
   if 'hbc_aclone_alloc:'not in rt.read_text():rt.write_text(rt.read_text()+'\n.text\nhbc_aclone_alloc:\n jmp hbc_alloc\n')
   z=run(['as','-o',w/(mode+'.rt.o'),rt],w,mode+'-as');assert z.returncode==0,(src,z.stderr)
   z=run(['ld','-o',exe,obj,w/(mode+'.rt.o')],w,mode+'-link');assert z.returncode==0,(src,z.stderr)
  z=run([exe],w,mode+'-run');exe.unlink();row[mode]=dict(exact=(z.returncode,z.stdout,z.stderr)==(0,want,wanterr),rc=z.returncode);assert row[mode]['exact'],(src,mode,z.returncode,z.stdout,z.stderr,want,wanterr)
 row['status']='exact';rows.append(row)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),llvm_lib_sha256=hashlib.sha256(Path(a.llvm_lib).read_bytes()).hexdigest(),fresh_Harbour=False,rows=rows),indent=2)+'\n');print('PASS scan',len(rows),'admitted',sum(x['emit_rc']==0 for x in rows),'rejected',sum(x['emit_rc']!=0 for x in rows),flush=True)

#!/usr/bin/env python3
"""Own MIT: exact fresh Harbour vs native and LLVM traced/untraced."""
from pathlib import Path
import subprocess,argparse,json,hashlib,os,sys
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--llvm-lib',required=True);p.add_argument('--output',required=True);a=p.parse_args();r=Path(__file__).resolve().parents[2];d=Path(a.output).resolve();d.mkdir();cc=str(Path(a.compiler).resolve());env=dict(os.environ,HARBOUR_LLVM_LIB=a.llvm_lib);rows=[]
def run(cmd,w,label):
 cmd=list(map(str,cmd));p=subprocess.run(cmd,cwd=w,env=env,capture_output=True,timeout=60)
 for ext,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(b)
 (w/(label+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(w),rc=p.returncode),indent=2)+'\n');return p
sources=sorted(Path(__file__).parent.glob('*.prg'))
for src in sources:
 w=d/src.stem;w.mkdir();copy=w/'input.prg';copy.write_bytes(src.read_bytes());(w/'input.sha256').write_text(hashlib.sha256(copy.read_bytes()).hexdigest()+'  input.prg\n')
 if src.stem.startswith('limit-'):
  for mode in ['--experimental-llvm','--experimental-llvm-no-trace']:
   ll=w/(mode+'.ll');z=run([cc,copy,ll,mode],w,mode);assert z.returncode==1 and not ll.exists() and (b'borrowed constant string reassignment unsupported' if src.stem=='limit-mutable' else b'exact string comparison requires immutable borrowed constants' if src.stem=='limit-owned' else b'expression unsupported: Str(') in z.stderr,(src,z.stderr)
   rows.append(dict(source=src.name,mode=mode,kind='named-limit',exact=False))
  continue
 z=run([a.hbmk2,copy,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert z.returncode==0,z.stderr
 z=run([w/'oracle'],w,'oracle-run');assert z.returncode==0 and not z.stderr;want=z.stdout;(w/'oracle').unlink()
 for name,flags in [('native',[]),('llvm-traced',['--experimental-llvm']),('llvm-untraced',['--experimental-llvm-no-trace'])]:
  if name=='native':
   exe=w/name;z=run([cc,copy,exe],w,name+'-build');assert z.returncode==0,z.stderr
  else:
   ll=w/(name+'.ll');z=run([cc,copy,ll,*flags],w,name+'-emit');assert z.returncode==0,z.stderr
   obj=w/(name+'.o');z=run([sys.executable,r/'experiments/llvm-scalar/llvm_aot.py',ll,obj],w,name+'-aot');assert z.returncode==0,z.stderr
   rt=Path(str(ll)+'.runtime.s');z=run([sys.executable,r/'experiments/llvm-scalar/link_runtime.py',rt],w,name+'-wrappers');assert z.returncode==0,z.stderr
   if 'hbc_aclone_alloc:' not in rt.read_text():rt.write_text(rt.read_text()+'\n.text\nhbc_aclone_alloc:\n jmp hbc_alloc\n')
   z=run(['as','-o',w/(name+'.rt.o'),rt],w,name+'-as');assert z.returncode==0,z.stderr
   exe=w/name;z=run(['ld','-o',exe,obj,w/(name+'.rt.o')],w,name+'-link');assert z.returncode==0,z.stderr
  z=run([exe],w,name+'-run');rows.append(dict(source=src.name,mode=name,exact=(z.returncode,z.stdout,z.stderr)==(0,want,b'')));exe.unlink()
(d/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),llvm_lib_sha256=hashlib.sha256(Path(a.llvm_lib).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');assert all(x['exact']or x.get('kind')=='named-limit'for x in rows);print('PASS',len(rows))

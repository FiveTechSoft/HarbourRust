#!/usr/bin/env python3
"""Own isolated compiler mutants. Rejection and memory mutants reported separately."""
from pathlib import Path
import argparse,hashlib,json,os,shutil,signal,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--rustc',required=True);ap.add_argument('--output',required=True);ap.add_argument('--only',default='wrong-logical,wrong-self,no-result-release,no-admission');a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);repo=Path(__file__).resolve().parents[2];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label,timeout=60):
 p=subprocess.Popen(list(map(str,cmd)),cwd=w,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=p.communicate(timeout=timeout);timed=False
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate();timed=True
 for k,v in [('stdout',so),('stderr',se),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p.returncode,so,se,timed
prefix='#include "hbclass.ch"\nclass Uno\nmethod Cierra()\nendclass\nmethod Cierra() class Uno\nreturn .T.\nclass Dos\nmethod Cierra()\nendclass\nmethod Cierra() class Dos\nreturn Self\nfunction Usa(o)\nreturn ValType(o:Cierra())\n'
mutations={
'wrong-logical':('if ty==Ty::Bool {"L"}','if ty==Ty::Bool {"O"}','functional-output'),
'wrong-self':(';"O"};',';"L"};','functional-output'),
'no-result-release':('call hrobj_release','nop','instrumented-memory'),
'no-admission':('if p==f.params[0]','if false && p==f.params[0]','build-rejection'),
}
for name in a.only.split(','):
 old,new,kind=mutations[name];w=out/name;w.mkdir();src=w/'p.prg';src.write_text(prefix+('function Work(n)\nlocal i\nfor i:=1 to n\nUsa(Dos():New())\nnext\nreturn nil\nfunction Main()\nlocal b\nWork(3)\nb:=hb_memcheck()\nWork(1503)\n? hb_memcheck()-b\nreturn nil\n' if kind=='instrumented-memory' else 'function Main()\n? Usa(Uno():New()),Usa(Dos():New())\nreturn nil\n'));flags=['--target=linux']+(['--instrument'] if kind=='instrumented-memory' else []);control=w/'control';b=run([a.compiler,src,control,*flags],w,'control-build');assert b[0]==0 and not b[3],b;cr=run([control],w,'control-run');assert cr[0]==0 and not cr[2] and not cr[3],cr
 if kind=='instrumented-memory':assert list(map(int,cr[1].split()))==[0],cr
 cb=h(control);control.unlink();sd=w/'rust';sd.mkdir()
 for directory in ['runtime','generated']:os.symlink(repo/directory,w/directory,target_is_directory=True)
 for p in (repo/'src').iterdir():
  if p.is_file():os.symlink(p,sd/p.name)
 module=sd/'method_valtype.rs';source=module.read_text();assert source.count(old)==1,(name,source.count(old));module.unlink();module.write_text(source.replace(old,new));mh=h(module);cc=w/'compiler';b=run([a.rustc,'--edition=2021','-C','debuginfo=0','-C','strip=symbols',sd/'hbc.rs','-o',cc],w,'compiler-build');row=dict(name=name,kind=kind,compiler_build_rc=b[0],compiler_timeout=b[3],source_sha256=h(src),mutated_module_sha256=mh,control_binary_sha256=cb,control_run_rc=cr[0],caught=False)
 if b[0]==0 and not b[3]:
  row['mutant_compiler_sha256']=h(cc);e=w/'program';q=run([cc,src,e,*flags],w,'program-build');row['program_build_rc']=q[0];row['program_timeout']=q[3]
  if kind in ['functional-output','instrumented-memory'] and q[0]==0 and not q[3]:
   row['mutant_binary_sha256']=h(e);q=run([e],w,'program-run');row.update(run_rc=q[0],caught=q[0]==0 and not q[2] and not q[3] and (q[1]!=cr[1] if kind=='functional-output' else int(q[1].strip())>0));e.unlink()
  elif kind=='build-rejection':row['caught']=q[0]==1 and not q[3] and not e.exists()
  cc.unlink()
 shutil.rmtree(sd)
 for directory in ['runtime','generated']:(w/directory).unlink()
 rows.append(row);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),runner_sha256=h(__file__),scope='Two functional output mutants require compiler/program build0,run0 and wrong stdout. One own instrumented lifetime mutant requires build0/run0 and positive pending count after control0. Admission mutant requires build rejection. No proxy counted as product mutant.',rows=rows),indent=2));print(row,flush=True)
assert all(r['caught'] for r in rows),rows

#!/usr/bin/env python3
"""Own isolated functional counterfactuals, never alter the checked working tree."""
from pathlib import Path
import argparse,hashlib,json,os,shutil,signal,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--rustc',required=True);ap.add_argument('--output',required=True);ap.add_argument('--only',default='wrong-string-length,wrong-view-length,no-admission');a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);repo=Path(__file__).resolve().parents[2];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label,timeout=60):
 p=subprocess.Popen(list(map(str,cmd)),cwd=w,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=p.communicate(timeout=timeout);timed=False
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate();timed=True
 for k,v in [('stdout',so),('stderr',se),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p.returncode,so,se,timed
mutations={
'wrong-string-length':('mov -8(%rdx), %rax','mov $99, %eax','functional-output'),
'wrong-view-length':('mov %rdx, %rax','movq $99, 16(%rdx)\\n    mov %rdx, %rax','functional-output'),
'no-admission':('if leaves.contains(id) &&','if false && leaves.contains(id) &&','build-rejection'),
}
for name in a.only.split(','):
 old,new,kind=mutations[name];w=out/name;w.mkdir();src=w/'p.prg';src.write_text('function Count(c)\nreturn Len(c)\nfunction Observe(a)\nreturn Count(a[1])\nfunction Main()\nlocal a:={"abc"}\n? Observe(a),a[1]\nreturn nil\n' if name!="wrong-view-length" else 'function Count(c)\nreturn Len(c)\nfunction Observe(a)\nreturn Count(a[1])\nfunction Main()\nlocal a:={{1,2}}\n? Observe(a),Len(a[1])\nreturn nil\n');control=w/'control';b=run([a.compiler,src,control,'--target=linux'],w,'control-build');assert b[0]==0 and not b[3],b;cr=run([control],w,'control-run');assert cr[0]==0 and not cr[2] and not cr[3],cr;cb=h(control);control.unlink()
 sd=w/'rust';sd.mkdir()
 for directory in ['runtime','generated']:os.symlink(repo/directory,w/directory,target_is_directory=True)
 for p in (repo/'src').iterdir():
  if p.is_file():os.symlink(p,sd/p.name)
 module=sd/'cell_len.rs';source=module.read_text();assert source.count(old)==1,(name,source.count(old));module.unlink();module.write_text(source.replace(old,new));mh=h(module)
 cc=w/'compiler';b=run([a.rustc,'--edition=2021','-C','debuginfo=0','-C','strip=symbols',sd/'hbc.rs','-o',cc],w,'compiler-build');row=dict(name=name,kind=kind,compiler_build_rc=b[0],compiler_timeout=b[3],source_sha256=h(src),mutated_module_sha256=mh,control_binary_sha256=cb,control_run_rc=cr[0],caught=False)
 if b[0]==0 and not b[3]:
  row['mutant_compiler_sha256']=h(cc);e=w/'program';q=run([cc,src,e,'--target=linux'],w,'program-build');row['program_build_rc']=q[0];row['program_timeout']=q[3]
  if kind=='functional-output' and q[0]==0 and not q[3]:
   row['mutant_binary_sha256']=h(e);r=run([e],w,'program-run');row.update(run_rc=r[0],caught=r[0]==0 and not r[2] and not r[3] and r[1]!=cr[1]);e.unlink()
  elif kind=='build-rejection':row['caught']=q[0]==1 and not q[3] and not e.exists()
  cc.unlink()
 shutil.rmtree(sd)
 for directory in ['runtime','generated']:(w/directory).unlink()
 rows.append(row);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),runner_sha256=h(__file__),scope='Two output mutants require compiler/program build0/run0 and wrong stdout; admission mutant separately requires build rejection. No proxy is counted as a functional mutant. Rust modules are isolated temporary symlinks plus one changed own module, deleted after recording hashes and raw logs.',rows=rows),indent=2));print(row,flush=True)
assert all(r['caught'] for r in rows),rows

#!/usr/bin/env python3
"""Own MIT Rust-build-valid counterfactuals, no edits to compiler product."""
from pathlib import Path
import argparse,json,hashlib,subprocess,os,ast
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--rustc',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);source=(repo/'src/hbc.rs').read_text();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
programs=next(ast.literal_eval(n.value) for n in ast.parse(Path(__file__).with_name('check.py').read_text()).body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='programs' for t in n.targets))
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 try:r=subprocess.run(list(map(str,cmd)),cwd=repo,env=env,capture_output=True,timeout=90 if label=='compiler-build' else 20)
 except subprocess.TimeoutExpired as e:r=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
mutations={
'new-default-on-match':('    je .Ldf_first{k}\\n','    jne .Ldf_first{k}\\n','bool-false'),
'no-numeric-unification':('    cmp $9, %eax\\n    je .Ldf_num','    cmp $123, %eax\\n    je .Ldf_num','numeric-kinds'),
'no-first-snapshot':('    cg_data_value(a,env,sigs,strs,out,target);','    cg_default_mutant_borrow(a,env,sigs,strs,out,target);','owned-preserve'),
'no-unselected-release':('    cg_dyn_stack_release(out,16,false);','    // removed selected-first loser release','memory'),
}
for name,(old,new,test) in mutations.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_bytes(Path(__file__).with_name('memory.prg').read_bytes() if test=='memory' else programs[test].encode());flags=['--target=linux']+(['--instrument'] if test=='memory' else []);control=run([a.compiler,src,w/'control',*flags],w,'control-build');assert control.returncode==0;cr=run([w/'control'],w,'control-run');assert cr.returncode==0 and not cr.stderr
 row=dict(name=name,test=test,source_sha256=h(src),control_binary_sha256=h(w/'control'))
 if test!='memory':
  ob=run([a.hbmk2,src,'-quiet','-w0','-gtstd','-o'+str(w/'oracle')],w,'oracle-build');assert ob.returncode==0;rr=run([w/'oracle'],w,'oracle-run');assert (cr.returncode,cr.stdout,cr.stderr)==(rr.returncode,rr.stdout,rr.stderr);row['oracle_binary_sha256']=h(w/'oracle')
 at=source.index('fn cg_default_value(');prefix=source[:at];body=source[at:];assert old in body;mutated=prefix+body.replace(old,new,1)
 if name=='no-first-snapshot':mutated+='\nfn cg_default_mutant_borrow(e:&Expr,env:&[CgLocal],sigs:&[Sig],strs:&mut Vec<String>,out:&mut String,target:Target) {if matches!(expr_ty(e,env,sigs),Ty::Str|Ty::StrOwn) {cg_value(e,env,sigs,strs,out,target);out.push_str("    mov %rax, %rdx\\n    mov $2, %eax\\n");}else{cg_data_value(e,env,sigs,strs,out,target);}}\n'
 rust=repo/'src/hbc_defaultvalue_mutant.rs';rust.write_text(mutated);row['mutated_source_sha256']=h(rust);b=run([a.rustc,'--edition=2021','-C','link-arg=-s',rust,'-o',w/'compiler'],w,'compiler-build');rust.unlink();row.update(compiler_build_rc=b.returncode,caught=False)
 if b.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');mb=run([w/'compiler',src,w/'mutant',*flags],w,'mutant-build');row['program_build_rc']=mb.returncode
  if mb.returncode==0:
   mr=run([w/'mutant'],w,'mutant-run');row.update(kind='runtime-difference',mutant_run_rc=mr.returncode,caught=mr.returncode!=124 and (mr.returncode,mr.stdout,mr.stderr)!=(cr.returncode,cr.stdout,cr.stderr),mutant_binary_sha256=h(w/'mutant'))
  else:row.update(kind='build-rejection',caught=mb.returncode!=124)
 rows.append(row)
 for f in [w/'control',w/'mutant',w/'compiler',w/'oracle']:
  if f.exists():f.unlink()
 print(row,flush=True);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Four own Rust-build-valid mutations: match selection, numeric kind, first string snapshot, loser release. Memory test is instrumentation, other controls exact Harbour. Build failures/timeouts never count as catches.',rows=rows),indent=2))
assert all(r['compiler_build_rc']==0 and r['caught'] for r in rows)

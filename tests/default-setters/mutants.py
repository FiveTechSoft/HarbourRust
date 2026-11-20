from pathlib import Path
import subprocess,hashlib,json,os
import argparse
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--rustc',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();tree=Path(__file__).resolve().parents[2];fixtures=Path(__file__).parent;out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();source=(tree/'src/hbc.rs').read_text();at=source.index('fn cg_default_setter(');prefix=source[:at];body=source[at:];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
cases=json.loads((fixtures/'cases.json').read_text());(out/'nil.prg').write_text(cases['__defaultNIL-nil']);(out/'same.prg').write_text(cases['hb_default-int'])
mutations=[('wrong-nil-test','    cmpb $1, 16(%rsp)\\n','    cmpb $0, 16(%rsp)\\n',out/'nil.prg',False),('wrong-category','    je .Lds_keep{k}\\n','    jne .Lds_keep{k}\\n',out/'same.prg',False),('no-fallback-copy','cg_data_value(b,env,sigs,strs,out,target);','cg_set_mut_borrow(b,env,sigs,strs,out,target);',fixtures/'copy-control.prg',False),('no-old-release','cg_dyn_stack_release(out,16,false);','/* removed old slot release */',fixtures/'memory-short.prg',True),('no-unused-release','    cg_dyn_stack_release(out,0,false);','    /* removed unused snapshot release */',fixtures/'memory-short.prg',True)]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 try:q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,cwd=tree,timeout=45)
 except subprocess.TimeoutExpired as e:q=subprocess.CompletedProcess([],124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for name,old,new,original,memory in mutations:
 w=out/name;w.mkdir();p=w/'p.prg';p.write_bytes(original.read_bytes());flags=['--target=linux']+(['--instrument'] if memory else []);cb=run([cc,p,w/'control',*flags],w,'control-build');assert cb.returncode==0;cr=run([w/'control'],w,'control-run');assert cr.returncode==0 and not cr.stderr
 if not memory:
  ob=run([a.hbmk2,p,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert ob.returncode==0
  rr=run([w/'oracle'],w,'oracle-run');assert (cr.returncode,cr.stdout,cr.stderr)==(rr.returncode,rr.stdout,rr.stderr)
 assert old in body;mutated=prefix+body.replace(old,new,1)
 if name=='no-fallback-copy':mutated+='\nfn cg_set_mut_borrow(e:&Expr,env:&[CgLocal],sigs:&[Sig],strs:&mut Vec<String>,out:&mut String,target:Target) {if matches!(expr_ty(e,env,sigs),Ty::Str|Ty::StrOwn) {cg_value(e,env,sigs,strs,out,target);out.push_str("    mov %rax, %rdx\\n    mov $2, %eax\\n");}else{cg_data_value(e,env,sigs,strs,out,target);}}\n'
 rust=tree/'src/hbc_set_mutant.rs';rust.write_text(mutated);b=run([a.rustc,'--edition=2021','-C','link-arg=-s',rust,'-o',w/'compiler'],w,'rust-build');row=dict(name=name,control_binary_sha256=h(w/'control'),source_sha256=h(p),mutated_source_sha256=h(rust),compiler_build_rc=b.returncode,caught=False);rust.unlink()
 if b.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');mb=run([w/'compiler',p,w/'mutant',*flags],w,'mutant-build');row['program_build_rc']=mb.returncode
  if mb.returncode==0:
   mr=run([w/'mutant'],w,'mutant-run');row.update(mutant_run_rc=mr.returncode,caught=mr.returncode==0 and (mr.stdout,mr.stderr)!=(cr.stdout,cr.stderr),mutant_binary_sha256=h(w/'mutant'))
 if not memory:row['oracle_binary_sha256']=h(w/'oracle')
 rows.append(row)
 for f in [w/'compiler',w/'control',w/'mutant',w/'oracle']:
  if f.exists():f.unlink()
 print(row,flush=True);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Five own counterfactuals: NIL predicate, category match, snapshot copy, old-slot release and unused-fallback release. Both Rust and PRG builds must succeed and runtime0 output must differ. Fresh external Harbour controls except memory instrumentation. No timeout/build rejection counts.',rows=rows),indent=2))
assert len(rows)==5 and all(x['compiler_build_rc']==x.get('program_build_rc')==x.get('mutant_run_rc')==0 and x['caught'] for x in rows)

from pathlib import Path
import subprocess,json,hashlib,os
import argparse
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--rustc',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();tree=Path(__file__).resolve().parents[2];fixtures=Path(__file__).parent;out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);source=(tree/'src/hbc.rs').read_text();at=source.index('fn cg_dyn_string_slice(');prefix=source[:at];body=source[at:];cc=Path(a.compiler).resolve();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
preserve=fixtures/'preserve.prg';memory=fixtures/'memory-short.prg';case=preserve
mutations=[('wrong-direction','    call hbc_left\\n','    call hbc_right\\n',case,False),('move-input-owner','cg_data_value(a,env,sigs,strs,out,target);','cg_dsu_mut_move(a,env,sigs,strs,out,target);',case,False),('no-normal-release','cg_dyn_stack_release(out,0,false);','/* omit normal source snapshot release */',memory,True),('no-catch-release','cg_dyn_stack_release(out,0,false);out.push_str(&format!("    add $64, %rsp\\n    jmp hbc_seq_unwind','/* omit catch snapshot release */out.push_str(&format!("    add $64, %rsp\\n    jmp hbc_seq_unwind',memory,True)]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 try:q=subprocess.run(list(map(str,cmd)),env=env,cwd=tree,capture_output=True,timeout=45)
 except subprocess.TimeoutExpired as e:q=subprocess.CompletedProcess([],124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for name,old,new,original,instrument in mutations:
 w=out/name;w.mkdir();p=w/'p.prg';p.write_bytes(original.read_bytes());flags=['--target=linux']+(['--instrument'] if instrument else []);b=run([cc,p,w/'control',*flags],w,'control-build');assert b.returncode==0;cr=run([w/'control'],w,'control-run');assert cr.returncode==0 and not cr.stderr
 if not instrument:
  ob=run([a.hbmk2,p,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert ob.returncode==0;oq=run([w/'oracle'],w,'oracle-run');assert (oq.returncode,oq.stdout,oq.stderr)==(cr.returncode,cr.stdout,cr.stderr)
 assert old in body;mutated=prefix+body.replace(old,new,1)
 if name=='move-input-owner':mutated+='\nfn cg_dsu_mut_move(e:&Expr,env:&[CgLocal],sigs:&[Sig],strs:&mut Vec<String>,out:&mut String,target:Target) {cg_expr(e,env,sigs,strs,out,target);if let Expr::Var(n)=e {let v=env.iter().rev().find(|v|v.name==*n).unwrap();out.push_str(&format!("    movq $1, -{}(%rbp)\\n    movq $0, -{}(%rbp)\\n",v.off,v.off-8));}}\n'
 rust=tree/'src/hbc_dsu_mutant.rs';rust.write_text(mutated);b=run([a.rustc,'--edition=2021','-C','link-arg=-s',rust,'-o',w/'compiler'],w,'rust-build');row=dict(name=name,source_sha256=h(p),mutated_source_sha256=h(rust),compiler_build_rc=b.returncode,caught=False);rust.unlink()
 if b.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');mb=run([w/'compiler',p,w/'mutant',*flags],w,'mutant-build');row['program_build_rc']=mb.returncode
  if mb.returncode==0:
   q=run([w/'mutant'],w,'mutant-run');row.update(mutant_run_rc=q.returncode,mutant_binary_sha256=h(w/'mutant'),caught=q.returncode==0 and (q.stdout,q.stderr)!=(cr.stdout,cr.stderr))
 rows.append(row)
 for p in [w/'control',w/'oracle',w/'compiler',w/'mutant']:
  if p.exists():p.unlink()
 print(row,flush=True);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Four own Rust-valid mutations, both build stages and runtime0 divergence required; semantic controls external Harbour, memory instrumentation separate. No build rejection, signal, timeout or OOM counts.',rows=rows),indent=2))
assert len(rows)==4 and all(x['compiler_build_rc']==x.get('program_build_rc')==x.get('mutant_run_rc')==0 and x['caught'] for x in rows)

from common import *
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','rustc','output']:p.add_argument('--'+n,type=Path,required=True)
a=p.parse_args();a.output=a.output.resolve();a.output.mkdir();repo=Path(__file__).resolve().parents[2];rust=(repo/'src/hbc.rs').read_text();cases=json.loads(Path(__file__).with_name('cases.json').read_text());rows=[]
start=rust.index('        Expr::Call(id,args) if is_builtin(id,"hb_osdriveseparator") => {');end=rust.index('        Expr::Call(id,args) if is_builtin(id,"hb_ps") => {',start);arm=rust[start:end]
for name,newarm in [('colon',arm.replace('strs.push(String::new())','strs.push(":".to_string())').replace('xor %esi, %esi','mov $1, %esi')),('nul-byte',arm.replace('xor %esi, %esi','mov $1, %esi'))]:
 w=a.output/name;w.mkdir();control=w/'control';control.mkdir();exact(a,control,cases['basic']);mutated=rust[:start]+newarm+rust[end:];src=repo/'src/hbc_osdrive_mutant.rs';src.write_text(mutated)
 try:q=run([a.rustc,'--edition','2021','-C','link-arg=-s',src,'-o',w/'compiler'],w,'rust-build',60)
 finally:src.unlink()
 row=dict(name=name,compiler_build_rc=q.returncode,mutated_source_sha256=hashlib.sha256(mutated.encode()).hexdigest(),caught=False)
 if q.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');q=run([w/'compiler',control/'p.prg',w/'mutant','--target=linux'],w,'mutant-build');row['program_build_rc']=q.returncode
  if q.returncode==0:
   q=run([w/'mutant'],w,'mutant-run');row.update(run_rc=q.returncode,binary_sha256=h(w/'mutant'),caught=q.returncode==0 and not q.stderr and q.stdout!=(control/'oracle-run.stdout').read_bytes());(w/'mutant').unlink()
  (w/'compiler').unlink()
 rows.append(row);print(name,row,flush=True)
finish(a,rows,'2own Rust-valid functional OS separator variants:colon result or counted NUL instead of empty. Compiler+program build0 and run0 required,stdout different from fresh exact oracle controls. No rejection/signal counts.')
assert len(rows)==2 and all(x['compiler_build_rc']==x.get('program_build_rc')==x.get('run_rc')==0 and x['caught'] for x in rows)

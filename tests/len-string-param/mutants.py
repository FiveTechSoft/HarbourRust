from common import *
import shutil
p=argparse.ArgumentParser()
for k in ['compiler','hbmk2','rustc','output']:p.add_argument('--'+k,type=Path,required=True)
a=p.parse_args();a.output=a.output.resolve();a.output.mkdir();repo=Path(__file__).resolve().parents[2];text=(repo/'src/hbc.rs').read_text();
for child in repo.iterdir():
 if child.is_dir() and child.name not in ['src','.git']:(a.output/child.name).symlink_to(child,target_is_directory=True)
cases=json.loads(Path(__file__).with_name('cases.json').read_text());rows=[]
mutants=[('no-deferral','if printed[i].len_line.is_none() {printed[i].len_line=Some(n);}','pin_vars(f,&Expr::Var(v.clone()),Ty::DArr,pin,n)?;','ascii-upper-before'),('erase-string-precedence','if !matches!(pin[i],Some(Ty::Str|Ty::StrOwn)) {pin_vars(f,&Expr::Var(f.params[i].clone()),Ty::DArr,&mut pin,line)?;}','pin_vars(f,&Expr::Var(f.params[i].clone()),Ty::DArr,&mut pin,line)?;','ascii-at-after')]
for name,before,after,case in mutants:
 w=a.output/name;w.mkdir();assert text.count(before)==1;mut=text.replace(before,after);src=w/'hbc.rs';src.write_text(mut)
 # Modules and include_str payloads are resolved from the original source tree.
 for child in (repo/'src').iterdir():
  if child.name!='hbc.rs':(w/child.name).symlink_to(child,target_is_directory=child.is_dir())
 b=run([a.rustc,'--edition','2021',src,'-o',w/'mutant-compiler'],w,'compiler-build',60);row=dict(name=name,compiler_build_rc=b.returncode,mutated_source_sha256=h(src),caught=False)
 if b.returncode==0:
  row['mutant_compiler_sha256']=h(w/'mutant-compiler');control=w/'control';control.mkdir();control_source=control/'p.prg';control_source.write_text(cases[case]);a.baseline=a.compiler
  c=exact(a,control,cases[case],False);assert c['results']['base']['build_rc']==0
  q=run([w/'mutant-compiler',control_source,w/'mutant-program','--target=linux'],w,'program-build');row.update(program_build_rc=q.returncode,program_executed=False,diagnostic=q.stderr.decode(),caught=q.returncode==1 and ((name=='no-deferral' and b'`len` expects an array' in q.stderr) or (name=='erase-string-precedence' and b'hb_At expects typed strings' in q.stderr)) and not(w/'mutant-program').exists());(w/'mutant-compiler').unlink()
 rows.append(row);print(name,row['caught'],flush=True)
finish(a,rows,'2Rust-valid inference mutants. Unchanged controls execute oracle-exact int/ext. A mutant counts only as named build rejection,not runtime wrongness; no rejected mutant is executed. Not presented as functional divergence.')
assert all(x['caught'] for x in rows)

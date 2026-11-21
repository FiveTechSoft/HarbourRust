#!/usr/bin/env python3
"""Real own Ret condition mutants. Build rejection and crashes never count."""
from pathlib import Path
import argparse,json,shutil
from common import *
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--rustc',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);repo=Path(__file__).resolve().parents[2];rows=[]
old='if matches!(expr_ty(e, env, sigs), Ty::Obj(_)) && !obj_fresh(e, env, sigs) {'
mutations=[('extra-fresh-retain','if matches!(expr_ty(e, env, sigs), Ty::Obj(_)) {','factory','memory'),('extra-send-retain','if matches!(expr_ty(e, env, sigs), Ty::Obj(_)) && (!obj_fresh(e,env,sigs) || matches!(e,Expr::Send(..))) {','method-fresh','memory'),('missing-borrow-retain','if false && matches!(expr_ty(e, env, sigs), Ty::Obj(_)) {','borrow-local','output')]
for name,new,case,kind in mutations:
 w=out/name;w.mkdir();s=w/'p.prg';s.write_text(source(case,1503 if kind=='memory' else 1,kind=='memory'));flags=['--target=linux']+(['--instrument'] if kind=='memory' else []);control=w/'control';b=run([a.compiler,s,control,*flags],w,'control-build');assert b[0]==0 and not b[3];q=run([control],w,'control-run');assert q[0]==0 and not q[2] and not q[3];assert q[1].split()==([b'1503',b'0'] if kind=='memory' else [b'1']);ch=h(control);control.unlink()
 sd=w/'src';sd.mkdir()
 for directory in ['runtime','generated']:os.symlink(repo/directory,w/directory,target_is_directory=True)
 for f in (repo/'src').iterdir():
  if f.is_file():os.symlink(f,sd/f.name)
 main=sd/'hbc.rs';text=main.read_text();assert text.count(old)==1;main.unlink();main.write_text(text.replace(old,new));mh=h(main);cc=w/'compiler';b=run([a.rustc,'--edition=2021','-C','debuginfo=0','-C','strip=symbols',main,'-o',cc],w,'compiler-build',90);row=dict(name=name,kind=kind,mutated_source_sha256=mh,source_sha256=h(s),control_binary_sha256=ch,compiler_build_rc=b[0],compiler_timeout=b[3],caught=False)
 if b[0]==0 and not b[3]:
  row['mutant_compiler_sha256']=h(cc);e=w/'program';b=run([cc,s,e,*flags],w,'program-build');row['program_build_rc']=b[0]
  if b[0]==0 and not b[3]:
   row['mutant_binary_sha256']=h(e);z=run([e],w,'program-run');valid=z[0]==0 and not z[2] and not z[3];parts=z[1].split();row.update(run_rc=z[0],caught=valid and (len(parts)==2 and parts[0]==b'1503' and int(parts[1])>0 if kind=='memory' else z[1]!=q[1]));e.unlink()
  cc.unlink()
 shutil.rmtree(sd)
 for directory in ['runtime','generated']:(w/directory).unlink()
 rows.append(row);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),runner_sha256=h(__file__),fixtures_sha256=h(Path(__file__).with_name('common.py')),scope='Three real Ret source mutants: overretain fresh,overretain send,omit borrowed retain. Every counted mutant requires compiler build0,program build0,run0,no timeout/stderr. Memory requires positivepending aftercontrol0;output requires differentstdout.',rows=rows),indent=2));print(row,flush=True)
assert all(x['caught'] for x in rows)

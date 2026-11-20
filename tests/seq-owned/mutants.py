#!/usr/bin/env python3
"""Own MIT compiler counterfactuals; isolated Rust source, never patch working product."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--rustc',required=True);ap.add_argument('--output',required=True);ap.add_argument('--only',required=True);a=ap.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);source=(repo/'src/hbc.rs').read_text();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
mutations={
'no-prefix-release':('''if i+1 < es.len() && !matches!(e, Expr::Var(_)) {''','''if false && i+1 < es.len() && !matches!(e, Expr::Var(_)) {''','memory'),
'no-final-clone':('''} else if i+1 == es.len() && matches!(e, Expr::Var(_)) {''','''} else if false && i+1 == es.len() && matches!(e, Expr::Var(_)) {''','copy'),
'no-float-discard-release':('''if t == Ty::StrOwn && !matches!(e, Expr::Var(_)) {\n        out.push_str''','''if false && t == Ty::StrOwn && !matches!(e, Expr::Var(_)) {\n        out.push_str''','memory'),
'no-print-unwind-release':('''Ty::StrOwn if matches!(e, Expr::Call(..) | Expr::Bin(..) | Expr::Seq(..)) => 2,''','''Ty::StrOwn if matches!(e, Expr::Call(..) | Expr::Bin(..)) => 2,''','memory'),
'no-list-promotion':('''Expr::Seq(es) => es.last().map_or(false, owned_assign),''','''Expr::Seq(_) => false,''','accumulator'),
}
programs={'memory':Path(__file__).with_name('memory.prg').read_bytes(),'copy':b'function Main()\nlocal c:=Upper("survives"),i:=0\nfor i:=1 to 10\nOutStd((1,c),c,Chr(10))\nnext\nreturn nil\n','accumulator':b'function Main()\nlocal c:="begin",n:=0\nc:=(n:=n+1,c+"end")\nOutStd(c,n,Chr(10))\nreturn nil\n'}
def run(cmd,w,label):
 try:p=subprocess.run(list(map(str,cmd)),cwd=repo,env=env,capture_output=True,timeout=60)
 except subprocess.TimeoutExpired as e:p=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'')
 for k,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return p
for name in a.only.split(','):
 old,new,test=mutations[name];assert source.count(old)==1,(name,source.count(old));w=out/name;w.mkdir();src=w/'p.prg';src.write_bytes(programs[test]);control=run([a.compiler,src,w/'control','--target=linux','--instrument'],w,'control-build');assert control.returncode==0;cr=run([w/'control'],w,'control-run');assert cr.returncode==0 and not cr.stderr
 rust=repo/'src/hbc_seq_mutant.rs';rust.write_text(source.replace(old,new));(w/'mutated-source.sha256').write_text(h(rust));mb=run([a.rustc,'--edition=2021',rust,'-o',w/'compiler'],w,'compiler-build');rust.unlink();row=dict(name=name,test=test,compiler_build_rc=mb.returncode,source_sha256=h(src),control_binary_sha256=h(w/'control'),control_run_rc=cr.returncode)
 if mb.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');b=run([w/'compiler',src,w/'mutant','--target=linux','--instrument'],w,'mutant-build');row['program_build_rc']=b.returncode
  if b.returncode==0:
   row['mutant_binary_sha256']=h(w/'mutant');mr=run([w/'mutant'],w,'mutant-run');row.update(kind='runtime-difference',mutant_run_rc=mr.returncode,caught=(mr.returncode,mr.stdout,mr.stderr)!=(cr.returncode,cr.stdout,cr.stderr))
  else:row.update(kind='build-rejection',caught=True)
 else:row.update(kind='mutant-compiler-build-failure',caught=False)
 for p in [w/'control',w/'mutant',w/'compiler']:
  if p.is_file():p.unlink()
 rows.append(row);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Five isolated own Rust compiler counterfactuals, one relevant workload each; runtime vs build-rejection distinguished',rows=rows),indent=2));print(row,flush=True)
assert all(x['caught'] for x in rows)

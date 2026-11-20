#!/usr/bin/env python3
"""Own MIT compiler counterfactuals; isolated Rust source, never patch working product."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--rustc',required=True);ap.add_argument('--output',required=True);ap.add_argument('--only',required=True);a=ap.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);source=(repo/'src/hbc.rs').read_text();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
mutations={
'no-store-clone':('hbc_hash_value_clone:\n    cmp $2, %rax','hbc_hash_value_clone:\n    jmp hbc_float_clone\n    cmp $2, %rax','cache'),
'no-string-drop':('.Lhashvr_string:\n    mov %rdx, %rdi\n    jmp hbc_freestr','.Lhashvr_string:\n    ret\n    mov %rdx, %rdi\n    jmp hbc_freestr','memory'),
'no-literal-init':('if !matches!(vt, Ty::I64 | Ty::Bool | Ty::Dyn) && !(matches!(v,Expr::Str(_))','if !matches!(vt, Ty::I64 | Ty::Bool | Ty::Dyn) && !(false && matches!(v,Expr::Str(_))','literal'),
'no-hvalues-limit':('je hbc_hvalues_string_error','je hbc_hvalues_string_error','hvalues'),
}
mutations.pop('no-hvalues-limit')
programs={
'cache':b'function Main()\nlocal h:={=>},d,z\nd:=Upper("old-value")\nh["k"]:=d\nd:=Upper("new-value")\nz:=Upper("bad-value")\n? h["k"],z\nreturn nil\n',
'literal':b'function Main()\nlocal h:={"k"=>"literal"}\n? h["k"]\nreturn nil\n',
'memory':(repo/'tests/hash-strings/memory.prg').read_bytes(),
}
def run(cmd,w,label):
 try:p=subprocess.run(list(map(str,cmd)),cwd=repo,env=env,capture_output=True,timeout=60)
 except subprocess.TimeoutExpired as e:p=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'')
 for k,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return p
for name in a.only.split(','):
 old,new,test=mutations[name];assert source.count(old)==1,(name,source.count(old));w=out/name;w.mkdir();src=w/'p.prg';src.write_bytes(programs[test]);control=run([a.compiler,src,w/'control','--target=linux','--instrument'],w,'control-build');assert control.returncode==0;cr=run([w/'control'],w,'control-run');assert cr.returncode==0 and not cr.stderr
 rust=repo/'src/hbc_hash_mutant.rs';rust.write_text(source.replace(old,new));(w/'mutated-source.sha256').write_text(h(rust));mb=run([a.rustc,'--edition=2021',rust,'-o',w/'compiler'],w,'compiler-build');rust.unlink();row=dict(name=name,test=test,compiler_build_rc=mb.returncode,source_sha256=h(src),control_binary_sha256=h(w/'control'),control_run_rc=cr.returncode)
 if mb.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');b=run([w/'compiler',src,w/'mutant','--target=linux','--instrument'],w,'mutant-build');row['program_build_rc']=b.returncode
  if b.returncode==0:
   row['mutant_binary_sha256']=h(w/'mutant');mr=run([w/'mutant'],w,'mutant-run');row.update(kind='runtime-difference',mutant_run_rc=mr.returncode,caught=(mr.returncode,mr.stdout,mr.stderr)!=(cr.returncode,cr.stdout,cr.stderr))
  else:row.update(kind='build-rejection',caught=True)
 else:row.update(kind='mutant-compiler-build-failure',caught=False)
 for p in [w/'control',w/'mutant',w/'compiler']:
  if p.is_file():p.unlink()
 rows.append(row);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Three isolated hash compiler counterfactuals with forced string-cache reuse, memory and literal-init tests. Runtime divergence vs program rejection distinguished.',rows=rows),indent=2));print(row,flush=True)
assert all(x['caught'] for x in rows)

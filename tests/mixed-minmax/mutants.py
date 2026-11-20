#!/usr/bin/env python3
"""Own MIT compiler counterfactuals; isolated Rust source, never patch working product."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--rustc',required=True);ap.add_argument('--output',required=True);ap.add_argument('--only',required=True);a=ap.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);source=(repo/'src/hbc.rs').read_text();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
mutations={
'no-mixed-admission':('if minmax_mixed_tys(a,b) { return Ok(Ty::Dyn); }','if false && minmax_mixed_tys(a,b) { return Ok(Ty::Dyn); }','basic'),
'erase-i64-metadata':('cg_i64_tagged(out);\n    } else { cg_mul_snapshot(e,env,sigs,strs,out,target); }','out.push_str("    mov %rax, %rdx\\n    xor %eax, %eax\\n");\n    } else { cg_mul_snapshot(e,env,sigs,strs,out,target); }','large'),
}
programs={
'basic':b'function Main()\n? Min(2,1.25)\nreturn nil\n',
'large':b'function Main()\nlocal seed:=9007199254740992,a:=9007199254740993,b:=seed/1\n? Min(a,b),Max(a,b)\nreturn nil\n',
}
def run(cmd,w,label):
 try:p=subprocess.run(list(map(str,cmd)),cwd=repo,env=env,capture_output=True,timeout=60)
 except subprocess.TimeoutExpired as e:p=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'')
 for k,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return p
for name in a.only.split(','):
 old,new,test=mutations[name];assert source.count(old)==1,(name,source.count(old));w=out/name;w.mkdir();src=w/'p.prg';src.write_bytes(programs[test]);control=run([a.compiler,src,w/'control','--target=linux','--instrument'],w,'control-build');assert control.returncode==0;cr=run([w/'control'],w,'control-run');assert cr.returncode==0 and not cr.stderr
 rust=repo/'src/hbc_minmax_mutant.rs';rust.write_text(source.replace(old,new));(w/'mutated-source.sha256').write_text(h(rust));mb=run([a.rustc,'--edition=2021',rust,'-o',w/'compiler'],w,'compiler-build');rust.unlink();row=dict(name=name,test=test,compiler_build_rc=mb.returncode,source_sha256=h(src),control_binary_sha256=h(w/'control'),control_run_rc=cr.returncode)
 if mb.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');b=run([w/'compiler',src,w/'mutant','--target=linux','--instrument'],w,'mutant-build');row['program_build_rc']=b.returncode
  if b.returncode==0:
   row['mutant_binary_sha256']=h(w/'mutant');mr=run([w/'mutant'],w,'mutant-run');row.update(kind='runtime-difference',mutant_run_rc=mr.returncode,caught=(mr.returncode,mr.stdout,mr.stderr)!=(cr.returncode,cr.stdout,cr.stderr))
  else:row.update(kind='build-rejection',caught=True)
 else:row.update(kind='mutant-compiler-build-failure',caught=False)
 for p in [w/'control',w/'mutant',w/'compiler']:
  if p.is_file():p.unlink()
 rows.append(row);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Two own isolated MinMax compiler counterfactuals, one PRG rejection and one runtime metadata/output difference.',rows=rows),indent=2));print(row,flush=True)
assert all(x['caught'] for x in rows)

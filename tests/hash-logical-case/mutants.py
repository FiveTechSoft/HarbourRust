#!/usr/bin/env python3
"""Own MIT representation/admission counterfactuals, no product source patching."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--rustc',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(exist_ok=False);source=(repo/'src/hbc.rs').read_text();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 try:r=subprocess.run(list(map(str,cmd)),cwd=repo,env=env,capture_output=True,timeout=60 if label=='compiler-build' else 10)
 except subprocess.TimeoutExpired as e:r=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
mutations={
'no-logical-getter':('if is_builtin(id, "hb_hcasematch") { return if hash_case_logical_profile() {Ty::Bool}else{Ty::I64}; }','if is_builtin(id, "hb_hcasematch") { return Ty::I64; }','getter'),
'no-old-snapshot':('mov %rax, 8(%rsp)\\n    mov (%rsp), %rsi\\n    lea -{}(%rbp), %rdi\\n    call hbc_hsetcasematch\\n    mov 8(%rsp), %rax','mov %rax, 8(%rsp)\\n    mov (%rsp), %rsi\\n    lea -{}(%rbp), %rdi\\n    call hbc_hsetcasematch\\n    mov (%rsp), %rax','setter'),
'no-clear-preserve':('if hash_case_logical_profile() {"hbc_hclear_keepcase"}else{"hbc_hclear"}','if false && hash_case_logical_profile() {"hbc_hclear_keepcase"}else{"hbc_hclear"}','clear'),
}
programs={
'getter':'function Main()\nlocal h:={=>}\n? hb_HCaseMatch(h)\nreturn nil\n',
'setter':'function Main()\nlocal h:={=>}\n? hb_HCaseMatch(h,.F.),hb_HCaseMatch(h)\nreturn nil\n',
'clear':'function Main()\nlocal h:={=>}\nhb_HCaseMatch(h,.F.)\nh["Host"]:=1\nhb_HClear(h)\nh["Host"]:=2\n? hb_HCaseMatch(h),hb_HHasKey(h,"HOST")\nreturn nil\n',
}
for name,(old,new,test) in mutations.items():
 assert source.count(old)==1,(name,source.count(old));w=out/name;w.mkdir();src=w/'p.prg';src.write_text(programs[test]);cb=run([a.compiler,src,w/'control','--target=linux'],w,'control-build');ob=run([a.hbmk2,src,'-quiet','-w0','-gtstd','-o'+str(w/'oracle')],w,'oracle-build');assert ob.returncode==0;rr=run([w/'oracle'],w,'oracle-run');assert rr.returncode==0 and not rr.stderr;row=dict(name=name,source_sha256=h(src),control_build_rc=cb.returncode,oracle_binary_sha256=h(w/'oracle'))
 if True:
  assert cb.returncode==0;cr=run([w/'control'],w,'control-run');assert (cr.returncode,cr.stdout,cr.stderr)==(rr.returncode,rr.stdout,rr.stderr);row['control_binary_sha256']=h(w/'control')
 rust=repo/'src/hbc_hashcase_mutant.rs';rust.write_text(source.replace(old,new));row['mutated_source_sha256']=h(rust);mb=run([a.rustc,'--edition=2021','-C','link-arg=-s',rust,'-o',w/'compiler'],w,'compiler-build');rust.unlink();row['compiler_build_rc']=mb.returncode;row['caught']=False
 if mb.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');b=run([w/'compiler',src,w/'mutant','--target=linux'],w,'mutant-build');row['program_build_rc']=b.returncode
  if b.returncode==0:
   mr=run([w/'mutant'],w,'mutant-run');row.update(kind='runtime-difference',mutant_run_rc=mr.returncode,mutant_binary_sha256=h(w/'mutant'),caught=mr.returncode!=124 and (mr.returncode,mr.stdout,mr.stderr)!=(rr.returncode,rr.stdout,rr.stderr))
  else:row.update(kind='build-rejection',caught=True)
 for f in [w/'control',w/'oracle',w/'mutant',w/'compiler']:
  if f.is_file():f.unlink()
 rows.append(row);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Three own Rust-build-valid counterfactuals: logical getter, old flag snapshot, clear preserves mode. Compiler build failures/timeouts are not catches. External Harbour executable only.',rows=rows),indent=2));print(row,flush=True)
assert all(x['caught'] and x['compiler_build_rc']==0 for x in rows)

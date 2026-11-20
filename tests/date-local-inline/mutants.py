#!/usr/bin/env python3
"""Own MIT counterfactuals: Date admission, narrowing and dominance."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--rustc',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(exist_ok=False);source=(repo/'src/hbc.rs').read_text();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),cwd=repo,env=env,capture_output=True,timeout=60)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
mutations={
'no-date-admission':('let date_inline = t==Ty::Date && DECIMAL_LOCAL_PROFILE.with(|v|v.get()) && env.iter().any(|v|v.name==*id && v.ty==Ty::Date);','let date_inline = false;'),
'no-narrowing':('    narrow_bare_date_locals(&mut funcs);','    // Counterfactual: no Date narrowing.'),
'ignore-early-observation':('let first=f.stmts[i+1..].iter().find(|s|stmt_mentions(s,&name));','let first=f.stmts[i+1..].iter().find(|s|first_store(s,&name));'),
}
for name,(old,new) in mutations.items():
 assert source.count(old)==1,(name,source.count(old));w=out/name;w.mkdir();src=w/'p.prg';src.write_text('function Main()\nlocal d\n'+('? ValType(d)\n' if name=='ignore-early-observation' else '')+'? (d:=StoD("20260203")),d\nreturn nil\n');cb=run([a.compiler,src,w/'control','--target=linux'],w,'control-build');oracle=run([a.hbmk2,src,'-quiet','-w0','-gtstd','-o'+str(w/'oracle')],w,'oracle-build');assert oracle.returncode==0;rr=run([w/'oracle'],w,'oracle-run');assert rr.returncode==0 and not rr.stderr;row=dict(name=name,source_sha256=h(src),control_build_rc=cb.returncode,oracle_binary_sha256=h(w/'oracle'))
 if name=='ignore-early-observation':assert cb.returncode==1
 else:
  assert cb.returncode==0;cr=run([w/'control'],w,'control-run');assert (cr.returncode,cr.stdout,cr.stderr)==(rr.returncode,rr.stdout,rr.stderr);row['control_binary_sha256']=h(w/'control')
 rust=repo/'src/hbc_dateinline_mutant.rs';rust.write_text(source.replace(old,new));row['mutated_source_sha256']=h(rust);mb=run([a.rustc,'--edition=2021','-C','link-arg=-s',rust,'-o',w/'compiler'],w,'compiler-build');rust.unlink();row['compiler_build_rc']=mb.returncode;row['caught']=False
 if mb.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');b=run([w/'compiler',src,w/'mutant','--target=linux'],w,'mutant-build');row['program_build_rc']=b.returncode
  if b.returncode==0:
   mr=run([w/'mutant'],w,'mutant-run');row.update(kind='runtime-difference',mutant_run_rc=mr.returncode,mutant_binary_sha256=h(w/'mutant'),caught=(mr.returncode,mr.stdout,mr.stderr)!=(rr.returncode,rr.stdout,rr.stderr))
  elif name!='ignore-early-observation':row.update(kind='build-rejection',caught=True)
 for f in [w/'control',w/'oracle',w/'mutant',w/'compiler']:
  if f.is_file():f.unlink()
 rows.append(row);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Three own Rust-build-valid counterfactuals. No admission and no narrowing reject an exact positive; ignoring early mention admits a source with D instead of Harbour U before first store. External Harbour executable only.',rows=rows),indent=2));print(row,flush=True)
assert all(x['caught'] and x['compiler_build_rc']==0 for x in rows)

from pathlib import Path
import subprocess,hashlib,json,os,argparse
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--rustc',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();tree=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();source=(tree/'src/hbc.rs').read_text();cases=json.loads(Path(__file__).with_name('cases.json').read_text());env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 try:q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,cwd=tree,timeout=45)
 except subprocess.TimeoutExpired as e:q=subprocess.CompletedProcess([],124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for name,old,new,case in [('char-to-space','name=="chr" && id.eq_ignore_ascii_case("hb_bchar")','name=="space" && id.eq_ignore_ascii_case("hb_bchar")','char-ascii'),('code-to-length','name=="asc" && id.eq_ignore_ascii_case("hb_bcode")','name=="len" && id.eq_ignore_ascii_case("hb_bcode")','code-ascii')]:
 w=out/name;w.mkdir();p=w/'p.prg';p.write_text(cases[case]);b=run([cc,p,w/'control','--target=linux'],w,'control-build');assert b.returncode==0;cr=run([w/'control'],w,'control-run');assert cr.returncode==0 and not cr.stderr;ob=run([a.hbmk2,p,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert ob.returncode==0;oq=run([w/'oracle'],w,'oracle-run');assert (oq.returncode,oq.stdout,oq.stderr)==(cr.returncode,cr.stdout,cr.stderr)
 assert source.count(old)==1;mutated=source.replace(old,new,1);rust=tree/'src/hbc_byte_mutant.rs';rust.write_text(mutated);b=run([a.rustc,'--edition=2021','-C','link-arg=-s',rust,'-o',w/'compiler'],w,'rust-build');row=dict(name=name,source_sha256=h(p),mutated_source_sha256=h(rust),compiler_build_rc=b.returncode,caught=False);rust.unlink()
 if b.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');mb=run([w/'compiler',p,w/'mutant','--target=linux'],w,'mutant-build');row['program_build_rc']=mb.returncode
  if mb.returncode==0:
   q=run([w/'mutant'],w,'mutant-run');row.update(mutant_run_rc=q.returncode,mutant_binary_sha256=h(w/'mutant'),caught=q.returncode==0 and (q.stdout,q.stderr)!=(cr.stdout,cr.stderr))
 rows.append(row)
 for p in [w/'control',w/'oracle',w/'compiler',w/'mutant']:
  if p.exists():p.unlink()
 print(row,flush=True);(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Two own routing mutants. Both Rust/PRG build0 plus runtime0 difference mandatory; unchanged controls equal fresh external Harbour. No rejection,signal,timeout,OOM or identical output counts.',rows=rows),indent=2))
assert len(rows)==2 and all(x['compiler_build_rc']==x.get('program_build_rc')==x.get('mutant_run_rc')==0 and x['caught'] for x in rows)

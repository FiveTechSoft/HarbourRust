from pathlib import Path
import subprocess,json,hashlib,os,argparse
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(exist_ok=False);cc=Path(a.compiler).resolve();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for e,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(v)
 return q
for name,text in json.loads(Path(__file__).with_name('limit-cases.json').read_text()).items():
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  w=out/(name+'-'+mode);w.mkdir();p=w/'p.prg';p.write_text(text);oracle=w/'oracle.prg';oracle.write_text('\n'.join('BEGIN SEQUENCE WITH {|o| Break(o)}' if l=='TRY' else 'RECOVER' if l=='CATCH e' else 'END SEQUENCE' if l=='END' else l for l in text.split('\n')));b=run([cc,p,w/'ours','--target=linux',*flags],w,'build');ob=run([a.hbmk2,oracle,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert b.returncode==ob.returncode==0
  q=run([w/'ours'],w,'run');oq=run([w/'oracle'],w,'oracle-run');rhs=name.startswith('rhs-');prefix=b'before \n'+(b'' if name.startswith('rhs-start') else b'pos \n')+(b'count \n' if not rhs and name.endswith('-3') else b'')
  if rhs:ok=q.returncode==oq.returncode==0 and (q.stdout,q.stderr)==(oq.stdout,oq.stderr) and oq.stdout==prefix+b'caught \nafter \n'
  else:ok=q.returncode==1 and q.stdout.startswith(prefix+b'Limit: Dyn SubStr requires a string source in this increment\nCallstack:\n') and b'caught \n' not in q.stdout and b'after \n' not in q.stdout and not q.stderr and oq.returncode==0 and oq.stdout==prefix+b'caught \nafter \n'
  row=dict(name=name,mode=mode,kind='rhs-catch-exact' if rhs else 'explicit-runtime-limit',source_sha256=h(p),oracle_source_sha256=h(oracle),oracle_adapter=True,build_rc=b.returncode,run_rc=q.returncode,oracle_build_rc=ob.returncode,oracle_run_rc=oq.returncode,binary_sha256=h(w/'ours'),oracle_binary_sha256=h(w/'oracle'),ok=ok);rows.append(row);(w/'ours').unlink();(w/'oracle').unlink();print(name,mode,ok,flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='26 cases:20 explicit fatal limits, not Harbour parity;6 RHS-catch exact. Own TRY syntax adapted only in oracle. Operand effects precede source validation. Timeout never passes.',rows=rows),indent=2));assert len(rows)==26 and all(x['ok'] for x in rows)

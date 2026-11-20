from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for api in ['hb_bitTest','hb_bitSet','hb_bitReset']:
 for n,v in [('nil','nil'),('bool','.t.'),('str','"1"'),('float','1.25')]:
  for mode,flags in [('int',[]),('ext',['--external-as'])]:
   w=out/(api+'-'+n+'-'+mode);w.mkdir();p=w/'p.prg';text='function Main()\nlocal bit\nbit:='+v+'\nTRY\n? '+api+'(0,bit)\nCATCH e\n? "caught"\nEND\n? "after"\nreturn nil\n';p.write_text(text);oracle=w/'oracle.prg';oracle.write_text(text.replace('TRY\n','BEGIN SEQUENCE WITH {|o| Break(o)}\n').replace('CATCH e\n','RECOVER\n').replace('END\n','END SEQUENCE\n'));b=run([a.compiler,p,w/'ours','--target=linux',*flags],w,'build');ob=run([a.hbmk2,oracle,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert b.returncode==ob.returncode==0;q=run([w/'ours'],w,'run');oq=run([w/'oracle'],w,'oracle-run');ok=q.returncode==oq.returncode==0 and not q.stderr and not oq.stderr and q.stdout==b'\n' + b'caught\nafter'
   rows.append(dict(name=api+'-'+n,mode=mode,source_sha256=h(p),oracle_source_sha256=h(oracle),oracle_adapter=True,build_rc=b.returncode,run_rc=q.returncode,oracle_run_rc=oq.returncode,kind='F64 runtime rejection, oracle accepts/truncates' if n=='float' else 'runtime type rejection',oracle_exact=(q.stdout,q.stderr)==(oq.stdout,oq.stderr),binary_sha256=h(w/'ours'),oracle_binary_sha256=h(w/'oracle'),ok=ok));(w/'ours').unlink();(w/'oracle').unlink()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='24explicit runtime type guards and stack-unwind continuation controls. Own TRY syntax adapted for oracle only. F64 Dyn rejected rather than coerced though Harbour truncates. Not blanket oracle parity.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==24 and all(x['ok'] for x in rows)

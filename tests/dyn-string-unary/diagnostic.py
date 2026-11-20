from pathlib import Path
import subprocess,json,hashlib,os
import argparse
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=Path(a.compiler).resolve();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);hb=a.hbmk2;rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label,merged=False):
 q=subprocess.run(list(map(str,cmd)),env=env,capture_output=not merged,stdout=subprocess.PIPE if merged else None,stderr=subprocess.STDOUT if merged else None,timeout=30)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr or b''),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
for api in ['Lower','Upper','AllTrim']:
 for kind,init in [('nil','nil'),('number','7'),('float','1.25'),('bool','.F.'),('array','{1}')]:
  for mode,flags in [('int',[]),('ext',['--external-as'])]:
   w=out/(api+'-'+kind+'-'+mode);w.mkdir();p=w/'p.prg';text='function Main()\nlocal x,y\nx:='+init+'\nOutStd("before",Chr(10))\nTRY\ny:='+api+'(x)\nCATCH e\nOutStd("caught",Chr(10))\nEND\nOutStd("after",Chr(10))\nreturn nil\n';p.write_text(text)
   oracle=w/'oracle.prg';oracle.write_text('\n'.join('BEGIN SEQUENCE WITH {|o| Break(o)}' if l=='TRY' else 'RECOVER' if l=='CATCH e' else 'END SEQUENCE' if l=='END' else l for l in text.split('\n')))
   b=run([cc,p,w/'ours','--target=linux',*flags],w,'build');ob=run([hb,oracle,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert b.returncode==ob.returncode==0
   q=run([w/'ours'],w,'run');oq=run([w/'oracle'],w,'oracle-run');raw=q.stdout+(q.stderr or b'');ok=q.returncode==1 and q.stdout.startswith(b'before \nLimit: Dyn string consumer requires a string value in this increment\n') and b'NIL used as a number' not in raw and b'caught \n' not in raw and oq.returncode==0 and oq.stdout==b'before \ncaught \nafter \n'
   rows.append(dict(api=api,kind=kind,mode=mode,source_sha256=h(p),oracle_source_sha256=h(oracle),oracle_adapter=True,build_rc=b.returncode,run_rc=q.returncode,oracle_build_rc=ob.returncode,oracle_run_rc=oq.returncode,binary_sha256=h(w/'ours'),oracle_binary_sha256=h(w/'oracle'),ok=ok));(w/'ours').unlink();(w/'oracle').unlink();print(api,kind,mode,ok,flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='30 runtime limit probes. Own TRY syntax explicitly adapted only for external Harbour. Harbour catches invalid argument and continues; compiler fatal limit is explicitly NOT catchable parity. No timeout passes.',rows=rows),indent=2));assert len(rows)==30 and all(x['ok'] for x in rows)

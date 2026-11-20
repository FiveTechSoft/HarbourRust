from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.'+e)).write_bytes(b)
 return q
cases={}
for api in ['hb_bitTest','hb_bitSet','hb_bitReset']:
 for kind in ['PRIVATE','PUBLIC']:
  for n,v in [('int','7'),('float','1.25'),('bool','.t.'),('str','"123"')]:cases[api+'-'+kind+'-'+n]='function Main()\n'+kind+' bit:='+v+'\n? '+api+'(0,bit)\nreturn nil\n'
 cases[api+'-local-in-memvar-context']='function Main()\nlocal bit\nPRIVATE other:=7\nbit:=7\n? '+api+'(0,bit)\nreturn nil\n'
 cases[api+'-local-in-macro-context']='function Main()\nlocal bit,s:="1+2"\nbit:=7\n? '+api+'(0,bit)\n? &(s)\nreturn nil\n'
for name,text in cases.items():
 w=out/name;w.mkdir();p=w/'p.prg';text='\n'.join('TRY\n'+l+'\nCATCH e\n? \"caught\"\nEND' if l.startswith('? hb_') else l for l in text.split('\n'));p.write_text(text);oracle=w/'oracle.prg';oracle.write_text(text.replace('TRY\n','BEGIN SEQUENCE WITH {|o| Break(o)}\n').replace('CATCH e\n','RECOVER\n').replace('END\n','END SEQUENCE\n'));b=run([a.compiler,p,w/'ours','--target=linux'],w,'build');ob=run([a.hbmk2,oracle,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');q=run([w/'oracle'],w,'oracle-run') if not ob.returncode else None;ok=b.returncode==1 and b'Dyn bit index requires ordinary Linux non-macro local storage' in b.stderr and b'panicked' not in b.stderr and not (w/'ours').exists() and bool(q and q.returncode==0 and not q.stderr);row=dict(name=name,source_sha256=h(p),build_rc=b.returncode,oracle_build_rc=ob.returncode,oracle_run_rc=q.returncode if q else None,oracle_adapter=True,oracle_source_sha256=h(oracle),ok=ok)
 if q:row['oracle_binary_sha256']=h(w/'oracle');(w/'oracle').unlink()
 rows.append(row)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='30 explicit compile-time limits against fresh executable Harbour oracle,not runtime parity.24PRIVATE/PUBLIC numeric/non-numeric plus6localDyn macro-context controls. No rejected binary executed.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==30 and all(x['ok'] for x in rows)

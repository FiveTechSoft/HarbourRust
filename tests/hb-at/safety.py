from pathlib import Path
import subprocess,json,hashlib,os
import argparse
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();rows=[];cc=Path(a.compiler);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])

def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,n):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=15)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(n+'.'+e)).write_bytes(b)
 return q
for at in ['normal','search','text','start','end']:
 body='local i,e\nfor i:=1 to 100\n'
 if at=='normal':body+='if hb_At(Replicate("A",64),Replicate("A",128),2,128)!=2\n? "bad-value"\nendif\n'
 else:
  args={'search':'Throw(),Replicate("A",128)','text':'Replicate("A",64),Throw()','start':'Replicate("A",64),Replicate("A",128),Throw()','end':'Replicate("A",64),Replicate("A",128),1,Throw()'}[at]
  body+='TRY\n? hb_At('+args+')\nCATCH e\nEND\n'
 body+='next\nreturn nil\n'
 text='function Main()\nlocal i\nWork()\n? hb_memcheck()\nfor i:=1 to 100\nWork()\nnext\n? hb_memcheck()\nreturn nil\nfunction Work()\n'+body+'function Throw()\nBreak("x")\nreturn '+('"unused"' if at in ['search','text'] else '1')+'\n'
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
  w=out/(at+'-'+mode);w.mkdir();p=w/'p.prg';p.write_text(text);b=run([cc,p,w/'ours','--target=linux','--instrument',*flags],w,'build');q=run([w/'ours'],w,'run') if not b.returncode else None;ok=bool(q and q.returncode==0 and q.stdout==b'\n         0\n         0' and not q.stderr);row=dict(name=at,mode=mode,build_rc=b.returncode,run_rc=q.returncode if q else None,source_sha256=h(p),ok=ok)
  if q:row['binary_sha256']=h(w/'ours');(w/'ours').unlink()
  rows.append(row);print(row,flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='15instrumented lifetime modes,normal andtext/start/endthrow positions,100warmup+10000measured calls,zeroallocdelta and BAD-value guard. Not oracle parity of hb_memcheck.',rows=rows),indent=2));assert all(x['ok'] for x in rows)

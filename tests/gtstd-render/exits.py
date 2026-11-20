#!/usr/bin/env python3
"""Original MIT. Raw fatal/TRY/WAIT boundaries, with explicit registered failure differences."""
from pathlib import Path
import argparse,json,subprocess,hashlib
ap=argparse.ArgumentParser()
for n in ['compiler','baseline','hbmk2','output']:ap.add_argument('--'+n,required=True)
a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[];hashes={};commands=[]
def run(cmd,w,tag,stdin=b'Z'):
 commands.append(dict(argv=list(map(str,cmd)),cwd=str(w),tag=tag,stdin_hex=stdin.hex()))
 try:p=subprocess.run(list(map(str,cmd)),cwd=w,input=stdin,capture_output=True,timeout=5)
 except subprocess.TimeoutExpired as e:p=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for ext,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(tag+'.'+ext)).write_bytes(b)
 return p

def case(name,source,kind,stdin=b'Z',oracle_source=None):
 w=out/name;w.mkdir();s=w/'p.prg';s.write_text(source);os=w/'oracle.prg';os.write_text(oracle_source if oracle_source is not None else source);results={}
 for label,cmd in [('oracle',[a.hbmk2,os,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')]),('baseline',[a.baseline,s,w/'baseline','--target=linux','--instrument']),('int',[a.compiler,s,w/'int','--target=linux','--instrument']),('ext',[a.compiler,s,w/'ext','--target=linux','--instrument','--external-as'])]:
  b=run(cmd,w,label+'-build',stdin);r=run([w/label],w,label+'-run',stdin) if b.returncode==0 else None;results[label]=(b,r)
  if (w/label).exists():hashes[str((w/label).relative_to(out))]=hashlib.sha256((w/label).read_bytes()).hexdigest();(w/label).unlink()
 for mode in ['int','ext']:
  b,r=results[mode];bb,br=results['baseline'];ob,o=results['oracle']
  exact=lambda p,q:bool(p and q and (p.returncode,p.stdout,p.stderr)==(q.returncode,q.stdout,q.stderr))
  if kind=='registered-fatal':ok=b.returncode==bb.returncode==0 and exact(r,br)
  elif kind=='unsupported':ok=b.returncode==bb.returncode==1 and r is None and br is None
  else:ok=b.returncode==0 and ob.returncode==0 and exact(r,o)
  rows.append(dict(name=name+'-'+mode,kind=kind,ok=bool(ok),build_rc=b.returncode,baseline_build_rc=bb.returncode,oracle_build_rc=ob.returncode,run_rc=r.returncode if r else None,baseline_rc=br.returncode if br else None,oracle_rc=o.returncode if o else None,oracle_exact=exact(r,o),baseline_exact=exact(r,br),source_sha256=hashlib.sha256(s.read_bytes()).hexdigest(),oracle_source_sha256=hashlib.sha256(os.read_bytes()).hexdigest()))
  if not ok:print('FAIL',name,mode,kind,flush=True)

def main(body):return 'function Main()\n'+body+'\nreturn nil\n'
for name,body in {'empty-break':'? ""\nBreak("boom")','text-break':'? "text"\nBreak("boom")','two-empty-break':'? ""\n? ""\nBreak("boom")','lf-break':'?? "a"+Chr(10)+Chr(10)\nBreak("boom")','empty-div':'local a:=1,b:=0\n? ""\n? a/b','text-div':'local a:=1,b:=0\n? "text"\n? a/b','lf-div':'local a:=1,b:=0\n?? "a"+Chr(10)+Chr(10)\n? a/b'}.items():case(name,main(body),'registered-fatal')
render='function Show(s)\n?? iif(hb_isnumeric(s[1]),hb_ntos(s[1]),s[1])\nreturn nil\nfunction Main()\nlocal a:={{1}}\n? ""\nShow(a)\nreturn nil\n';case('empty-render-error',render,'registered-fatal')
for n,body in {'empty-quit':'? ""\nQUIT','lf-quit':'?? "a"+Chr(10)+Chr(10)\nQUIT','errorlevel':'? ""\nErrorLevel(7)','box-qout':'DispBox(0,0,2,4,"123456789")\n? "after"','empty-box-qout':'? ""\nDispBox(0,0,2,4,"123456789")\n? "after"','box-bs':'DispBox(0,0,2,4,"123456789")\n?? Chr(8)+"X"','box-cr':'DispBox(0,0,2,4,"123456789")\n?? Chr(13)+"X"','box-lf':'DispBox(0,0,2,4,"123456789")\n?? Chr(10)+"X"'}.items():case(n,main(body),'unsupported')
for name,prefix in [('empty','? ""'),('two-empty','? ""\n? ""'),('lf','?? "a"+Chr(10)+Chr(10)'),('text','? "abc"')]:
 source=main('local n:=0\n'+prefix+'\nTRY\nBreak("boom")\nCATCH e\nOutStd(e)\nEND\n?? "X"');oracle=source.replace('TRY\n','begin sequence with {|e| Break(e)}\n').replace('CATCH e\n','recover using e\n').replace('END\n','end sequence\n');case('caught-'+name,source,'oracle-expanded-TRY',oracle_source=oracle)
for key in [32,65,90,126]:
 for name,body in {'qout':'WAIT\n? "after"','empty-qout':'? ""\nWAIT\n? "after"','text-inline':'?? "abc"\nWAIT\n?? "X"','bs':'WAIT\n?? Chr(8)+"X"','cr':'WAIT\n?? Chr(13)+"X"','lf':'WAIT\n?? Chr(10)+"X"'}.items():case('wait-'+str(key)+'-'+name,main(body),'oracle-exact-WAIT',bytes([key]))
result=dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),baseline_sha256=hashlib.sha256(Path(a.baseline).read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),scope='Raw stdout/stderr/rc. Fatal differences already registered vs Harbour: require exact baseline diagnostics and preserved prefix, report oracle_exact separately; never call these Harbour-exact. QUIT/ErrorLevel and mixed DispBox remain build rejections. TRY oracle syntax expanded, WAIT sources unchanged.',passed=sum(r['ok'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));(out/'binary-shas.json').write_text(json.dumps(hashes,indent=2));(out/'commands.json').write_text(json.dumps(commands,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(r['ok'] for r in rows))

#!/usr/bin/env python3
"""Own MIT lifetime/limit controls plus a Date oracle-positive row."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);p.add_argument('--hbmk2',required=True);a=p.parse_args();cc=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),env=env,capture_output=True,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
def oracle_pair(name,text,observable,boundary,diagnostic):
 # One original row is upgraded, not removed or skipped. The unchanged PRG
 # and an observable companion both need exact int/ext oracle equality.
 w=out/name;w.mkdir();checks={}
 for case,source in [('original',text),('observable',observable)]:
  d=w/case;d.mkdir();src=d/'p.prg';src.write_text(source);results={}
  for label,cmd in [('oracle',[a.hbmk2,src,'-quiet','-w0','-gtstd','-o'+str(d/'oracle')]),('int',[cc,src,d/'int','--target=linux']),('ext',[cc,src,d/'ext','--target=linux','--external-as'])]:
   b=run(cmd,d,label+'-build');rr=dict(build_rc=b.returncode)
   if b.returncode==0:
    q=run([d/label],d,label+'-run');rr.update(run_rc=q.returncode,binary_sha256=h(d/label));(d/label).unlink()
   results[label]=rr
  built=all(x['build_rc']==0 and x.get('run_rc')==0 for x in results.values())
  exact=built and all((d/(label+'-run.'+ext)).read_bytes()==(d/('oracle-run.'+ext)).read_bytes() for label in ['int','ext'] for ext in ['stdout','stderr','rc'])
  checks[case]=dict(source_sha256=h(src),results=results,exact=exact)
 d=w/'boundary';d.mkdir();src=d/'p.prg';src.write_text(boundary);results={}
 # Harbour must accept/run the boundary. A local compiler limitation is not
 # mislabeled as a language-invalid source or counted as oracle equality.
 b=run([a.hbmk2,src,'-quiet','-w0','-gtstd','-o'+str(d/'oracle')],d,'oracle-build');rr=dict(build_rc=b.returncode)
 if b.returncode==0:
  q=run([d/'oracle'],d,'oracle-run');rr.update(run_rc=q.returncode,binary_sha256=h(d/'oracle'));(d/'oracle').unlink()
 results['oracle']=rr
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  binary=d/mode;b=run([cc,src,binary,'--target=linux',*flags],d,mode+'-build');results[mode]=dict(build_rc=b.returncode,diagnostic_matches=diagnostic in b.stderr,no_artifact=not binary.exists())
 rejected=results['oracle']['build_rc']==0 and results['oracle'].get('run_rc')==0 and all(results[m]['build_rc']==1 and results[m]['diagnostic_matches'] and results[m]['no_artifact'] for m in ['int','ext'])
 checks['boundary']=dict(source_sha256=h(src),results=results,expected='Harbour accepts; compiler explicitly rejects unsupported neighboring shape',ok=rejected)
 rows.append(dict(name=name,kind='oracle-positive-with-neighbor-boundary',checks=checks,ok=all(checks[x]['exact'] for x in ['original','observable']) and rejected))
for mode,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
 w=out/mode;w.mkdir();src=w/'p.prg';src.write_bytes(Path(__file__).with_name('memory.prg').read_bytes());b=run([cc,src,w/'p','--target=linux','--instrument',*flags],w,'build');r=run([w/'p'],w,'run') if not b.returncode else None
 row=dict(name=mode,kind='lifetime',source_sha256=h(src),build_rc=b.returncode,ok=bool(r and r.returncode==0 and r.stdout==b'      2000          0 \n' and not r.stderr))
 if r:row['binary_sha256']=h(w/'p');(w/'p').unlink()
 rows.append(row)
program='function Keep(x)\nreturn x\nfunction Main()\nlocal x\n? (x:=Keep(nil))\nreturn nil\n'
for name,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('threads',['--target=linux'])]:
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if name=='threads' else '')+program.replace('function Main()\n','function Main()\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else '')));b=run([cc,src,w/'p',*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and b'inline `:=`' in b.stderr and not (w/'p').exists()))
oracle_pair('date','function Main()\nlocal x:=StoD("20260101")\n? (x:=StoD("20260203"))\nreturn nil\n','function Main()\nlocal x:=StoD("20260101")\n? (x:=StoD("20260203")),x,ValType(x),Day(x),Month(x),Year(x)\nreturn nil\n','function Main()\nlocal x\n? x,ValType(x),(x:=StoD("20260203"))\nreturn nil\n',b'inline `:=`')
negative={
'float-static':'function Main()\nlocal x\n? (x:=1.25)\nreturn nil\n',
'string-static':'function Main()\nlocal x\n? (x:=Upper("hello"))\nreturn nil\n',
'byref':'function Keep(x)\nreturn x\nfunction Put(x)\n? (x:=Keep(nil))\nreturn nil\nfunction Main()\nlocal x\nPut(@x)\nreturn nil\n',
}
for name,text in negative.items():
 expected=b'inline `:=`'
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(text);b=run([cc,src,w/'p','--target=linux'],w,'build');rows.append(dict(name=name,kind='shape-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and expected in b.stderr and not (w/'p').exists()))
assert len(rows)==12, "top-level safety row count changed"
report=dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Three lifetime modes with1000 string/F64 autocopy/nested/discard loops plus2000 catches, warmup then allocation delta0. Five excluded profiles and three static limits; Date row verifies original and observable companion against Harbour int/ext, plus unsupported early-read boundary. Lifetime instrumentation and rejections are not oracle equality.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));print([x for x in rows if not x['ok']]);assert all(x['ok'] for x in rows)

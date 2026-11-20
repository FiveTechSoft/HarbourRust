#!/usr/bin/env python3
"""Own MIT hash safety checks with a literal integer-key oracle-positive row."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);p.add_argument('--hbmk2',required=True);a=p.parse_args();cc=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=30)
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
 row=dict(name=mode,kind='lifetime',source_sha256=h(src),build_rc=b.returncode,ok=bool(r and r.returncode==0 and r.stdout==b'      1000          0 \n' and not r.stderr))
 if r:row['binary_sha256']=h(w/'p');(w/'p').unlink()
 rows.append(row)
oracle_pair('numeric-key','function Main()\nlocal h:={=>}\nh[10]:="literal"\nreturn nil\n','function Main()\nlocal h:={=>}\nh[10]:="literal"\nh["10"]:="string-key"\n? h[10],h["10"],Len(h),hb_HHasKey(h,10)\nreturn nil\n','function Main()\nlocal h:={=>},n:=10\nh[n]:="literal"\n? h[n]\nreturn nil\n',b'hash keys are strings')
negative={
'owned-temporary':'local h:={=>}\nh["k"]:=Upper("fresh")',
'owned-variable':'local h:={=>},s:=Upper("fresh")\nh["k"]:=s',
'array-value':'local h:={=>}\nh["k"]:={1,2}',
'effectful-key':'local h:={=>}\nh[Upper("k")]:="literal"',
}
for name,body in negative.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text('function Main()\n'+body+'\nreturn nil\n');b=run([cc,src,w/'p','--target=linux'],w,'build');rows.append(dict(name=name,kind='build-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and not (w/'p').exists()))
for name,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('threads',['--target=linux'])]:
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if name=='threads' else '')+'function Main()\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else '')+'local h:={"k"=>"literal"}\n? h["k"]\nreturn nil\n');b=run([cc,src,w/'p',*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and not (w/'p').exists()))
for mode,flags in [('int',[]),('ext',['--external-as'])]:
 w=out/('hvalues-'+mode);w.mkdir();src=w/'p.prg';src.write_text('function Main()\nlocal h:={"k"=>"literal"},a:=hb_HValues(h)\n? Len(a)\nreturn nil\n');b=run([cc,src,w/'p','--target=linux','--instrument',*flags],w,'build');r=run([w/'p'],w,'run') if not b.returncode else None
 row=dict(name='hvalues-'+mode,kind='named-runtime-limit-not-oracle-equality',source_sha256=h(src),build_rc=b.returncode,ok=bool(r and r.returncode==1 and b'Limit: hb_HValues with string values is not in this increment\n' in r.stdout and b'NIL used as a number' not in r.stdout))
 if r:row['binary_sha256']=h(w/'p');(w/'p').unlink()
 rows.append(row)
assert len(rows)==15, "top-level safety row count changed"
report=dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Three lifetime controls, four shape rejections, five profiles, two HValues runtime limits, plus numeric-key original/observable exact Harbour int/ext and unsupported variable-key boundary. Instrumentation/limits are not oracle equality.',passed=sum(x['ok'] for x in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));print(report['passed'],report['total'],[x for x in rows if not x['ok']]);assert all(x['ok'] for x in rows)

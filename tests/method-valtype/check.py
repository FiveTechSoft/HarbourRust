#!/usr/bin/env python3
"""Own MIT bounded method-result type observer, external Harbour oracle only."""
from pathlib import Path
import argparse,hashlib,json,os,signal,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--baseline');ap.add_argument('--hbmk2',required=True);ap.add_argument('--output',required=True);ap.add_argument('--external-p11');a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 p=subprocess.Popen(list(map(str,cmd)),cwd=w,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=p.communicate(timeout=15);timed=False
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate();timed=True
 for k,v in [('stdout',so),('stderr',se),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p.returncode,so,se,timed
classes='#include "hbclass.ch"\nclass Uno\nmethod Cierra()\nendclass\nmethod Cierra() class Uno\nreturn .T.\nclass Dos\nmethod Cierra()\nendclass\nmethod Cierra() class Dos\nreturn Self\n'
observe='function Usa(o)\nreturn ValType(o:Cierra())\n'
def main(body='? Usa(Uno():New()),Usa(Dos():New())',defs=classes+observe):return defs+'function Main()\n'+body+'\nreturn nil\n'
programs={
'basic':main(),
'reverse-call':main('? Usa(Dos():New()),Usa(Uno():New())'),
'bare-instances':main('? Usa(Uno()),Usa(Dos())'),
'variable-owners':main('local a:=Uno():New(),b:=Dos():New()\n? Usa(a),Usa(b),a:ClassName(),b:ClassName(),Usa(a),Usa(b)'),
'false':main(defs=(classes+observe).replace('return .T.','return .F.')),
'both-bool':main(defs=(classes+observe).replace('return Self','return .F.')),
'both-objects':main(defs=(classes+observe).replace('return .T.','return Self')),
'reverse-return':main(defs=(classes+observe).replace('return .T.','return Other()').replace('return Self','return .F.').replace('return Other()','return Self')),
'method-effect':main(defs=(classes+observe).replace('return .T.','OutStd("uno",Chr(10))\nreturn .T.').replace('return Self','OutStd("dos",Chr(10))\nreturn Self')),
'self-effect':main(defs=(classes+observe).replace('return Self','OutStd("self",Chr(10))\nreturn Self')),
'self-branch':main(defs=(classes+observe).replace('return Self','if .T.\nreturn Self\nendif\nreturn Self')),
'br-name':main(defs=(classes+observe).replace('Usa','Usa__brave')).replace('? Usa(', '? Usa__brave(').replace(',Usa(', ',Usa__brave('),
'method-name':main(defs=(classes+observe).replace('Cierra','Close')),
'observer-after-main':main(defs=classes)+observe,
'local-effects':main(defs=(classes+observe).replace('return .T.','local n:=1\n? n\nreturn n==1')),
'empty-data-object':main('local a:=Uno():New(),b:=Dos():New()\n? Usa(a),Usa(b)',(classes+observe).replace('method Cierra()\nendclass','data empty\nmethod Cierra()\nendclass')),
'lateral-output':main('? Usa(Uno():New()),Usa(Dos():New()),Usa(Uno():New()),Usa(Dos():New())'),
'repeat':main('local a:=Uno():New(),b:=Dos():New(),i\nfor i:=1 to 17\n? Usa(a),Usa(b)\nnext\n? a:ClassName(),b:ClassName()'),
'different-slots':main(defs=(classes+observe).replace('class Dos\nmethod Cierra()','class Dos\nmethod Other()\nmethod Cierra()')+'method Other() class Dos\nreturn 99\n'),
'inherited':main('? Usa(Uno():New()),Usa(Hijo():New()),Usa(Dos():New())',classes+'class Hijo from Dos\nendclass\n'+observe),
'override':main('? Usa(Uno():New()),Usa(Hijo():New()),Usa(Dos():New())',classes+'class Hijo from Dos\nmethod Cierra()\nendclass\nmethod Cierra() class Hijo\nreturn .F.\n'+observe),
'one-class':main('? Usa(Uno():New())',classes.split('class Dos')[0]+observe),
'object-state':main('local a:=Uno():New(),b:=Dos():New()\na:n:=1\nb:n:=2\n? Usa(a),Usa(b),a:n,b:n',(classes+observe).replace('method Cierra()\nendclass','data n\nmethod Cierra()\nendclass').replace('return .T.','::n:=7\nreturn .T.').replace('return Self','::n:=8\nreturn Self')),
'two-observers':main('? Usa(Uno():New()),Mirror(Dos():New())',classes+observe+observe.replace('Usa','Mirror')),
}
if a.external_p11:programs['external-p11-unmodified']=Path(a.external_p11).read_text()
for name,s in programs.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(s);e=w/'oracle';b=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(e)],w,'oracle-build');assert b[0]==0 and not b[3],(name,b);osh=h(e);oracle=run([e],w,'oracle-run');e.unlink();assert oracle[0]==0 and not oracle[3],(name,oracle)
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
  e=w/mode;b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,mode+'-build');row=dict(name=name,mode=mode,source_sha256=h(src),oracle_binary_sha256=osh,build_rc=b[0],timeout=b[3],exact=False)
  if b[0]==0 and not b[3]:
   row['binary_sha256']=h(e);q=run([e],w,mode+'-run');row.update(run_rc=q[0],timeout=q[3],exact=not q[3] and q[:3]==oracle[:3]);e.unlink()
  rows.append(row);print(name,mode,row['exact'],flush=True)
 if a.baseline:
  e=w/'base';b=run([a.baseline,src,e,'--target=linux'],w,'base-build');rows.append(dict(name=name,mode='baseline',source_sha256=h(src),build_rc=b[0],timeout=b[3]));assert b[0]==1 and not b[3] and not e.exists(),(name,b)
 (out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline) if a.baseline else None,runner_sha256=h(__file__),scope='Exact rc/stdout/stderr external Harbour comparison. Baseline rejection not runtime wrongness. Five Linux instrumented modes. No native PE/Mac execution claim.',rows=rows),indent=2))
assert all(x['exact'] for x in rows if x['mode']!='baseline'),[x for x in rows if x['mode']!='baseline' and not x['exact']]
print('PASS',sum(x['mode']!='baseline' for x in rows))

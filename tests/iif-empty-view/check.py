#!/usr/bin/env python3
"""Own MIT read-only optional-array probes; Harbour is an external oracle only."""
from pathlib import Path
import argparse,hashlib,json,os,signal,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--baseline');ap.add_argument('--hbmk2',required=True);ap.add_argument('--output',required=True);ap.add_argument('--external-p05');a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 p=subprocess.Popen(list(map(str,cmd)),cwd=w,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=p.communicate(timeout=20);timed=False
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate();timed=True
 for k,v in [('stdout',so),('stderr',se),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p.returncode,so,se,timed
pick='function Pick(a)\nlocal b:=IIf(a==nil,{},a)\nreturn Len(b)\n'
def main(body,defs=pick):return defs+'function Main()\n'+body+'\nreturn nil\n'
programs={
'omitted-and-nil':main('? Pick(),Pick(nil)'),
'explicit-empty':main('local a:={}\n? Pick(a),Len(a)'),
'flat-owned':main('local a:={}\nAAdd(a,41)\n? Pick(a),Len(a),a[1]'),
'flat-fixed':main('local a:={1,2,3}\n? Pick(),Pick(a),Len(a),a[3]'),
'strings':main('local a:={}\nAAdd(a,Upper("one"))\nAAdd(a,"two")\n? Pick(),Pick(a),Len(a),a[1],a[2]'),
'logicals':main('local a:={}\nAAdd(a,.T.)\n? Pick(a),Len(a),a[1]'),
'nested':main('local a:={},b:=Array(2)\nAAdd(a,b)\n? Pick(a),Len(a),Len(a[1])'),
'mixed-cells':main('local a:={1,"two",.T.,nil}\n? Pick(a),Len(a),a[2]'),
'two-level-literal':main('local a:={{1,2},{3}}\n? Pick(a),Len(a),Len(a[1])'),
'repeat-and-grow':main('local a:={},i\nAAdd(a,41)\nfor i:=1 to 17\n? Pick(a),Len(a)\nAAdd(a,i)\nnext\n? Pick(a),Len(a)'),
'reverse-ne':main('local a:={1,2}\n? Pick(),Pick(nil),Pick(a),Len(a)',pick.replace('a==nil,{},a','a!=nil,a,{}')),
'reverse-operand':main('local a:={1,2}\n? Pick(),Pick(nil),Pick(a),Len(a)',pick.replace('a==nil','nil==a')),
'single-equals':main('local a:={1,2}\n? Pick(),Pick(nil),Pick(a),Len(a)',pick.replace('a==nil','a=nil')),
'nil-ne-operand':main('local a:={1,2}\n? Pick(),Pick(nil),Pick(a),Len(a)',pick.replace('a==nil,{},a','nil!=a,a,{}')),
'double-local':main('local a:={1,2}\n? Pick(),Pick(a),Len(a)',pick.replace('return Len(b)','local c:=IIf(nil==a,{},a)\nreturn Len(b)+Len(c)')),
'count-computation':main('local a:={1,2}\n? Pick(),Pick(a),Len(a)',pick.replace('return Len(b)','return Len(b)*7+Len(b)')),
'count-argument':main('local a:={1,2}\n? Pick(),Pick(a),Len(a)',pick.replace('return Len(b)','return Count(Len(b))')+'function Count(n)\nreturn n+1\n'),
'body-loop':main('local a:={1,2}\n? Pick(),Pick(a),Len(a)',pick.replace('local b:=','local i,n:=0\nlocal b:=').replace('return Len(b)','for i:=1 to 5\nn+=Len(b)\nnext\nreturn n')),
'body-if':main('local a:={1,2}\n? Pick(),Pick(a),Len(a)',pick.replace('return Len(b)','if Len(b)==0\nreturn 8\nendif\nreturn Len(b)')),
'extra-scalar-param':main('local a:={1,2}\n? Pick(nil,3),Pick(a,4),Len(a)',pick.replace('Pick(a)','Pick(a,n)').replace('return Len(b)','return Len(b)+n')),
'multiple-optional':main('local a:={1,2},b:={3}\n? Pick(),Pick(a),Pick(a,b),Pick(nil,b),Len(a),Len(b)','function Pick(a,c)\nlocal b:=IIf(a==nil,{},a),d:=IIf(c==nil,{},c)\nreturn Len(b)*10+Len(d)\n'),
'left-to-right':main('local a:={1,2}\n? Pick(a,Effect()),Len(a)',pick.replace('Pick(a)','Pick(a,n)').replace('return Len(b)','return Len(b)+n')+'function Effect()\nOutStd("once",Chr(10))\nreturn 3\n'),
'function-order':main('local a:={1,2}\n? Pick(),Pick(a),Len(a)','')+pick,
'user-name-br':main('local a:={1,2}\n? Pick__brave(),Pick__brave(a),Len(a)',pick.replace('Pick','Pick__brave')),
}
if a.external_p05:programs['external-p05-unmodified']=Path(a.external_p05).read_text()
for name,s in programs.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(s);oe=w/'oracle';ob=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(oe)],w,'oracle-build');assert ob[0]==0 and not ob[3],(name,ob);osh=h(oe);oracle=run([oe],w,'oracle-run');oe.unlink();assert oracle[0]==0 and not oracle[3],(name,oracle)
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
  e=w/mode;b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,mode+'-build');row=dict(name=name,mode=mode,source_sha256=h(src),oracle_binary_sha256=osh,build_rc=b[0],timeout=b[3],exact=False)
  if b[0]==0 and not b[3]:
   row['binary_sha256']=h(e);r=run([e],w,mode+'-run');row.update(run_rc=r[0],timeout=r[3],exact=not r[3] and r[:3]==oracle[:3]);e.unlink()
  rows.append(row);print(name,mode,row['exact'],flush=True)
 if a.baseline:
  e=w/'base';b=run([a.baseline,src,e,'--target=linux'],w,'base-build');assert not e.exists();rows.append(dict(name=name,mode='baseline-compile',build_rc=b[0],timeout=b[3],source_sha256=h(src)));assert b[0]==1 and not b[3],(name,b)
 report=dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline) if a.baseline else None,runner_sha256=h(__file__),scope='Exact rc/stdout/stderr against external Harbour; no normalization. Baseline rows are build rejection checks, not functional wrongness. Instrumentation enabled on native candidate only; programs do not read counters.',rows=rows)
 (out/'results.json').write_text(json.dumps(report,indent=2))
assert all(x.get('exact',True) for x in rows)
print('PASS',sum('exact' in x for x in rows))

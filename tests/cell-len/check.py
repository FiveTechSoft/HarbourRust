#!/usr/bin/env python3
"""Own MIT bounded received-array element LEN observer. External Harbour oracle."""
from pathlib import Path
import argparse,hashlib,json,os,signal,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--baseline');ap.add_argument('--hbmk2',required=True);ap.add_argument('--output',required=True);ap.add_argument('--external-p10');a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label,timeout=15):
 p=subprocess.Popen(list(map(str,cmd)),cwd=w,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=p.communicate(timeout=timeout);timed=False
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate();timed=True
 for k,v in [('stdout',so),('stderr',se),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p.returncode,so,se,timed
leaf='function Count(c)\nreturn Len(c)\n'
loop='function Sum(a)\nlocal i,n:=0\nfor i:=1 to Len(a)\nn+=Count(a[i])\nnext\nreturn n\n'
def main(body,defs=leaf+loop):return defs+'function Main()\n'+body+'\nreturn nil\n'
programs={
'strings':main('local a:={}\nAAdd(a,"one")\nAAdd(a,"four")\n? Sum(a)'),
'empty':main('local a:={}\n? Sum(a),Len(a)'),
'strings-reuse':main('local a:={}\nAAdd(a,"one")\n? Sum(a),Len(a),a[1],Sum(a),a[1]'),
'empty-string':main('local a:={}\nAAdd(a,"")\nAAdd(a,"four")\n? Sum(a),a[1]'),
'owned-string':main('local a:={}\nAAdd(a,Upper("one"))\n? Sum(a),a[1]'),
'fixed-strings':main('local a:={"one","four",""}\n? Sum(a),a[2]'),
'nested-two':main('local a:={{1,2},{3}}\n? Sum(a),Len(a),Len(a[1])'),
'nested-three':main('local a:={{{1,2},{3}},{{4}}}\n? Sum(a),Len(a[1])'),
'nested-four':main('local a:=Array(2,1,1,2)\n? Sum(a),Len(a[1])'),
'nested-empty':main('local a:={{},{1,2},{}}\n? Sum(a),Len(a[1])'),
'lazy-empty':main('local a:={}\n? Sum(a)',leaf+loop.replace('Count(a[i])','Count(a[Effect()])')+'function Effect()\nOutStd("must-not-run",Chr(10))\nreturn 1\n'),
'index-effect':main('local a:={}\nAAdd(a,"one")\n? Sum(a)',leaf+'function Sum(a)\nreturn Count(a[Effect()])\nfunction Effect()\nOutStd("once",Chr(10))\nreturn 1\n'),
'repeated-cell':main('local a:={}\nAAdd(a,"one")\n? Sum(a)',leaf+'function Sum(a)\nreturn Count(a[1])+Count(a[1])\n'),
'lateral-headers':main('local a:={}\nAAdd(a,"one")\nAAdd(a,"four")\n? Sum(a)',leaf+'function Sum(a)\nreturn Mix(Count(a[1]),Count(a[2]))\nfunction Mix(n,m)\nreturn n*10+m\n'),
'whole-and-cell':main('local a:={}\nAAdd(a,"one")\n? Count(a),Sum(a),Count(a),Len(a)'),
'callee-order':main('local a:={}\nAAdd(a,"one")\n? Sum(a)',loop+leaf),
'br-name':main('local a:={}\nAAdd(a,"one")\n? Sum(a)',(leaf+loop).replace('Count','Count__brave')),
'index-local':main('local a:={}\nAAdd(a,"one")\n? Sum(a)',leaf+'function Sum(a)\nlocal j:=1\nreturn Count(a[j])\n'),
'view-forward':main('local a:={}\nAAdd(a,"one")\n? Relay(a),a[1]',leaf+loop+'function Relay(a)\nreturn Sum(a)\n'),
'classified':main('local a:={}\nAAdd(a,"one")\n? Sum(a)',leaf+loop.replace('n+=Count(a[i])','? ValType(a[i])\nn+=Count(a[i])')),
'repeat-grow':main('local a:={},i\nAAdd(a,"one")\nfor i:=1 to 41\n? Sum(a),Len(a)\nAAdd(a,"two")\nnext\n? Sum(a),a[1]'),
'cache-reuse':main('local a:={},i,s\nAAdd(a,Upper("owned"))\nfor i:=1 to 101\n? Sum(a)\ns:=Upper("BAD-VALUE-BAD-VALUE")\nnext\n? a[1],Sum(a)'),
'different-roots':main('local a:={"one"},b:={"four","two"}\n? Sum(a),Sum(b),a[1],b[1]'),
'output-discard':main('local a:={"one"}\nSum(a)\n? a[1],Sum(a)'),
}
if a.external_p10:programs['external-p10-unmodified']=Path(a.external_p10).read_text()
for name,s in programs.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(s);e=w/'oracle';b=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(e)],w,'oracle-build');assert b[0]==0 and not b[3],(name,b);osh=h(e);oracle=run([e],w,'oracle-run');e.unlink();assert oracle[0]==0 and not oracle[3],(name,oracle)
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
  e=w/mode;b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,mode+'-build');row=dict(name=name,mode=mode,source_sha256=h(src),oracle_binary_sha256=osh,build_rc=b[0],timeout=b[3],exact=False)
  if b[0]==0 and not b[3]:
   row['binary_sha256']=h(e);r=run([e],w,mode+'-run');row.update(run_rc=r[0],timeout=r[3],exact=not r[3] and r[:3]==oracle[:3]);e.unlink()
  rows.append(row);print(name,mode,row['exact'],flush=True)
 if a.baseline:
  e=w/'base';b=run([a.baseline,src,e,'--target=linux'],w,'base-build');row=dict(name=name,mode='baseline',source_sha256=h(src),build_rc=b[0],timeout=b[3])
  if b[0]==0 and not b[3]:row['binary_sha256']=h(e);r=run([e],w,'base-run');row.update(run_rc=r[0],timeout=r[3],exact=r[:3]==oracle[:3]);e.unlink()
  rows.append(row)
 (out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline) if a.baseline else None,runner_sha256=h(__file__),scope='Exact rc/stdout/stderr external Harbour comparison. Baseline build failures are not runtime wrongness. Five Linux instrumented modes, no native PE/Mac claim.',rows=rows),indent=2))
assert all(x.get('exact',False) for x in rows if x['mode']!='baseline'),[x for x in rows if x['mode']!='baseline' and not x.get('exact')]
print('PASS',sum(x['mode']!='baseline' for x in rows))

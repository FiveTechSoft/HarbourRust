#!/usr/bin/env python3
"""Own MIT typed concat output/order gate, external Harbour executable oracle."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,signal
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 q=subprocess.Popen(list(map(str,cmd)),cwd=w,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=q.communicate(timeout=15);timed=False
 except subprocess.TimeoutExpired:os.killpg(q.pid,signal.SIGKILL);so,se=q.communicate();timed=True
 for ext,v in [('stdout',so),('stderr',se),('rc',str(q.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return q.returncode,so,se,timed
def main(s,defs=''):return defs+'function Main()\n'+s+'\nreturn nil\n'
programs={
'upper':main('? Upper("ab")+Upper("cd")'),
'nested-right':main('? Upper("a")+(Upper("b")+Upper("c"))'),
'nested-left':main('? (Upper("a")+Upper("b"))+Upper("c")'),
'nested-both':main('? (Upper("a")+Upper("b"))+(Upper("c")+Upper("d"))'),
'owners':main('local s:=Upper("ab"),t:=Upper("cd")\n? Upper("x")+t,s+t,s,t,Upper("x")+Upper("y"),s,t'),
'empty':main('? Upper("")+Upper(""),Upper("x")+Upper(""),Upper("")+Upper("y")'),
'embedded-nul':main('? Upper("a")+(Chr(0)+Upper("b"))'),
'call-order':main('? LeftSide()+RightSide()','function LeftSide()\nOutStd("left",Chr(10))\nreturn Upper("a")\nfunction RightSide()\nOutStd("right",Chr(10))\nreturn Upper("b")\n'),
'calls-reused':main('local a:=LeftSide(),b:=RightSide()\n? Upper("x")+b,a,b','function LeftSide()\nOutStd("left",Chr(10))\nreturn Upper("a")\nfunction RightSide()\nOutStd("right",Chr(10))\nreturn Upper("b")\n'),
'sequence-left':main('? (Upper("x"),Upper("a"))+Upper("b")'),
'sequence-right':main('? Upper("a")+(Upper("x"),Upper("b"))'),
'index-rhs':main('local a:={"bc"}\n? Upper("a")+a[1]'),
'hash-rhs':main('local h:={"k"=>"bc"}\n? Upper("a")+h["k"]'),
'materialized':main('local s:=Upper("a")+Upper("b")\n? s,s'),
'assign-root':main('local s:="",i\nfor i:=1 to 17\ns:=Upper("a")+Upper("b")\nnext\n? s'),
'array-value':main('local a:={}\nAAdd(a,Upper("a")+Upper("b"))\n? a[1]'),
'outstd':main('OutStd(Upper("a")+Upper("b"))'),
'numeric-control':main('local n:=7\n? n+2,n*2,n-2'),
}
for name,text in programs.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(text);e=w/'oracle';b=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(e)],w,'oracle-build');assert b[0]==0 and not b[3],(name,b);bs=h(e);oq=run([e],w,'oracle-run');e.unlink();assert oq[0]==0 and not oq[3],name
 for mode,flags in [('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]:
  e=w/mode;b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,mode+'-build');row=dict(name=name,mode=mode,source_sha256=h(src),oracle_binary_sha256=bs,build_rc=b[0],exact=False)
  if b[0]==0 and not b[3]:row['binary_sha256']=h(e);q=run([e],w,mode+'-run');row.update(run_rc=q[0],exact=not q[3] and q[:3]==oq[:3]);e.unlink()
  rows.append(row);print(name,mode,row['exact'],flush=True)
 e=w/'base';b=run([a.baseline,src,e,'--target=linux'],w,'base-build');row=dict(name=name,mode='base',source_sha256=h(src),build_rc=b[0],exact=False)
 if b[0]==0 and not b[3]:row['binary_sha256']=h(e);q=run([e],w,'base-run');row.update(run_rc=q[0],exact=not q[3] and q[:3]==oq[:3]);e.unlink()
 rows.append(row)
 (out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline),runner_sha256=h(__file__),scope='Exact rc/stdout/stderr external Harbour for normal output/order;fivemodesfinalplusbaseline. No memory parity or exceptiondialogclaim.',rows=rows),indent=2))
assert all(r['exact'] for r in rows),[r for r in rows if not r['exact']]
print('PASS',len(rows))

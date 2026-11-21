from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser()
for n in ['compiler','baseline','output']:p.add_argument('--'+n,type=Path,required=True)
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all',HBC_MINGW_LIB='/tmp/toolchain/mingwroot/usr/x86_64-w64-mingw32/lib');rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,tag):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=20)
 for ext,data in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(tag+'.'+ext)).write_bytes(data)
 return q
for name,c in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=a.output/name;w.mkdir();src=w/'p.prg';src.write_text(c['helpers']+'function Cycle(n)\nlocal i,result,caught:=0\nfor i:=1 to n\nTRY\n'+c['call']+'\nCATCH\ncaught++\nEND\nnext\nreturn caught\nfunction Main()\nlocal b,n\nCycle(3)\nb:=hb_memcheck()\nn:=Cycle('+str(c['count'])+')\n? n,hb_memcheck()-b\nreturn nil\n');rr={}
 for label,cc in [('base',a.baseline),('candidate',a.compiler)]:
  for target in ['linux','windows']:
   for mode,flags in [('int',[]),('ext',['--external-as'])]:
    tag=label+'-'+target+'-'+mode;e=w/(tag+('.exe' if target=='windows' else ''));b=run([cc,src,e,'--target='+target,'--instrument',*flags],w,tag+'-build');assert b.returncode==0,(name,tag,b.stderr);bh=h(e);q=run((['wine'] if target=='windows' else [])+[e],w,tag+'-run');e.unlink();assert q.returncode==0 and not q.stderr,(name,tag,q);values=list(map(int,q.stdout.split()));assert values[0]==c['caught'],(name,tag,values)
    if label=='candidate':assert values[1]==0,(name,tag,values)
    elif c['baseline_leak']:assert values[1]>0,(name,tag,values)
    rr[tag]=dict(build_rc=0,run_rc=q.returncode,binary_sha256=bh,caught=values[0],pending=values[1])
 rows.append(dict(name=name,source_sha256=h(src),results=rr));print(name,'PASS',flush=True)
(a.output/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline),runner_sha256=h(Path(__file__)),scope='Own bounded frame-unwind bank3warmup,113calls or5x270depth,2targetsLinuxnative/PEWine xint/ext xbase/candidate;counted catches and0pending required. Not Harbour memory equivalence.',rows=rows),indent=2))

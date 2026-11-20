#!/usr/bin/env python3
"""Own MIT explicit scalar-only limit, not Harbour result parity."""
from pathlib import Path
import argparse,subprocess,hashlib,json,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);message=b'Limit: hb_defaultValue supports scalar values only in this increment\n'
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label,merged=False):
 r=subprocess.run(list(map(str,cmd)),env=env,capture_output=not merged,stdout=subprocess.PIPE if merged else None,stderr=subprocess.STDOUT if merged else None,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr or b''),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
for side in ['first','second']:
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  for merged in [False,True]:
   w=out/(side+'-'+mode+('-merged' if merged else '-separate'));w.mkdir();src=w/'p.prg';expr='hb_defaultValue(x,Flag())' if side=='first' else 'hb_defaultValue(Flag(),x)';src.write_text('function Flag()\nOutStd("right",Chr(10))\nreturn 7\nfunction Main()\nlocal x\nx:={1}\nOutStd("left",Chr(10))\nOutStd('+expr+',Chr(10))\nreturn nil\n')
   results={}
   for label,cmd in [('candidate',[a.compiler,src,w/'candidate','--target=linux',*flags]),('oracle',[a.hbmk2,src,'-quiet','-w0','-gtstd','-o'+str(w/'oracle')])]:
    b=run(cmd,w,label+'-build');assert b.returncode==0,(label,b.stderr);r=run([w/label],w,label+'-run',merged);results[label]=dict(build_rc=b.returncode,run_rc=r.returncode,binary_sha256=h(w/label));(w/label).unlink()
   raw=(w/'candidate-run.stdout').read_bytes();assert results['candidate']['run_rc']==1 and raw.startswith(b'left \nright \n'+message) and b'NIL used as a number' not in raw
   assert results['oracle']['run_rc']==0
   rows.append(dict(side=side,mode=mode,merged=merged,source_sha256=h(src),ok=True,results=results))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Dyn-held array in either operand: both evaluation effects precede explicit fatal scalar limit. Separate/merged streams, int/ext. Harbour runs successfully, so this is a compiler limit, NOT oracle equality or catchable error parity.',rows=rows),indent=2));print(len(rows),'explicit limits pass')

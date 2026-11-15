#!/usr/bin/env python3
"""Linux-only fresh Harbour -mt checks, no instrumented-thread claim."""
import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(exist_ok=False);root=pathlib.Path(__file__).resolve().parents[2];rows=[]
for n in ['thread','broadcast','data-thread']:
 src=root/('tests/dyn-heap/'+n+'.prg');outs=[]
 for mode,c in [('harbour',[a.hbmk2,'-quiet','-gtstd','-mt',str(src),'-o'+str(r/'oracle')]),('dyn',[a.compiler,str(src),str(r/'mine')])]:
  q=subprocess.run(c,capture_output=True);(r/(n+'-'+mode+'.build')).write_bytes(q.stdout+q.stderr);assert q.returncode==0,q.stderr
  exe=r/('oracle' if mode=='harbour' else 'mine');q=subprocess.run([exe],capture_output=True,timeout=30);exe.unlink();(r/(n+'-'+mode+'.stdout')).write_bytes(q.stdout);(r/(n+'-'+mode+'.stderr')).write_bytes(q.stderr);assert q.returncode==0 and not q.stderr;outs.append(q.stdout)
 assert outs[0]==outs[1],(n,outs);rows.append(dict(case=n,exact=True,instrumented=False))
(r/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(len(rows),'Linux normal threaded fresh oracle PASS')

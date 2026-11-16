from pathlib import Path
import subprocess,time,statistics,json
R=Path(__file__).resolve().parents[3];E=R/'evidence/p1-bench';E.mkdir(parents=True,exist_ok=True);core='/tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185';rows=[]
for name,expr in [('upper','Upper(s)'),('lower','Lower(s)'),('numeric','n+1')]:
 d=E/name;d.mkdir(exist_ok=True);n=50000;source='function Main()\nCheck()\nOutStd("mem",hb_memcheck(),Chr(10))\nreturn nil\nfunction Check()\nlocal i:=0,result,text:='+repr(expr)+'\nprivate s:="abcdefghijklmnopqrstuvwxyz",n:=3\nfor i:=1 to '+str(n)+'\nresult:=&(text)\nnext\nOutStd("value",result,Chr(10))\nreturn nil\n';(d/'case.prg').write_text(source);(d/'oracle.prg').write_text(source.replace('hb_memcheck()','0')+'\nREQUEST RIGHT\n');subprocess.run(['/tmp/hr-p1-hbc',str(d/'case.prg'),str(d/'product'),'--instrument'],check=True,capture_output=True);subprocess.run([core+'/bin/linux/gcc/hbmk2','oracle.prg','-ooracle','-gtstd'],cwd=d,check=True,capture_output=True);times={};outputs={}
 for label in ['product','oracle']:
  samples=[]
  for i in range(6):
   t=time.perf_counter_ns();p=subprocess.run([str(d/label)],capture_output=True,timeout=45);dt=time.perf_counter_ns()-t;assert not p.returncode and not p.stderr;samples.append(dt);outputs[label]=p.stdout
  times[label]=dict(samples_ns=samples,median_ns=statistics.median(samples[1:]),median_ns_per_eval=statistics.median(samples[1:])/n)
  (d/(label+'.stdout')).write_bytes(p.stdout);(d/label).unlink()
 assert outputs['product']==outputs['oracle'];rows.append(dict(name=name,expr=expr,iterations=n,includes_process_startup=True,timing=times,ratio_product_over_oracle=times['product']['median_ns']/times['oracle']['median_ns']));print(name,rows[-1],flush=True)
(E/'results.json').write_text(json.dumps(rows,indent=2)+'\n')

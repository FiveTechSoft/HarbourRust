#!/usr/bin/env python3
from pathlib import Path
import subprocess,json,time,argparse,hashlib,sys
ap=argparse.ArgumentParser(description='Full manifest: compare diagnostics/emission on both targets and raw Linux executions against BASE. Not an oracle comparison.')
ap.add_argument('--base',required=True);ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True)
a=ap.parse_args();root=Path(__file__).resolve().parents[2];ev=Path(a.output).resolve();ev.mkdir(parents=True,exist_ok=False)
base=Path(a.base).resolve();compiler=Path(a.compiler).resolve()
(ev/'identity.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [base,compiler,root/'tests/manifest.txt']},indent=2))
results=[];counts={}
for idx,line in enumerate((root/'tests/manifest.txt').read_text().splitlines()):
 if not line.strip() or line.startswith('#'):continue
 fields=line.split();kind,src=fields[:2]
 w=ev/('%04d'%idx);w.mkdir(exist_ok=True)
 d={'index':idx,'kind':kind,'source':src,'targets':{}}
 for target in ['linux','windows']:
  states=[];asms=[]
  for label,compiler in [('base',base),('candidate',compiler)]:
   asm=w/(label+'.'+target+'.s')
   cmd=[compiler,src,asm,'--target='+target,'--instrument','-I','tests']
   p=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=20)
   for k,v in [('stderr',p.stderr),('stdout',p.stdout),('rc',str(p.returncode).encode())]:(w/(label+'.'+target+'.compile.'+k)).write_bytes(v)
   states.append((p.returncode,p.stderr));asms.append(asm)
  compile_same=states[0]==states[1]
  emit_same=all(p.exists() for p in asms) and asms[0].read_bytes()==asms[1].read_bytes() if states[0][0]==states[1][0]==0 else None
  dt={'compile_same':compile_same,'base_rc':states[0][0],'candidate_rc':states[1][0],'emission_same':emit_same}
  if target=='linux' and states[0][0]==states[1][0]==0 and kind!='neg':
   runs=[]
   for label,asm in zip(['base','candidate'],asms):
    obj=w/(label+'.o');exe=w/(label+'.x')
    pa=subprocess.run(['as','-o',str(obj),str(asm)],capture_output=True)
    pl=subprocess.run(['ld','-o',str(exe),str(obj)],capture_output=True) if pa.returncode==0 else pa
    (w/(label+'.link.stderr')).write_bytes(pl.stderr)
    if pl.returncode:runs.append(('build',pl.returncode,pl.stderr));continue
    try:
     p=subprocess.run([str(exe)],capture_output=True,timeout=8)
     rr=(p.returncode,p.stdout,p.stderr)
    except subprocess.TimeoutExpired as e:rr=(124,e.stdout or b'',e.stderr or b'')
    for k,v in [('stdout',rr[1]),('stderr',rr[2]),('rc',str(rr[0]).encode())]:(w/(label+'.run.'+k)).write_bytes(v)
    runs.append(rr)
   dt['raw_same']=runs[0]==runs[1]
  d['targets'][target]=dt
 results.append(d)
 if len(results)%150==0:print(len(results),'checked',flush=True)
 (ev/'results.json').write_text(json.dumps(results,indent=2))
print('TOTAL',len(results),'compile differences',sum(not t['compile_same'] for r in results for t in r['targets'].values()),'emission changes',sum(t['emission_same'] is False for r in results for t in r['targets'].values()),'raw differences',sum(t.get('raw_same') is False for r in results for t in r['targets'].values()),flush=True)

sys.exit(0 if all(t['compile_same'] and t.get('raw_same',True) for r in results for t in r['targets'].values()) else 1)

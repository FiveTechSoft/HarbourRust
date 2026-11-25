#!/usr/bin/env python3
"""Own MIT current-compiler replay, fresh evidence after environment loss."""
from pathlib import Path
import argparse,subprocess,hashlib,json,os,sys
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','spec-root','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(Path(a.compiler).resolve());hb=str(Path(a.hbmk2).resolve());sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import emit_delta
suites=['asciiupper-linux','dirsepadd-linux','hextonum-linux','base64-linux','strtohex-linux','osdrive-linux'];rows=[]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label):
 cmd=list(map(str,cmd));(w/(label+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(w)),indent=2)+'\n');z=subprocess.run(cmd,cwd=w,capture_output=True,timeout=60,stdin=subprocess.DEVNULL)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return z
for suite in suites:
 cases=json.loads((root/'tests'/suite/'cases.json').read_text())
 for name,text in cases.items():
  w=out/(suite+'-'+name);w.mkdir();src=w/'input.prg';src.write_text(text);oracle=w/'oracle.prg';adapted=text.replace('TRY\n','BEGIN SEQUENCE WITH {|o| Break(o)}\n').replace('CATCH e\n','RECOVER USING e\n').replace('END\n','END SEQUENCE\n');oracle.write_text(adapted)
  z=run([hb,oracle,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert z.returncode==0,(suite,name,z.stderr)
  z=run([w/'oracle'],w,'oracle-run');assert z.returncode==0 and not z.stderr;want=z.stdout;(w/'oracle').unlink()
  for mode,flags in [('native',[]),('external',['--external-as'])]:
   z=run([cc,src,w/mode,'--instrument',*flags],w,mode+'-build');assert z.returncode==0,(suite,name,z.stderr)
   z=run([w/mode],w,mode+'-run');assert(z.returncode,z.stdout,z.stderr)==(0,want,b''),(suite,name,mode);(w/mode).unlink();rows.append(dict(suite=suite,name=name,kind='exact-Harbour',mode=mode,source_sha256=sha(src),oracle_sha256=sha(oracle),oracle_adapted=adapted!=text))
  d=w/'delta';d.mkdir();(d/'commands.json').write_text(json.dumps(dict(cwd=str(d),argv=[[cc,str(src),str(d/'checked.s'),'--target=linux','--instrument','--no-prune'],['as','--64','-o',str(d/'checked.o'),str(d/'checked.s')],['ld','-s','-o',str(d/'checked'),str(d/'checked.o')],[str(d/'checked')]]),indent=2)+'\n');bal=emit_delta(cc,os.environ,src,d,want);assert bal['state_ok']and bal['delta']==0,(suite,name,bal);rows.append(dict(suite=suite,name=name,kind='strict-final-balance',**bal))
  for f in d.iterdir():
   if f.suffix in ['.s','.o']or f.name=='checked':f.unlink()
 print(suite,len(cases),'complete',flush=True)
(out/'results.json').write_text(json.dumps(dict(fresh_postreset=True,compiler_sha256=sha(cc),hbmk2_sha256=sha(hb),oracle_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=a.spec_root,text=True).strip(),fixture_sha256={s:sha(root/'tests'/s/'cases.json')for s in suites},runner_sha256=sha(__file__),guard_sha256=sha(root/'tests/trycatch-linux/memdelta_guard.py'),rows=rows),indent=2)+'\n');print('PASS',len(rows))

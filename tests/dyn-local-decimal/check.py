from pathlib import Path
import json,subprocess,hashlib,argparse,os
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--baseline',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--output',required=True);ap.add_argument('--external-p01');ap.add_argument('--external-p02');a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(exist_ok=False);cc=Path(a.compiler);hb=a.hbmk2;rows=[];env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'])
programs={
'copy-local-add':'function F(x)\nlocal n:=x\nn:=n+0.5\nreturn n\nfunction Main()\n? F(2),F(1.25)\nreturn nil\n',
'direct-add':'function F(x)\nreturn x+0.5\nfunction Main()\n? F(2),F(1.25)\nreturn nil\n',
'copy-local-store-constant':'function F(x)\nlocal n:=x\nn:=0.5\nreturn n\nfunction Main()\n? F(2),F(1.25)\nreturn nil\n',
'dyn-local-explicit':'function F(x)\nlocal n\nn:=x\nn:=n+0.5\nreturn n\nfunction Main()\n? F(2),F(1.25)\nreturn nil\n',
'copy-local-add-intonly':'function F(x)\nlocal n:=x\nn:=n+0.5\nreturn n\nfunction Main()\n? F(2)\nreturn nil\n',
'copy-local-add-floatonly':'function F(x)\nlocal n:=x\nn:=n+0.5\nreturn n\nfunction Main()\n? F(1.25)\nreturn nil\n',
'copy-local-multiply':'function F(x)\nlocal n:=x\nn:=n*0.1\nreturn n\nfunction Main()\n? F(20),F(3.5)\nreturn nil\n',
'direct-multiply':'function F(x)\nreturn x*0.1\nfunction Main()\n? F(20),F(3.5)\nreturn nil\n',

'copy-local-plus-return-original':'function F(x)\nlocal n:=x\n? n+0.5\nreturn n\nfunction Main()\n? F(2),F(1.25)\nreturn nil\n',
}
for op,name in [('+','add'),('-','subtract'),('*','multiply')]:
 for side,expr in [('right','n'+op+'0.25'),('left','0.25'+op+'n')]:
  programs[name+'-'+side]='function F(x)\nlocal n:=x\nlocal old:=n\nn:='+expr+'\n? old,n\nreturn n\nfunction Main()\n? F(2),F(1.25)\nreturn nil\n'
programs['branches']='function F(x,b)\nlocal n:=x\nif b\nn:=n+0.5\nendif\nreturn n\nfunction Main()\n? F(2,.T.),F(2,.F.),F(1.25,.T.),F(1.25,.F.)\nreturn nil\n'
programs['once']='function TouchN(x)\n? "one"\nreturn x\nfunction F(x)\nlocal n:=TouchN(x)\nn:=n+0.5\nreturn n\nfunction Main()\n? F(2),F(1.25)\nreturn nil\n'
if a.external_p01:programs['external-p01-unmodified']=Path(a.external_p01).read_text()
if a.external_p02:programs['external-p02-unmodified']=Path(a.external_p02).read_text()
for name,text in programs.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(text);row=dict(name=name,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),results={})
 for label,cmd in [('base',[a.baseline,str(src),str(w/'base'),'--target=linux']),('int',[str(cc),str(src),str(w/'int'),'--target=linux']),('ext',[str(cc),str(src),str(w/'ext'),'--target=linux','--external-as']),('oracle',[hb,str(src),'-quiet','-w0','-gtstd','-o'+str(w/'oracle')])]:
  b=subprocess.run(cmd,capture_output=True,timeout=30,env=env)
  for ext,v in [('stdout',b.stdout),('stderr',b.stderr),('rc',str(b.returncode).encode())]:(w/(label+'.build.'+ext)).write_bytes(v)
  rr=dict(build_rc=b.returncode,diagnostic=b.stderr.decode().strip())
  if not b.returncode:
   q=subprocess.run([w/label],capture_output=True,timeout=5)
   for ext,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'.run.'+ext)).write_bytes(v)
   rr.update(run_rc=q.returncode,binary_sha256=hashlib.sha256((w/label).read_bytes()).hexdigest());(w/label).unlink()
  row['results'][label]=rr
 assert row['results']['oracle']['build_rc']==0,name
 for label in ['int','ext']:
  assert row['results'][label]['build_rc']==0,(name,label,row['results'][label])
  assert all((w/(label+'.run.'+ext)).read_bytes()==(w/('oracle.run.'+ext)).read_bytes() for ext in ['rc','stdout','stderr']),(name,label)
 rows.append(row);print(name,'EXACT int/ext',flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),baseline_sha256=hashlib.sha256(Path(a.baseline).read_bytes()).hexdigest(),scope='Own independent decimal-store probes plus optional unchanged external PRGs. Two assembler modes exact rc/stdout/stderr against external Harbour. Base build rejection kept separate.',rows=rows),indent=2))

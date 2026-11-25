from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
base='procedure Main()\n? hb_MilliSeconds()\nreturn\n'
cases=[('windows',base,['--target=windows']),('macho',base,['--target=macho']),('macho-arm64',base,['--target=macho-arm64']),('llvm',base,['--experimental-llvm']),('threads','function Worker()\nreturn 1\n'+base.replace('? hb_', 'local t:=hb_threadStart(@Worker())\n? hb_'),[]),('extra-literal',base.replace('Seconds()','Seconds(1)'),[]),('extra-call',base.replace('Seconds()','Seconds(Unknown())'),[]),('macro','procedure Main()\nlocal c:="hb_MilliSeconds()"\n? &c\n? hb_MilliSeconds()\nreturn\n',[])]
for n,text,flags in cases:
 w=out/n;w.mkdir();src=w/'input.prg';src.write_text(text);cmd=[cc,str(src),str(w/'bad'),*flags];z=subprocess.run(cmd,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/('build.'+k)).write_bytes(b)
 (w/'command.json').write_text(json.dumps(dict(argv=cmd,cwd=str(Path.cwd())))+'\n');assert z.returncode==1 and not(w/'bad').exists(),(n,z.stderr);rows.append(dict(name=n,pass_=True))
# The existing reserved-name policy remains an explicit boundary.
w=out/'override';w.mkdir();src=w/'input.prg';src.write_text('function hb_MilliSeconds()\nreturn 77\nprocedure Main()\n? hb_MilliSeconds()\nreturn\n');cmd=[cc,str(src),str(w/'bad')];z=subprocess.run(cmd,capture_output=True);assert z.returncode==1 and b'reserved' in z.stderr,z.stderr
(w/'command.json').write_text(json.dumps(dict(argv=cmd,cwd=str(Path.cwd())))+'\n')
for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/('build.'+k)).write_bytes(b)
rows.append(dict(name='override-reserved',pass_=True))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS limits',len(rows))

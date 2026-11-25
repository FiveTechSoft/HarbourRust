from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
base='procedure Main()\n? hb_DiskSpace("/tmp",0)\nreturn\n'
cases=[('windows',base,['--target=windows']),('macho',base,['--target=macho']),('macho-arm64',base,['--target=macho-arm64']),('llvm',base,['--experimental-llvm']),('threads','function Worker()\nreturn 1\n'+base.replace('? hb_', 'local t:=hb_threadStart(@Worker())\n? hb_'),[]),('noargs',base.replace('("/tmp",0)','()'),[]),('selector',base.replace(',0)',',4)'),[]),('dynamic-selector',base.replace('? hb_','local n:=0\n? hb_').replace(',0)',',n)'),[]),('temporary',base.replace('"/tmp"','Upper("/tmp")'),[]),('dynpath',base.replace('? hb_','local c\nc:="/tmp"\n? hb_').replace('("/tmp",0)','(c,0)'),[])]
for n,text,flags in cases:
 w=out/n;w.mkdir();src=w/'input.prg';src.write_text(text);cmd=[cc,str(src),str(w/'bad'),*flags];z=subprocess.run(cmd,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/('build.'+k)).write_bytes(b)
 (w/'command.json').write_text(json.dumps(dict(argv=cmd,cwd=str(Path.cwd())))+'\n');assert z.returncode==1 and not(w/'bad').exists(),(n,z.stderr);rows.append(dict(name=n,pass_=True))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS limits',len(rows))

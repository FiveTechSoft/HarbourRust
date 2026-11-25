from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
def run(cmd,w,tag):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(tag+'.'+k)).write_bytes(b)
 (w/(tag+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(Path.cwd())))+'\n');return z
# Runtime scalar retags admitted, nonstring consumers stop at named boundary.
for n,value in [('nil','NIL'),('int','7'),('double','1.5'),('logical','.T.')]:
 for mode,flags in [('native',[]),('external',['--external-as']),('noescape',['--no-escape-analysis'])]:
  w=out/(n+'-'+mode);w.mkdir();src=w/'input.prg';src.write_text('procedure Main(c)\nc:='+value+'\n? hb_DiskSpace(c,0)\nreturn\n');exe=w/'exe';z=run([cc,src,exe,*flags],w,'build');assert z.returncode==0,(n,z.stderr);z=run([exe],w,'run');assert(z.returncode,z.stdout,z.stderr)==(1,('Limit: hb_DiskSpace scalar Dyn path requires a string value\nCallstack:\n  at main ('+str(src)+':3)\n').encode(),b''),(n,z.returncode,z.stdout,z.stderr);exe.unlink();rows.append(dict(case=n,mode=mode,named_runtime_limit=True))
# Unsupported lifetime shapes remain compiler boundaries.
for n,source in [('date','procedure Main(c)\nc:=CToD("")\n? hb_DiskSpace(c,0)\nreturn\n'),('usercall','function GetPath()\nreturn "/tmp"\nprocedure Main()\nlocal c\nc:=GetPath()\n? hb_DiskSpace(c,0)\nreturn\n'),('array','procedure Main()\nlocal c\nc:={"/tmp"}\n? hb_DiskSpace(c,0)\nreturn\n'),('byref','procedure Use(c)\n? hb_DiskSpace(c,0)\nreturn\nprocedure Main()\nlocal c\nc:="/tmp"\nUse(@c)\nreturn\n'),('shared','procedure Main()\nstatic c\nc:="/tmp"\n? hb_DiskSpace(c,0)\nreturn\n')]:
 w=out/n;w.mkdir();src=w/'input.prg';src.write_text(source);z=run([cc,src,w/'bad'],w,'build');assert z.returncode==1 and not(w/'bad').exists(),(n,z.stderr);rows.append(dict(case=n,compile_boundary=True))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS limits',len(rows))

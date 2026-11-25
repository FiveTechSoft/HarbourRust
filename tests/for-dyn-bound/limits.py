from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();cc=str(Path(a.compiler).resolve());out=Path(a.output);out.mkdir();rows=[]
program='procedure Main()\nlocal n:=0,i\nn:=Val("2.5")\nfor i:=1 to n\n ? i\nnext\nreturn\n'
cases={
'call':program.replace('to n\n','to Val("2.5")\n'),
'numlocal':program.replace('Val("2.5")','2.5'),
'dynamic-step':program.replace('local n:=0,i','local n:=0,i,s:=1').replace('to n\n','to n step s\n'),
'captured':program.replace('for i:=','local b:={||n}\nfor i:='),
'byref':'function Mut(n)\nreturn n\n'+program.replace('for i:=','Mut(@n)\nfor i:='),
}
for name,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--experimental-llvm']),('threads',[])]:
 cases[name]=(program.replace('local n:=0,i','local t:=hb_threadStart(@Worker()),n:=0,i')+'function Worker()\nreturn 1\n'if name=='threads'else program,flags)
for name,v in cases.items():
 text,flags=v if isinstance(v,tuple)else(v,[]);w=out/name;w.mkdir();s=w/'input.prg';s.write_text(text);cmd=[cc,str(s),str(w/'bad'),*flags];z=subprocess.run(cmd,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/('build.'+k)).write_bytes(b)
 (w/'command.json').write_text(json.dumps(dict(argv=cmd,cwd=str(Path.cwd())))+'\n');rows.append(dict(name=name,rc=z.returncode,pass_=z.returncode==1 and not(w/'bad').exists(),source_sha256=hashlib.sha256(s.read_bytes()).hexdigest()));assert rows[-1]['pass_'],(name,z.stderr)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows))

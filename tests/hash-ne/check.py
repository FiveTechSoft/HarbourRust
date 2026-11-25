from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
def run(cmd,w,t):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=root,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(root)))+'\n');return z
sources={'basic':Path(__file__).with_name('basic.prg').read_text(),'pp':'''#define A 4
#xtranslate DIFFERENT(<x>,<y>) => (<x> != <y>)
PROCEDURE Main()
? A#3,A#4
? DIFFERENT(1,2)
? "#define untouched",[x#y]
RETURN
''','precedence':'''PROCEDURE Main()
LOCAL a:=2,b:=3,n:=0
? a+b#5,a*b#6,a#b+1,a#b*1
IF a#b .AND. b#4
 n++
ENDIF
? n
? .NOT.(a#b),!(a#b),!(a#2)
? a # b .OR. b # 3
RETURN
''','date':'''PROCEDURE Main()
? 0d20261125#0d20261126,0d20261125!=0d20261126
? 0d20261125#0d20261125,0d20261125<>0d20261125
? 1.25#1.26,1.25!=1.26,1.25<>1.26
RETURN
'''}
for name,source in sources.items():
 w=out/name;w.mkdir();src=w/'input.prg';src.write_text(source);z=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert z.returncode==0,(name,z.stderr);want=run([w/'oracle'],w,'oracle-run');assert want.returncode==0 and not want.stderr
 for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
  z=run([cc,src,w/mode,*flags],w,mode+'-build');assert z.returncode==0,(name,mode,z.stderr);got=run([w/mode],w,mode+'-run');assert(got.returncode,got.stdout,got.stderr)==(want.returncode,want.stdout,want.stderr),(name,mode,got.stdout,want.stdout);(w/mode).unlink();rows.append(dict(case=name,mode=mode,exact=True))
 (w/'oracle').unlink()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows))

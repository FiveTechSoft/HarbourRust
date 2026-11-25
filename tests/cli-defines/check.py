#!/usr/bin/env python3
"""Own MIT: fresh Harbour vs hbc CLI definitions, plus adapter route."""
from pathlib import Path
import subprocess,json,hashlib,argparse,sys
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();r=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());hb=str(Path(a.hbmk2).resolve());rows=[]
def run(cmd,w,label):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=w,capture_output=True,timeout=60,stdin=subprocess.DEVNULL)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 (w/(label+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(w)),indent=2)+'\n');return z
cases=[('bare',['FOO'],'#ifdef FOO\n? "defined"\n#else\n? "absent"\n#endif\n? FOO\n'),('empty',['FOO='],'#ifdef FOO\n? "defined"\n#endif\n? FOO\n? "ab"\n'),('value',['FOO=42'],'? FOO\n'),('repeat',['FOO=1','FOO=2'],'? FOO\n'),('case',['Foo=7'],'#ifdef FOO\n? "upper"\n#else\n? "not-upper"\n#endif\n? Foo\n'),('source-redefine',['FOO=42'],'#define FOO 9\n? FOO\n'),('source-undef',['FOO=42'],'#undef FOO\n#ifdef FOO\n? "defined"\n#else\n? "absent"\n#endif\n'),('expr',['FOO=(2+3)'],'? FOO*2\n'),('quoted',['FOO="two words"'],'? FOO\n'),('include',['FOO=42'],'#include "sibling.ch"\n? FOO\n')]
for name,defs,body in cases:
 w=out/name;w.mkdir();src=w/'input.prg';src.write_text('FUNCTION Main()\n'+body+'RETURN NIL\n');(w/'sibling.ch').write_text('#ifdef FOO\n#undef FOO\n#define FOO 17\n#endif\n');(w/'input.sha256').write_text(hashlib.sha256(src.read_bytes()).hexdigest()+'  input.prg\n')
 z=run([hb,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')]+['-d'+x for x in defs],w,'oracle-build');assert z.returncode==0,z.stderr
 want=run([w/'oracle'],w,'oracle-run');assert want.returncode==0 and not want.stderr;(w/'oracle').unlink()
 for mode in ['joined-upper','joined-lower','separate','adapter']:
  exe=w/mode
  flags=['-D'+x for x in defs] if mode=='joined-upper' else ['-d'+x for x in defs] if mode=='joined-lower' else [y for x in defs for y in ['-D',x]]
  cmd=[cc,src,exe]+flags if mode!='adapter' else [sys.executable,r/'tools/hbc_hbmk2.py',src,'--hbc',cc,'--hbmk2',hb,'-o',exe]+['-D'+x for x in defs]
  z=run(cmd,w,mode+'-build');assert z.returncode==0,(name,mode,z.stderr)
  z=run([exe],w,mode+'-run');ok=(z.returncode,z.stdout,z.stderr)==(want.returncode,want.stdout,want.stderr);rows.append(dict(case=name,mode=mode,exact=ok));assert ok,(name,mode,z.stdout,want.stdout);exe.unlink()
for i,definition in enumerate(['','9BAD=1','BAD-NAME=1','F(x)=x','BAD=1\n#error x','BAD=1\r#error x','BAD=\0']):
 w=out/('negative'+str(i));w.mkdir();src=w/'input.prg';src.write_text('FUNCTION Main()\n? 1\nRETURN NIL\n');exe=w/'old';exe.write_bytes(b'OLD')
 if '\0' in definition:continue # OS argv cannot carry NUL; Rust method validates it separately.
 z=run([cc,src,exe,'-D'+definition],w,'reject');ok=z.returncode==2 and exe.read_bytes()==b'OLD' and b'-D ' in z.stderr;rows.append(dict(case='negative'+str(i),rejected=ok));assert ok,z.stderr
w=out/'missing';w.mkdir();z=run([cc,'-D'],w,'reject');assert z.returncode==2 and b'-D needs' in z.stderr;rows.append(dict(case='missing',rejected=True))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),hbmk2_sha256=hashlib.sha256(Path(hb).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows),'rows')

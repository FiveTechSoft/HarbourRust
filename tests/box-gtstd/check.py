#!/usr/bin/env python3
"""Original MIT: isolated literal box partial evaluation, external GTSTD oracle."""
import argparse,hashlib,json,pathlib,subprocess
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['compiler','hbmk2','harbour-core','output']:ap.add_argument('--'+k,required=True)
a=ap.parse_args();cc=P(a.compiler).resolve();out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);gate=P(__file__).resolve().parent;core=P(a.harbour_core).resolve();rows=[]
def run(cmd,w,label):
 try:r=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,timeout=30)
 except subprocess.TimeoutExpired as e:r=subprocess.CompletedProcess(cmd,124,e.stdout or b'',e.stderr or b'TIMEOUT')
 for k,d in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(d)
 return r
def add(name,ok,**kw):rows.append(dict(name=name,ok=bool(ok),**kw));print(name,'PASS' if ok else 'FAIL',flush=True)
src=core/'tests/box.prg';inv=json.loads((gate.parents[1]/'corpus/harbour-694428e1-inventory.json').read_text());assert hashlib.sha256(src.read_bytes()).hexdigest()==next(x['sha256'] for x in inv['files'] if x['path']=='tests/box.prg')
for src in sorted((gate/'programs').glob('*.prg'))+[src]:
 w=out/src.stem;w.mkdir();ob=run([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),src],w,'oracle-build');rr=run([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None
 for variant,flags in [('elf-int',[]),('elf-ext',['--external-as'])]:
  b=run([cc,src,w/variant,'--target=linux',*flags,'-I',str(core/'include')],w,'build-'+variant);r=run([w/variant],w,'run-'+variant) if b.returncode==0 else None
  add(src.stem+'-'+variant,rr and r and (rr.returncode,r.returncode,rr.stderr,r.stderr)==(0,0,b'',b'') and rr.stdout==r.stdout,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),external_source=src.parent==core/'tests',build_rc=b.returncode,run_rc=r.returncode if r else None)
w=out/'limits';w.mkdir();body='DispBox(1,1,3,5)';(w/'p.prg').write_text('function main()\n'+body+'\nreturn nil\n')
for name,flags in [('windows',['--target=windows']),('darwin',['--target=macho']),('arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('llvm-no-trace',['--target=linux','--experimental-llvm-no-trace'])]:
 b=run([cc,w/'p.prg',w/name,*flags],w,'build-'+name);add('limit-'+name,b.returncode==1 and b'literal GTSTD boxes are measured only on ordinary Linux' in b.stderr and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
cases={
 'right-edge-space':'function main()\nDispBox(1,1,3,5,"12 45678")\nreturn nil\n',
 'blank-border':'function main()\nDispBox(1,1,3,5,"        ")\nreturn nil\n',
 'trailing-edge':'function main()\nDispBox(1,1,3,5,"1234567 ")\nreturn nil\n',
 'trailing-fill':'function main()\nDispBox(1,1,3,5,"12345678 ")\nreturn nil\n',
 'del-border':'function main()\nDispBox(1,1,3,5,"1234567"+Chr(127))\nreturn nil\n',
 'other-byte':'function main()\nDispBox(1,1,3,5,"1234567"+Chr(255))\nreturn nil\n',

 'mixed':'function main()\n'+body+'\n? "x"\nreturn nil\n',
 'loop':'function main()\nlocal i\nfor i:=1 to 2\n'+body+'\nnext\nreturn nil\n',
 'overlap':'function main()\n'+body+'\nDispBox(3,1,5,5)\nreturn nil\n',
 'reverse':'function main()\nDispBox(5,1,7,5)\n'+body+'\nreturn nil\n',
 'thin':'function main()\nDispBox(1,1,1,5)\nreturn nil\n',
 'last-row':'function main()\nDispBox(22,75,24,79,"123456789")\nreturn nil\n',
 'outside':'function main()\nDispBox(1,1,25,5)\nreturn nil\n',
 'short':'function main()\nDispBox(1,1,3,5,"x")\nreturn nil\n',
 'unknown-glyph':'function main()\nDispBox(1,1,3,5,hb_UTF8ToStrBox("abcdefghé"))\nreturn nil\n',
 'callee':'function Box()\n'+body+'\nreturn nil\nfunction main()\nBox()\nreturn nil\n',
 'variable':'function main()\nlocal x:=1\nDispBox(x,1,3,5)\nreturn nil\n',
 'effect':'function Border()\nreturn "123456789"\nfunction main()\nDispBox(1,1,3,5,Border())\nreturn nil\n',
 'method':'#include "hbclass.ch"\nfunction main()\nlocal o:=T():New()\no:Draw()\nreturn nil\nCREATE CLASS T\nMETHOD Draw()\nENDCLASS\nMETHOD Draw() CLASS T\n'+body+'\nRETURN NIL\n',
}
for name,source in cases.items():
 (w/'args.prg').write_text(source);b=run([cc,w/'args.prg',w/name,'--target=linux','-I',str(core/'include')],w,'build-'+name);add('limit-'+name,b.returncode==1 and b'DispBox' in b.stderr and b'panicked' not in b.stderr and not (w/name).exists(),build_rc=b.returncode)
result=dict(compiler_sha256=hashlib.sha256(cc.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(P(__file__).read_bytes()).hexdigest(),passed=sum(r['ok'] for r in rows),total=len(rows),rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));print(result['passed'],'/',result['total']);raise SystemExit(not all(r['ok'] for r in rows))

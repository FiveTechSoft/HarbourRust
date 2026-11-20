#!/usr/bin/env python3
"""Own MIT integer hash key lifetime and fail-closed boundary controls."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();cc=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),env=env,capture_output=True,timeout=30)
 for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(v)
 return r
for mode,flags in [('int',[]),('ext',['--external-as']),('no-escape',['--no-escape-analysis'])]:
 w=out/mode;w.mkdir();src=w/'p.prg';src.write_bytes(Path(__file__).with_name('memory.prg').read_bytes());b=run([cc,src,w/'p','--target=linux','--instrument',*flags],w,'build');r=run([w/'p'],w,'run') if not b.returncode else None
 row=dict(name=mode,kind='lifetime',source_sha256=h(src),build_rc=b.returncode,ok=bool(r and r.returncode==0 and r.stdout==b'      2000          0 \n' and not r.stderr))
 if r:row['binary_sha256']=h(w/'p');(w/'p').unlink()
 rows.append(row)
program='function Main()\nlocal h:={=>}\nh[10]:=1\n? h[10]\nreturn nil\n'
for name,flags in [('windows',['--target=windows']),('macho',['--target=macho']),('macho-arm64',['--target=macho-arm64']),('llvm',['--target=linux','--experimental-llvm']),('threads',['--target=linux'])]:
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(('function Work()\nreturn 1\n' if name=='threads' else '')+program.replace('function Main()\n','function Main()\n'+('local t:=hb_threadStart(@Work())\n' if name=='threads' else '')));b=run([cc,src,w/'p',*flags],w,'build');rows.append(dict(name=name,kind='profile-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and b'hash keys are strings' in b.stderr and not (w/'p').exists()))
negative={
'variable':'local h:={=>},n:=10\nh[n]:=1\n? h[n]',
'float':'local h:={=>}\nh[10.0]:=1\n? h[10.0]',
'computed':'local h:={=>},n:=10\nh[n+1]:=1',
'hashlit':'local h:={10=>1}\n? h[10]',
'numeric-hset':'local h:={=>}\nhb_HSet(h,10,1)',
'numeric-hdel':'local h:={=>}\nh[10]:=1\nhb_HDel(h,10)',
'numeric-hpos':'local h:={=>}\nh[10]:=1\n? hb_HPos(h,10)',
'enumeration':'local h:={=>}\nh[10]:=1\nlocal keys:=hb_HKeys(h)\n? Len(keys)',
'keyat':'local h:={=>}\nh[10]:=1\n? hb_HKeyAt(h,1)',
'case-mutation':'local h:={=>}\nh[10]:=1\nhb_HSetCaseMatch(h,0)',
'early-enumeration':'local h:={=>}\nlocal keys:=hb_HKeys(h)\n? Len(keys)\nh[10]:=1',
'early-keyat':'local h:={"x"=>1}\n? hb_HKeyAt(h,1)\nh[10]:=1',
'macro-excluded':'local h:={=>},c:="1+2"\n? &(c)\nh[10]:=1',
'logical-key':'local h:={=>}\nh[.T.]:=1',
'date-key':'local h:={=>}\nh[StoD("20260203")]:=1',
}
for name,body in negative.items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text('function Main()\n'+body+'\nreturn nil\n');b=run([cc,src,w/'p','--target=linux'],w,'build');expected=b'Limit: literal integer hash keys' if name in ['enumeration','keyat','case-mutation','early-enumeration','early-keyat'] else b'hash keys are strings';rows.append(dict(name=name,kind='shape-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and expected in b.stderr and not (w/'p').exists()))
for name,tail in [('uncalled-keys','local keys:=hb_HKeys(h)\n? Len(keys)'),('uncalled-keyat','? hb_HKeyAt(h,1)'),('uncalled-case','hb_HSetCaseMatch(h,0)')]:
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text('function Uncalled()\nlocal h:={"x"=>1}\n'+tail+'\nreturn nil\n'+program);b=run([cc,src,w/'p','--target=linux'],w,'build');rows.append(dict(name=name,kind='whole-program-rejection',source_sha256=h(src),build_rc=b.returncode,ok=b.returncode==1 and b'Limit: literal integer hash keys' in b.stderr and not (w/'p').exists()))
report=dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='Three instrumented modes1000loops growth/clone/copy/merge/overwrite/fill/clear/1000catch, forced string reuse and exact >2^53 observations, warmupdelta0. Five excluded profiles,15shape and3uncalled-combination controls. Not Harbour parity.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));print([x for x in rows if not x['ok']]);assert all(x['ok'] for x in rows)

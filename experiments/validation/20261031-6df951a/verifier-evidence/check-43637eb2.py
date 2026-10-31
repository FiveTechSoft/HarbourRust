from pathlib import Path
import subprocess,json,os,hashlib
w=Path('/downloads/verify-replicate6df951a');b=Path('/downloads/verify-replicate-contracts');hb='/tmp/harbour-reference/bin/linux/gcc/hbmk2'
def run(cmd):
 try:
  q=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=25,cwd=b);return dict(exit=q.returncode,stdout=q.stdout.decode(errors='replace'),stderr=q.stderr.decode(errors='replace'))
 except subprocess.TimeoutExpired as e:return dict(exit=None,timeout=25,stdout=(e.stdout or b'').decode(errors='replace'),stderr=(e.stderr or b'').decode(errors='replace'))
cases={
'zero_edges': 'function main()\n? "["+Replicate("",9223372036854775807)+"]"\n? "["+Replicate("abc",-9223372036854775807-1)+"]"\n? "["+Replicate("abc",1)+"]"\nreturn nil\n',
'doubling': 'function main()\n? Replicate("abc",5)\n? Replicate("abc",7)\n? Replicate("abc",8)\n? Replicate("abc",9)\n? Len(Replicate("abc",100001))\nreturn nil\n',
'nul_bytes': 'function main()\nOutStd(Replicate("a"+Chr(0)+"b",3))\nreturn nil\n',
'owned_reuse': 'function main()\nlocal a := hb_ntos(123)\nlocal b := Replicate(a,3)\n? a\n? b\n? Replicate(Replicate(LTrim("  xy"),3),2)\n? PadR(Replicate("ab",3),8)\nreturn nil\n',
'effects': 'function main()\n? Replicate(txt(),num(3))\n? Replicate(txt(),num(0))\nreturn nil\nfunction txt()\n? "S"\nreturn "ab"\nfunction num(n)\n? n\nreturn n+0\n',
'infer_params': 'function main()\n? rep("ab",4)\nreturn nil\nfunction rep(s,n)\nreturn Replicate(s,n)\n',
'formerly_unknown': subprocess.check_output(['git','-C','/downloads/alias-remote','show','01e92c9:tests/t1369_unknown_nested_arg_neg.hb']).decode(),
'published_t1406': (w/'tests/t1406_replicate.hb').read_text(),
'overflow_mult': 'function main()\n? Replicate("ab",9223372036854775807)\nreturn nil\n',
'overflow_alloc': 'function main()\n? Replicate("a",9223372036854775807)\nreturn nil\n',
'balance': 'function main()\nexercise()\n? hb_memcheck()\nreturn nil\nfunction exercise()\nlocal s := Replicate("a",3)\ns := Replicate(s,2)\n? Replicate(Replicate("x",0),2)\n? Replicate(LTrim("  ab"),3)\nreturn nil\n'}
rows=[]
for name,src in cases.items():
 p=b/(name+'.prg');p.write_text(src);r=dict(name=name,source=src,results={})
 if not name.startswith('overflow') and name!='balance':
  re=b/(name+'-ref');r['ref_build']=run([hb,p,'-q','-gtstd','-o'+str(re)])
  if r['ref_build']['exit']==0:r['reference']=run([re])
 for t in ['linux','windows']:
  s=b/(name+'-'+t+'.s');o=s.with_suffix('.o');exe=b/(name+('.exe'if t=='windows'else''));z={'compile':run([w/'hbc',p,s,'--target='+t,'--instrument'])};r['results'][t]=z
  if z['compile']['exit']:continue
  assembler='as'if t=='linux'else os.environ['M']+'/x86_64-w64-mingw32-as';linker='ld'if t=='linux'else os.environ['M']+'/x86_64-w64-mingw32-ld';z['assemble']=run([assembler,'-o',o,s]);z['link']=run([linker,'-o',exe,o]+(['-e','_start','--subsystem','console','-L'+os.environ['MLIB'],'-lkernel32']if t=='windows'else[]))
  if z['link']['exit']==0:z['execution']=run([os.environ['WINE'],exe]if t=='windows'else[exe]);z['exact']=z['execution']==r.get('reference')
 r['llvm']=run([w/'hbc',p,b/'probe.ll','--experimental-llvm']);rows.append(r);(b/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(name,{k:v.get('exact',v['compile'])for k,v in r['results'].items()},flush=True)
neg={n:p.read_text()for n in ['guard_t1369','neg1407','neg1408','neg1409','neg1410']for p in [w/'tests'/({'guard_t1369':'t1369_unknown_nested_arg_neg.hb','neg1407':'t1407_replicate_neg_noargs.hb','neg1408':'t1408_replicate_neg_onearg.hb','neg1409':'t1409_replicate_neg_intfirst.hb','neg1410':'t1410_replicate_neg_strcount.hb'}[n])]}
neg.update({'float':'function main()\n? Replicate("ab",1.5)\nreturn nil\n','closure_zero':'function main()\nlocal b := {|| Replicate() }\nreturn nil\n','three':'function main()\n? Replicate("x",3,4)\nreturn nil\n'})
nrows=[]
for name,src in neg.items():
 p=b/(name+'.prg');p.write_text(src);r=dict(name=name,source=src,results={})
 for mode in ['default','llvm']:
  for t in ['linux','windows']:r['results'][mode+'-'+t]=run([w/'hbc',p,b/'negative.out','--target='+t]+(['--experimental-llvm']if mode=='llvm'else[]))
 nrows.append(r);print(name,[(k,v['exit'])for k,v in r['results'].items()])
(b/'negatives.json').write_text(json.dumps(nrows,indent=2)+'\n')
g=lambda *a:subprocess.check_output(['git','-C','/downloads/alias-remote',*a]).decode().strip()
(b/'identity.json').write_text(json.dumps(dict(commit=g('rev-parse','6df951a'),tag=g('rev-parse','snapshot/replicate-pending-verification'),remote_observed=g('rev-parse','origin/experiment/llvm-scalar-aot'),tree=g('rev-parse','6df951a^{tree}'),base=g('rev-parse','01e92c9')),indent=2)+'\n')

from pathlib import Path
import subprocess,json,hashlib
w=Path('/downloads/verify-stringscd9fea6'); b=Path('/downloads/verify-strings-contracts'); hb='/tmp/harbour-reference/bin/linux/gcc/hbmk2'
def run(cmd):
 try:
  q=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=20,cwd=b);return dict(exit=q.returncode,stdout=q.stdout.decode(errors='replace'),stderr=q.stderr.decode(errors='replace'))
 except subprocess.TimeoutExpired:return dict(exit=None,timeout=20)
custom={
'boundaries':'''function main()
local m := -9223372036854775807 - 1
? "[" + hb_ntos(m) + "]"
? "[" + Str(m) + "]"
? "[" + Str(m,19) + "]"
? "[" + Str(m,21) + "]"
? "[" + Str(-999999999) + "]"
? "[" + Str(-1000000000) + "]"
? "[" + Str(1000000000) + "]"
return nil
''',
'pad_bytes':'''function main()
? "[" + PadR("ab",2) + "]"
? "[" + PadR("ab",1) + "]"
? "[" + PadR("",0) + "]"
? "[" + PadR("a"+Chr(0)+"b",5) + "]"
? "[" + PadR("a"+Chr(0)+"b",2) + "]"
return nil
''',
'owned_alias':'''function main()
local a := hb_ntos(123)
local c := a
local d := PadR(a,5)
? "[" + a + "][" + c + "][" + d + "]"
? "[" + PadR(PadR(hb_ntos(-7),8),4) + "]"
? "[" + Str(42,Len(PadR("x",3))) + "]"
return nil
''',
'call_order':'''function main()
? "[" + Str(mark(42),mark(4)) + "]"
? "[" + PadR(txt(),mark(4)) + "]"
return nil
function mark(n)
? n
return n
function txt()
? "TXT"
return "xy"
''',
'param_infer':'''function main()
? fmt(12,4)
? pad("x",3)
return nil
function fmt(n,w)
return Str(n,w)
function pad(s,w)
return PadR(s,w)
'''}
neg={'padr_zero':'PadR()','str_zero':'Str()','ntos_zero':'hb_ntos()','padr_float':'PadR("x",1.5)','padr_numeric':'PadR(42,4)','padr_three':'PadR("x",4,"_")','str_three':'Str(1,4,0)','ntos_float':'hb_ntos(1.2)','padr_zero_param':'wrap(1)'}
rows=[]
custom.update({
'pad_nul_outstd': 'function main()\nOutStd(PadR("a"+Chr(0)+"b",5))\nOutStd(PadR("a"+Chr(0)+"b",2))\nreturn nil\n',
'call_order_typed': custom['call_order'].replace('return n\n','return n + 0\n'),
'owned_reuse': 'function main()\nlocal a := hb_ntos(123)\nlocal d := PadR(a,5)\n? "["+a+"]["+d+"]"\n? "["+PadR(PadR(hb_ntos(-7),8),4)+"]"\n? "["+Str(42,Len(PadR("x",3)))+"]"\nreturn nil\n',
'pad_nul_asc': 'function main()\nlocal a := PadR("a"+Chr(0)+"b",5)\n? Len(a)\n? Asc(SubStr(a,2,1))\nreturn nil\n'
})
for p in sorted(w.glob('tests/t139[2-8]*')):
 custom[p.stem]=p.read_text()
for name,src in custom.items():
 p=b/(name+'.prg');p.write_text(src);ref=b/(name+'-ref'); r=dict(name=name,source=src,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
 r['ref_build']=run([hb,p,'-gtstd','-q','-o'+str(ref)])
 if r['ref_build']['exit']==0:r['reference']=run([ref])
 r['compile']=run([w/'hbc',p,b/(name+'.s')])
 if r['compile']['exit']==0:
  r['assemble']=run(['as','-o',b/(name+'.o'),b/(name+'.s')]);r['link']=run(['ld','-o',b/name,b/(name+'.o')])
  if r['link']['exit']==0:r['execution']=run([b/name]);r['exact']=r['execution']==r.get('reference')
 r['llvm']=run([w/'hbc',p,b/(name+'.ll'),'--experimental-llvm'])
 rows.append(r);print(name,r.get('exact'),r['compile'] if r['compile']['exit'] else '',flush=True)
 (b/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
nrows=[]
for name,expr in neg.items():
 p=b/(name+'.prg');p.write_text('function main()\n? '+expr+'\nreturn nil\n'+('function wrap(n)\nreturn PadR()\n' if name=='padr_zero_param' else ''));r=dict(name=name,source=p.read_text(),results={})
 for mode in ['default','llvm']:
  for target in ['linux','windows']:r['results'][mode+'-'+target]=run([w/'hbc',p,b/'negative.out','--target='+target]+(['--experimental-llvm']if mode=='llvm'else[]))
 nrows.append(r);print(name,r['results']['default-linux'],flush=True)
(b/'negatives.json').write_text(json.dumps(nrows,indent=2)+'\n')

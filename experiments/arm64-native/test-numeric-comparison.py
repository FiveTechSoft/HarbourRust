"""Numeric comparison chooses exact integer vs converted double by runtime tags."""
from pathlib import Path
import subprocess,importlib.util,json,re
r=Path(__file__).resolve().parent;out=r/'numeric-comparison-cases';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
ops=['=','==','<>','<','<=','>','>=']
def table(a,b):return '? '+','.join(a+op+b for op in ops)
pos={
'mixed-compare-old':'LOCAL a:=1\nLOCAL b:=1.0\n'+table('a','b'),
'mixed-local-old':'LOCAL x:=1\nx:=1.25\n'+table('x','1'),
'copy-comparison-old':'LOCAL x:=1\nx:=1.25\nLOCAL y:=x\n'+table('y','1.25'),
'kind-changes':'LOCAL x:=9007199254740993\nLOCAL y:=9007199254740992\nIF .F.\nx:=1.0\ny:=1.0\nENDIF\n'+table('x','y')+'\nx:=9007199254740992.0\n'+table('x','y')+'\ny:=9007199254740992.0\n'+table('x','y'),
'loop':'LOCAL x:=1\nLOCAL y:=2\nDO WHILE x<y\n? x<2.0\nx:=2.0\nENDDO\n'+table('x','y'),
'order':'? A()<B()\nRETURN\nFUNCTION A()\n? "left"\nRETURN 1\nFUNCTION B()\n? "right"\nRETURN 2.0',
'quotient':'LOCAL x:=1\nLOCAL y:=2\n'+table('(x/y)','0.5'),
}
values=[('9007199254740993','9007199254740992'),('9007199254740993','9007199254740992.0'),('9223372036854775807','9223372036854775807'),('9223372036854775807','9223372036854775807.0'),('(-9223372036854775807-1)','-9223372036854775807.0'),('0','-0.0'),('-1','-1.250'),('10000000000','9999999999.0')]
for i,(a,b)in enumerate(values):
 for reverse in[False,True]:
  if reverse:a,b=b,a
  for mixed in[False,True]:
   extra='IF .F.\nx:='+('1'if'.'in a else'1.0')+'\ny:='+('1'if'.'in b else'1.0')+'\nENDIF\n'if mixed else''
   pos[f'pair-{i}-{int(reverse)}-{int(mixed)}']=f'LOCAL x:={a}\nLOCAL y:={b}\n'+extra+table('x','y')
neg={
'bool':'LOCAL x:=1\n? x=.T.',
'string':'LOCAL x:=1\n? x="1"',
'contains':'LOCAL x:=1\n? x$2',
'mixed-arith':'LOCAL x:=1\nx:=1.25\n? x+1<2',
'float-arith':'LOCAL x:=1.25\n? x+1.0<3',
'mixed-argument':'LOCAL x:=1\nx:=1.25\n? F(x)\nRETURN\nFUNCTION F(n)\nRETURN n<2',
}
def src(body):
 body=re.sub(r'(-?\d{16,})\.0',r'(\1/one)',body)
 return'FUNCTION Main()\nLOCAL one:=1\n'+body+('\n'if'\nFUNCTION 'in body else'\nRETURN\n')
def run(*args):return subprocess.run(list(map(str,args)),capture_output=True)
records=[]
for name,body in pos.items():
 f=out/(name+'.prg');f.write_text(src(body));arm=out/(name+'.arm');linux=out/(name+'.linux')
 for compiler,target,dest in[(r/'hbc-arm64-research','macho-arm64',arm),(r/'hbc-baseline','linux',linux)]:
  result=run(compiler,f,dest,'--target='+target);assert result.returncode==0,(name,result.stderr)
 ref=run(linux);assert ref.returncode==0 and not ref.stderr
 for short,intr,fp in[(None,False,(0,0)),(1,False,(3<<22|1<<24,0x0800009f)),(3,True,(1<<22|1<<25,0x1f))]:
  got=m.execute(arm,short,intr,fp_state=fp);assert got['rc']==0 and bytes.fromhex(got.pop('stdout_hex'))==ref.stdout,(name,got,ref.stdout)
 records.append({'name':name,'modes':3,'stdout':ref.stdout.decode()})
for name,body in neg.items():
 f=out/(name+'.prg');f.write_text(src(body));dest=out/(name+'.arm');dest.unlink(missing_ok=True)
 result=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert result.returncode!=0 and not dest.exists(),name
 dest.write_bytes(b'canary');again=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert again.returncode!=0 and dest.read_bytes()==b'canary';dest.unlink()
 records.append({'name':name,'rejected':result.stderr.decode()})
(out/'results.json').write_text(json.dumps({'positive':len(pos),'negative':len(neg),'modes':3,'scope':'finite I64/F64/Mixed comparisons, not mixed arithmetic or call/return ABI','cases':records},indent=2)+'\n')
print(len(pos),'numeric comparison sources x3 exact;',len(neg),'fail-closed negatives')

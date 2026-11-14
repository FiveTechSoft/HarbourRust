"""Bounded fixed F64 +,-,*; nonfinite/dec>16 are research exit75, not VM errors."""
from pathlib import Path
import subprocess,importlib.util,json
r=Path(__file__).resolve().parent;out=r/'f64-arithmetic-cases';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
pos={
'i64-division-result':'LOCAL x:=3\n? x/2+1.0',
'prior-comparison':'LOCAL x:=1.25\n? x+1.0<3',
'large-finite':'LOCAL a:=10.0^200\nLOCAL b:=1.0\n? a+b,a-b,a*b',
'underflow':'LOCAL a:=10.0^(-200)\nLOCAL b:=a\n? a*b,a+b,a-b',
'nested-right':'LOCAL a:=1.250\n? a+F(2.50,3.000),a*F(2.50,3.000)\nRETURN\nFUNCTION F(a,b)\nIF a<0.0\nRETURN a\nENDIF\nIF b<0.0\nRETURN b\nENDIF\nRETURN a+b',
'basic':'LOCAL a:=1.250\nLOCAL b:=2.50\n? a+b,a-b,a*b',
'copy':'LOCAL a:=1.250\nLOCAL b:=2.50\nLOCAL c:=a*b\nLOCAL d:=c\n? a,b,c,d\nc:=a+b\n? c,d',
'compound':'LOCAL a:=1.250\nLOCAL b:=2.50\n? (a+b)*(a-b)',
'order':'? A()+B(),A()-B(),A()*B()\nRETURN\nFUNCTION A()\n? "left"\nRETURN 1.250\nFUNCTION B()\n? "right"\nRETURN 2.50',
'calls':'? F(1.250,2.50),F(F(1.250,2.50),2.0)\nRETURN\nFUNCTION F(a,b)\nIF a<0.0\nRETURN a\nENDIF\nIF b<0.0\nRETURN b\nENDIF\nRETURN a*b',
'parameters':'? F(1.250,2.50)\nRETURN\nFUNCTION F(a,b)\nIF a<0.0\nRETURN a\nENDIF\nIF b<0.0\nRETURN b\nENDIF\na:=a+b\nb:=a-b\nRETURN a*b',
'loop':'LOCAL a:=0.0\nLOCAL b:=0.250\nDO WHILE a<1.0\na:=a+b\n? a\nENDDO',
'compare':'LOCAL a:=1.250\nLOCAL b:=2.50\n? a+b>b,a-b<b,a*b==b+a',
'lazy':'LOCAL a:=1.25\n? .F. .AND. (a*Side()>1.0),.T. .OR. (a+Side()>1.0)\nRETURN\nFUNCTION Side()\n? "must-not-run"\nRETURN 2.0',
'mixed-destination':'LOCAL a:=1.250\nLOCAL b:=2.50\nLOCAL c:=1\nc:=a+b\nLOCAL d:=c\n? c,d\nc:=a*b\n? c,d',
'dead-add':'IF .F.\nLOCAL a:=1.25\n? a+2.0\nENDIF\n? "ok"',
'unused-add':'? "ok"\nRETURN\nFUNCTION Never()\nLOCAL a:=1.25\nRETURN a+1.0',
}
for i,(a,b)in enumerate([('0.0','-0.0'),('-0.0','-0.0'),('1.0','-1.0'),('9999999999.0','1.0'),('10000000000.0','1.0'),('-999999999.0','-1.0'),('-1000000000.0','-1.0'),('0.00000001','0.00000001'),('1.23456789','1.23456789'),('9999999999.0','9999999999.0')]):
 pos[f'bound-{i}']=f'LOCAL a:={a}\nLOCAL b:={b}\n? a+b,a-b,a*b'
pos['dec16-add']='LOCAL a:=0.0000000000000001\nLOCAL b:=1.0\n? a+b,a-b'
neg={
'float-int':'LOCAL a:=1.25\n? a+1',
'int-float':'LOCAL a:=1\n? a+1.25',
'float-div':'LOCAL a:=1.25\n? a/1.0',
'mixed':'LOCAL a:=1\na:=1.25\n? a+1.0',
'dead-mixed':'LOCAL a:=1\na:=1.25\nIF .F.\n? a*1.0\nENDIF',
'power':'LOCAL a:=1.25\n? a^2.0',
'remainder':'LOCAL a:=1.25\n? a%2.0',
'caught':'LOCAL a:=1.25\nTRY\n? a+2.0\nCATCH\n? "caught"\nEND',
'byref':'LOCAL a:=1.25\nF(@a)\nRETURN\nFUNCTION F(n)\n? n+2.0\nRETURN',
'date':'? Date()',
'curdir':'? CurDir()',
'class':'CLASS C\nENDCLASS\n? 1',
'precision17':'LOCAL a:=0.12345678901234567\n? a+1.0',
}
limits={
'dec17-mul':'LOCAL a:=0.123456789\nLOCAL b:=0.12345678\n? a*b',
'dec32-mul':'LOCAL a:=0.0000000000000001\n? a*a',
'nonfinite':'LOCAL a:=10.0^200\n? a*a',
'dec-stops-right':'? Fail()*Side()\nRETURN\nFUNCTION Fail()\nLOCAL a:=0.0000000000000001\nRETURN a*a\nFUNCTION Side()\n? "must-not-run"\nRETURN 1.0',
}
def src(body):return 'FUNCTION Main()\n'+body+('\n'if'\nFUNCTION 'in body else'\nRETURN\n')
def run(*args):return subprocess.run(list(map(str,args)),capture_output=True)
records=[]
for name,body in pos.items():
 f=out/(name+'.prg');f.write_text(src(body));arm=out/(name+'.arm');linux=out/(name+'.linux')
 for compiler,target,dest in[(r/'hbc-arm64-research','macho-arm64',arm),(r/'hbc-baseline','linux',linux)]:
  p=run(compiler,f,dest,'--target='+target);assert p.returncode==0,(name,p.stderr)
 ref=run(linux);assert ref.returncode==0 and not ref.stderr
 for short,intr,fp in[(None,False,(0,0)),(1,False,(3<<22|1<<24,0x0800009f)),(3,True,(1<<22|1<<25,0x1f))]:
  got=m.execute(arm,short,intr,fp_state=fp);assert got['rc']==0 and bytes.fromhex(got['stdout_hex'])==ref.stdout,(name,got,ref.stdout)
 for fault in ['zero','oversize','failure']:
  got=m.execute(arm,failure=fault=='failure',fault=None if fault=='failure'else fault);assert got['rc']==74 and not got['stdout_hex'],(name,fault,got)
 records.append({'name':name,'modes':3,'stdout':ref.stdout.decode(),'write_faults':3})
for name,body in limits.items():
 f=out/(name+'.prg');f.write_text(src(body));arm=out/(name+'.arm');p=run(r/'hbc-arm64-research',f,arm,'--target=macho-arm64');assert p.returncode==0,(name,p.stderr)
 for fp in [(0,0),(3<<22|1<<24,0x0800009f),(1<<22|1<<25,0x1f)]:
  got=m.execute(arm,fp_state=fp);assert got['rc']==75 and not got['stdout_hex'],(name,got)
 records.append({'name':name,'research_limit_exit':75,'modes':3,'not_x86_equivalence':True})
for name,body in neg.items():
 f=out/(name+'.prg');f.write_text(src(body));dest=out/(name+'.arm');dest.unlink(missing_ok=True)
 p=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert p.returncode!=0 and not dest.exists(),name
 dest.write_bytes(b'canary');p=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert p.returncode!=0 and dest.read_bytes()==b'canary',name;dest.unlink()
 records.append({'name':name,'compile_reject':True})
(out/'results.json').write_text(json.dumps({'positive':len(pos),'research_limits':len(limits),'negative':len(neg),'cases':records},indent=2)+'\n')
print(len(pos),'fixed F64 arithmetic sources x3 exact;',len(limits),'research exit75 x3;',len(neg),'fail-closed negatives')

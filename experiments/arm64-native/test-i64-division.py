"""Fixed-I64 division only; source uncaught errors compared with current x86."""
from pathlib import Path
import subprocess,importlib.util,json
r=Path(__file__).resolve().parent;out=r/'i64-division-cases';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
pos={
'zero-nested':'? Outer(0)\nRETURN\nFUNCTION Outer(n)\nRETURN Inner(n)\nFUNCTION Inner(n)\nRETURN 8/n',
'zero-stops-right':'? Fail(0)/Side()\nRETURN\nFUNCTION Fail(n)\nLOCAL x:=8\n? x/n\nRETURN 1\nFUNCTION Side()\n? "must-not-run"\nRETURN 2',
'basic':'LOCAL x:=8\nLOCAL y:=2\n? x/y',
'call-return':'LOCAL x:=17\nLOCAL y:=3\n? F(x/y),G(x,y)\nRETURN\nFUNCTION F(n)\nIF n<0.0\nRETURN n\nENDIF\n? n\nRETURN n\nFUNCTION G(a,b)\nRETURN a/b',
'compound-operands':'LOCAL x:=17\nLOCAL y:=3\n? (x+y)/(x-y)',
'mixed-destination':'LOCAL x:=17\nLOCAL y:=3\nLOCAL z:=1\nz:=x/y\nLOCAL a:=z\n? z,a',
'left-right-order':'? A()/B()\nRETURN\nFUNCTION A()\n? "left"\nRETURN 17\nFUNCTION B()\n? "right"\nRETURN 3',
'dead-div':'IF .F.\nLOCAL x:=3\n? x/2\nENDIF\n? "ok"',
'unused-div':'? "ok"\nRETURN\nFUNCTION Never()\nLOCAL x:=3\nRETURN x/2',
'zero':'LOCAL x:=8\nLOCAL y:=0\n? x/y',
'zero-call':'LOCAL x:=8\nLOCAL y:=0\n? F(x,y)\nRETURN\nFUNCTION F(a,b)\n? a/b\nRETURN 1.0',
'zero-right-effect':'LOCAL x:=8\n? A()/B(x)\nRETURN\nFUNCTION A()\n? "left"\nRETURN 17\nFUNCTION B(n)\n? "right"\nRETURN n-n',
'zero-loop':'LOCAL x:=2\nDO WHILE x>0\nx:=x-1\n? 8/x\nENDDO',
}
for i,(a,b)in enumerate([('1','3'),('-1','3'),('0','-1'),('9999999999','1'),('10000000000','1'),('-999999999','1'),('-1000000000','1'),('9223372036854775807','-1'),('(-9223372036854775807-1)','-1'),('1','9223372036854775807'),('(-9223372036854775807-1)','3')]):pos[f'bound-{i}']=f'LOCAL x:={a}\nLOCAL y:={b}\n? x/y'
neg={
'float-div':'LOCAL x:=1.25\n? x/1',
'mixed-div':'LOCAL x:=1\nx:=1.25\n? x/1',
'nested-result-div':'LOCAL x:=3\n? (x/2)/2',
'float-add-result':'LOCAL x:=3\n? x/2+1.0',
'zero-try':'LOCAL x:=0\nTRY\n? 1/x\nCATCH\n? "caught"\nEND',
'dead-try':'LOCAL x:=0\nIF .F.\nTRY\n? 1/x\nCATCH\n? "caught"\nEND\nENDIF',
'precision':'LOCAL x:=1\n? 0.12345678901234567/x',
}
def src(body):return 'FUNCTION Main()\n'+body+('\n'if '\nFUNCTION 'in body else '\nRETURN\n')
def run(*args):return subprocess.run(list(map(str,args)),capture_output=True)
records=[]
# Include-origin zero case checks the preprocessor's original file/line map.
inc=out/'divide.ch';inc.write_text('LOCAL x:=8\nLOCAL y:=0\n? x/y\n')
pos['include-zero']='#include "divide.ch"'
for name,body in pos.items():
 f=out/(name+'.prg');f.write_text(src(body));arm=out/(name+'.arm');linux=out/(name+'.linux')
 for compiler,target,dest in[(r/'hbc-arm64-research','macho-arm64',arm),(r/'hbc-baseline','linux',linux)]:
  result=run(compiler,f,dest,'--target='+target);assert result.returncode==0,(name,result.stderr)
 ref=run(linux);assert ref.returncode in[0,1]and not ref.stderr
 for short,intr,fp in[(None,False,(0,0)),(1,False,(3<<22|1<<24,0x0800009f)),(3,True,(1<<22|1<<25,0x1f))]:
  got=m.execute(arm,short,intr,fp_state=fp);assert got['rc']==ref.returncode and bytes.fromhex(got.pop('stdout_hex'))==ref.stdout,(name,short,got,ref.stdout)
 if ref.stdout:
  for fault in ['zero','oversize','failure']:
   got=m.execute(arm,failure=fault=='failure',fault=None if fault=='failure'else fault);assert got['rc']==74 and got['stdout_hex']=='',(name,fault,got)
 records.append({'name':name,'modes':3,'exit':ref.returncode,'stdout':ref.stdout.decode(),'write_failures':3 if ref.stdout else 0})
for name,body in neg.items():
 f=out/(name+'.prg');f.write_text(src(body));dest=out/(name+'.arm');dest.unlink(missing_ok=True)
 result=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert result.returncode!=0 and not dest.exists(),name
 dest.write_bytes(b'canary');again=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert again.returncode!=0 and dest.read_bytes()==b'canary';dest.unlink()
 records.append({'name':name,'rejected':result.stderr.decode()})
(out/'results.json').write_text(json.dumps({'positive':len(pos),'negative':len(neg),'modes':3,'scope':'fixed-I64 / -> finite F64 dec2 and uncaught zero only, no caught/F64operand/Mixedoperand arithmetic','cases':records},indent=2)+'\n')
print(len(pos),'fixed-I64 division sources x3 exact;',sum(x.get('exit')==1 for x in records),'uncaught-zero;',len(neg),'fail-closed negatives')

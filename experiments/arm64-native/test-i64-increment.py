"""Expression ++/-- checked fixed-I64 updates, not standalone desugared wrap."""
from pathlib import Path
import subprocess,importlib.util,json
r=Path(__file__).resolve().parent;out=r/'i64-increment-cases';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
pos={
'basic':'LOCAL n:=1\n? n++,n,++n,n--,n,--n,n',
'width':'LOCAL n:=9999999999\n? n++,n,++n,n--,--n,n',
'copy':'LOCAL n:=9999999999\nLOCAL a:=n++\nLOCAL b:=++n\n? a,b,n',
'order':'LOCAL n:=1\n? F(n++),F(++n),n\nRETURN\nFUNCTION F(n)\nIF n<0\nRETURN n\nENDIF\n? n\nRETURN n',
'nested':'LOCAL n:=2\n? n++*++n,n,(n++<++n),n',
'parameter':'? F(9999999999)\nRETURN\nFUNCTION F(n)\nIF n<0\nRETURN n\nENDIF\n? n++,n\nRETURN ++n',
'loop':'LOCAL n:=0\nDO WHILE n++<3\n? n\nENDDO\n? n',
'short-circuit':'LOCAL n:=1\n? .F. .AND. (n++>0),n,.T. .OR. (++n>0),n\n? .T. .AND. (n++>0),n',
'overflow-prefix':'LOCAL n:=9223372036854775807\n? ++n',
'overflow-postfix':'LOCAL n:=9223372036854775807\n? n++',
'underflow':'LOCAL n:=(-9223372036854775807-1)\n? n--',
'overflow-frame':'? F(9223372036854775807)\nRETURN\nFUNCTION F(n)\nIF n<0\nRETURN n\nENDIF\nRETURN ++n',
'overflow-stop':'LOCAL n:=9223372036854775807\n? n++,Side()\nRETURN\nFUNCTION Side()\n? "must-not-run"\nRETURN 1',
}
for i,n in enumerate(['0','-1','9999999999','10000000000','-999999999','-1000000000','9223372036854775806','(-9223372036854775807)']):pos[f'bound-{i}']=f'LOCAL n:={n}\n? n++,n,n--,n,++n,--n'
neg={
'mixed-destination':'LOCAL n:=9999999999\nLOCAL x:=1.25\nx:=n++\n? x,n\nx:=++n\n? x,n',
'float':'LOCAL n:=1.25\n? n++',
'mixed':'LOCAL n:=1\nn:=1.25\n? ++n',
'dead-mixed':'LOCAL n:=1\nn:=1.25\nIF .F.\n? n++\nENDIF',
'bool':'LOCAL n:=.T.\n? n++',
'call-lvalue':'? F()++\nRETURN\nFUNCTION F()\nRETURN 1',
'byref':'LOCAL n:=1\nF(@n)\nRETURN\nFUNCTION F(n)\n? n++\nRETURN',
'caught-overflow':'LOCAL n:=9223372036854775807\nTRY\n? n++\nCATCH\n? "caught"\nEND',
}
def src(body):return'FUNCTION Main()\n'+body+('\n'if'\nFUNCTION 'in body else'\nRETURN\n')
def run(*args):return subprocess.run(list(map(str,args)),capture_output=True)
records=[]
for name,body in pos.items():
 f=out/(name+'.prg');f.write_text(src(body));arm=out/(name+'.arm');linux=out/(name+'.linux')
 for compiler,target,dest in[(r/'hbc-arm64-research','macho-arm64',arm),(r/'hbc-baseline','linux',linux)]:
  result=run(compiler,f,dest,'--target='+target);assert result.returncode==0,(name,result.stderr)
 ref=run(linux);assert ref.returncode in[0,1]and not ref.stderr
 for short,intr,fp in[(None,False,(0,0)),(1,False,(3<<22|1<<24,0x0800009f)),(3,True,(1<<22|1<<25,0x1f))]:
  got=m.execute(arm,short,intr,fp_state=fp);assert got['rc']==ref.returncode and bytes.fromhex(got.pop('stdout_hex'))==ref.stdout,(name,got,ref.stdout)
 for fault in ['zero','oversize','failure']:
  got=m.execute(arm,failure=fault=='failure',fault=None if fault=='failure'else fault);assert got['rc']==74 and got['stdout_hex']=='',(name,fault,got)
 records.append({'name':name,'modes':3,'exit':ref.returncode,'stdout':ref.stdout.decode(),'write_faults':3})
for name,body in neg.items():
 f=out/(name+'.prg');f.write_text(src(body));dest=out/(name+'.arm');dest.unlink(missing_ok=True)
 result=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert result.returncode!=0 and not dest.exists(),name
 dest.write_bytes(b'canary');again=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert again.returncode!=0 and dest.read_bytes()==b'canary';dest.unlink()
 records.append({'name':name,'rejected':result.stderr.decode()})
(out/'results.json').write_text(json.dumps({'positive':len(pos),'negative':len(neg),'modes':3,'scope':'checked fixed-I64 expression increment/decrement with original old/new provenance, no numeric promotion or caught errors','cases':records},indent=2)+'\n')
print(len(pos),'expression increment sources x3 exact;',sum(x.get('exit')==1 for x in records),'overflow errors;',len(neg),'fail-closed negatives')

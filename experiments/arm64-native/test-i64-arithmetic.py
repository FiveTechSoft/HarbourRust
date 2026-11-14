"""Bounded fixed-I64 runtime +,-,* only; current x86 is the behavior oracle."""
from pathlib import Path
import subprocess,importlib.util,json
r=Path(__file__).resolve().parent;out=r/'i64-arithmetic-cases';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
pos={
'standalone-inc':'LOCAL n:=9999999999\nn++\n? n\n--n\n? n',
'standalone-compound':'LOCAL n:=9999999999\nn+=1\n? n\nn-=2\n? n\nn*=2\n? n',
'ops':'LOCAL x:=17\nLOCAL y:=3\n? x+y,x-y,x*y,(x+y)*(x-y)',
'copies':'LOCAL x:=9999999999\nLOCAL y:=1\nLOCAL z:=x+y\nLOCAL a:=z\n? x,z,a\nz:=z+y\n? z,a',
'branch':'LOCAL x:=9999999999\nLOCAL y:=1\nLOCAL z:=x\nIF .T.\nz:=x+y\nENDIF\n? z\nIF .F.\nz:=x+y\nELSE\nz:=x\nENDIF\n? z',
'loop':'LOCAL x:=9999999999\nLOCAL y:=1\nDO WHILE y<4\nx:=x+1\n? x\ny:=y+1\nENDDO',
'call-return':'LOCAL x:=9999999999\nLOCAL y:=1\n? F(x+y),G(x,y),F(F(x+y))\nRETURN\nFUNCTION F(n)\nIF n<0\nRETURN n\nENDIF\n? n\nn:=n+1\nRETURN n\nFUNCTION G(a,b)\nRETURN a+b',
'mixed-destination':'LOCAL x:=9999999999\nLOCAL z:=1.25\nz:=x+1\nLOCAL a:=z\n? z,a',
'order':'? A()*B()\nRETURN\nFUNCTION A()\n? "left"\nRETURN 17\nFUNCTION B()\n? "right"\nRETURN 3',
'dead-add':'LOCAL n:=1\nIF .F.\n? n+1\nENDIF\n? n',
'old-add':'LOCAL x:=1\n? x+1',
'unused-add':'? "ok"\nRETURN\nFUNCTION Never()\nLOCAL x:=1\nRETURN x+1',
}
for i,n in enumerate(['0','1','-1','9999999999','10000000000','-999999999','-1000000000','9223372036854775807','(-9223372036854775807-1)']):
 pos[f'bound-{i}']=f'LOCAL x:={n}\nLOCAL y:=1\n? x,x+y,x-y,x*y\ny:=2\n? x+y,x-y,x*y'
neg={
'expr-inc':'LOCAL n:=1\n? n++',
'float-add':'LOCAL x:=1.25\n? x+1.0',
'mixed-add':'LOCAL x:=1\nx:=1.25\n? x+1',
'mixed-dead':'LOCAL x:=1\nx:=1.25\nIF .F.\n? x+1\nENDIF',
'remainder':'LOCAL x:=3\n? x%2',
'power':'LOCAL x:=3\n? x^2',
}
def src(body):return 'FUNCTION Main()\n'+body+('\n'if '\nFUNCTION 'in body else '\nRETURN\n')
def run(*args):return subprocess.run(list(map(str,args)),capture_output=True)
records=[]
for name,body in pos.items():
 f=out/(name+'.prg');f.write_text(src(body));arm=out/(name+'.arm');linux=out/(name+'.linux')
 for compiler,target,dest in[(r/'hbc-arm64-research','macho-arm64',arm),(r/'hbc-baseline','linux',linux)]:
  result=run(compiler,f,dest,'--target='+target);assert result.returncode==0,(name,result.stderr)
 ref=run(linux);assert ref.returncode==0 and not ref.stderr
 for short,intr,fp in[(None,False,(0,0)),(1,False,(3<<22|1<<24,0x0800009f)),(3,True,(1<<22|1<<25,0x1f))]:
  got=m.execute(arm,short,intr,fp_state=fp);assert got['rc']==0 and bytes.fromhex(got.pop('stdout_hex'))==ref.stdout,(name,short,got,ref.stdout)
 records.append({'name':name,'modes':3,'stdout':ref.stdout.decode()})
for name,body in neg.items():
 f=out/(name+'.prg');f.write_text(src(body));dest=out/(name+'.arm');dest.unlink(missing_ok=True)
 result=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert result.returncode!=0 and not dest.exists(),name
 dest.write_bytes(b'canary');result=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert result.returncode!=0 and dest.read_bytes()==b'canary';dest.unlink()
 records.append({'name':name,'rejected':result.stderr.decode()})
(out/'results.json').write_text(json.dumps({'positive':len(pos),'modes':3,'negative':len(neg),'scope':'fixed I64 wrapping runtime +,-,* only, not mixed/F64 arithmetic or / or caught errors','cases':records},indent=2)+'\n')
print(len(pos),'fixed I64 sources x3 exact;',len(neg),'fail-closed negatives')

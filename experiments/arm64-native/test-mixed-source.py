from pathlib import Path
import subprocess,importlib.util,json
r=Path(__file__).resolve().parent;out=r/'mixed-source-cases';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
pos={
'int-float-int':'LOCAL x:=1\n? x\nx:=1.250\n? x\nx:=19\n? x',
'float-int-float':'LOCAL x:=1.250\n? x\nx:=19\n? x\nx:=2.50\n? x',
'copy-detached':'LOCAL x:=1\nLOCAL a:=x\nx:=1.250\nLOCAL b:=x\n? x,a,b\nx:=19\n? x,a,b',
'branch-true':'LOCAL x:=1\nIF .T.\nx:=1.250\nELSE\nx:=19\nENDIF\n? x',
'branch-false':'LOCAL x:=1\nIF .F.\nx:=1.250\nELSE\nx:=19\nENDIF\n? x',
'loop-change':'LOCAL go:=.T.\nLOCAL x:=1\nDO WHILE go\n? x\nx:=1.250\n? x\ngo:=.F.\nENDDO\n? x',
'function-local':'? F(1),F(0)\nRETURN\nFUNCTION F(n)\nIF n<0\nRETURN 0\nENDIF\nLOCAL x:=1\nIF n>0\nx:=1.250\nENDIF\n? x\nRETURN n',
'per-function':'LOCAL x:=1\nx:=1.250\n? x\nSide()\nRETURN\nFUNCTION Side()\nLOCAL x:=2.50\n? x\nRETURN',
}
values=['0.0','-0.0','1.0','1.250','-1.250','9999999999.0','10000000000.0','-999999999.0','-1000000000.0','0.0000000000000001']
for i,v in enumerate(values):pos[f'format-{i}']=f'LOCAL x:=1\nx:={v}\nLOCAL y:=x\n? x,y\nx:=9223372036854775807\n? x,y\nx:=(-9223372036854775807-1)\n? x,y'
pos['copy-branch']='LOCAL x:=1\nLOCAL y:=x\nx:=1.250\nIF .T.\ny:=x\nENDIF\n? x,y\nx:=19\n? x,y'
pos['reverse-local-kind']='LOCAL x:=1.250\nx:=1\nLOCAL y:=x\n? x,y\nx:=2.50\n? x,y'
neg={
'inline-literal':'LOCAL x:=1\nx:=1.25\n? (x:=1)',
'inline-copy':'LOCAL x:=1\nx:=1.25\nLOCAL y:=x\n? (y:=x)',
'arithmetic':'LOCAL x:=1\nx:=1.25\n? x+1',
'return':'? F()\nRETURN\nFUNCTION F()\nLOCAL x:=1\nx:=1.25\nRETURN x',
'argument':'LOCAL x:=1\nx:=1.25\nF(x)\nRETURN\nFUNCTION F(n)\n? n\nRETURN',
'borrow':'LOCAL x:=1\nx:=1.25\nF(@x)\nRETURN\nFUNCTION F(n)\n? n\nRETURN',
'bad-assign':'LOCAL x:=1\nx:=1.25\nx:=.T.\n? x',
'dead-arithmetic':'LOCAL x:=1\nx:=1.25\nIF .F.\n? x+1\nENDIF',
'precision':'LOCAL x:=1\nx:=0.12345678901234567\n? x',
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
 records.append({'name':name,'stdout':ref.stdout.decode(),'modes':3})
for name,body in neg.items():
 f=out/(name+'.prg');f.write_text(src(body));dest=out/(name+'.arm');dest.unlink(missing_ok=True)
 result=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert result.returncode!=0 and not dest.exists(),name
 dest.write_bytes(b'output-canary');again=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert again.returncode!=0 and dest.read_bytes()==b'output-canary';dest.unlink()
 records.append({'name':name,'rejected':result.stderr.decode()})
(out/'results.json').write_text(json.dumps({'positive':len(pos),'modes':3,'negative':len(neg),'scope':'mixed local storage/copy/branch and formatting only, no arithmetic AST or mixed call/return/comparison','cases':records},indent=2)+'\n')
print(len(pos),'mixed LOCAL source controls x3 exact;',len(neg),'fail-closed negatives')

from pathlib import Path
import subprocess,importlib.util,json
r=Path(__file__).resolve().parent;out=r/'pair-source-cases';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
# Original scalar boundary regression must still run before any source claim.
pos={
'literals':'? 1.0,1.250,-1.250,0.0,-0.0,9999999999.0,10000000000.0,0.0000000000000001',
'folded-floats':'? 1.5+2.5,9999999999.0+1.0,(-9223372036854775807-1)/3',
'locals-copy':'LOCAL x:=1.250\nLOCAL y:=x\n? x,y\nx:=2.50\n? x,y',
'branches':'LOCAL x:=1.250\nIF .T.\nx:=2.75\nENDIF\n? x',
'compare':'? 1.0<2.0,1.0<=1.0,2.0>1.0,2.0>=2.0,1.0=1.0,1.0<>2.0,-0.0==0.0',
'calls':'? Echo(1.250),Echo(-1.0)\nRETURN\nFUNCTION Echo(n)\nIF n<0.0\nRETURN 0.0\nENDIF\nLOCAL a:=n\nRETURN a',
'nested-order':'? Both(Effect(1.25),Effect(2.50))\nRETURN\nFUNCTION Effect(n)\nIF n<0.0\nRETURN 0.0\nENDIF\n? n\nRETURN n\nFUNCTION Both(a,b)\nIF a<0.0\nRETURN 0.0\nENDIF\nIF b<0.0\nRETURN 0.0\nENDIF\n? a\nRETURN b',
'four-floats':'? Last(1.25,2.50,3.75,4.0)\nRETURN\nFUNCTION Last(a,b,c,d)\nIF a<0.0\nRETURN 0.0\nENDIF\nIF b<0.0\nRETURN 0.0\nENDIF\nIF c<0.0\nRETURN 0.0\nENDIF\nIF d<0.0\nRETURN 0.0\nENDIF\n? a,b,c\nRETURN d',
'mixed-args':'? Last(17,1.250,.T.,2.50,19)\nRETURN\nFUNCTION Last(a,b,c,d,e)\nIF a<0\nRETURN 0.0\nENDIF\nIF b<0.0\nRETURN 0.0\nENDIF\nIF d<0.0\nRETURN 0.0\nENDIF\nIF e<0\nRETURN 0.0\nENDIF\nIF c\n? a,b,d,e\nENDIF\nRETURN d',
}
# More source values test literal/copy/call provenance beyond host-model kernels.
values=['0.0','-0.0','1.250','-1.250','9999999999.0','10000000000.0','-999999999.0','-1000000000.0','0.0000000000000001']
for i,v in enumerate(values):
 pos['literal-transport-'+str(i)]=f'LOCAL a:={v}\nLOCAL b:=a\n? a,b,Identity(a),Identity(Identity(b))\nRETURN\nFUNCTION Identity(n)\nIF n<0.0\nRETURN n\nENDIF\nRETURN n'
# Source comparison truth tables with runtime loads, not constant folding.
for i,(a,b)in enumerate([(x,y)for x,y in [('0.0','-0.0'),('1.25','2.5'),('2.5','1.25'),('-1.25','-1.25'),('10000000000.0','9999999999.0')]]):
 pos['loaded-comparison-'+str(i)]=f'LOCAL a:={a}\nLOCAL b:={b}\n? '+','.join('a'+op+'b'for op in ['=','==','<>','<','<=','>','>='])
neg={
'runtime-add':'LOCAL x:=1.25\n? x+1.0',
'runtime-zero-div':'LOCAL x:=1.25\n? x/0.0',
'dec17':'? 0.12345678901234567',
'dead-arithmetic':'IF .F.\nLOCAL x:=1.25\n? x+2.0\nENDIF',
'unused-arithmetic':'RETURN\nFUNCTION Never()\nLOCAL x:=1.25\nRETURN x+1.0',
'float-try':'TRY\n? 1.25\nCATCH\n? 2.50\nEND',
}
# Current source accepts scalar signatures but the pair convention cannot pack
# five F64 arguments in eight GPR words. This is a deliberate no-output reject.
neg['five-floats']='? Last(1.0,2.0,3.0,4.0,5.0)\nRETURN\nFUNCTION Last(a,b,c,d,e)\n'+''.join(f'IF {x}<0.0\nRETURN 0.0\nENDIF\n'for x in'abcde')+'RETURN e'
neg['unused-dec17']='RETURN\nFUNCTION Never()\nRETURN 0.12345678901234567'
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
 dest.write_bytes(b'existing-output-canary');again=run(r/'hbc-arm64-research',f,dest,'--target=macho-arm64');assert again.returncode!=0 and dest.read_bytes()==b'existing-output-canary';dest.unlink()
 records.append({'name':name,'rejected':result.stderr.decode()})
(out/'results.json').write_text(json.dumps({'positive':len(pos),'modes':3,'negative':len(neg),'scope':'separate copied finite literal/copy/call AST proof, no runtime arithmetic AST or production support','cases':records},indent=2)+'\n')
print(len(pos),'source pair transport controls x3 exact;',len(neg),'fail-closed negatives')

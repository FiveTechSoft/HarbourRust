"""Source literal transport plus explicit raw metadata injection, no arithmetic AST."""
from pathlib import Path
import subprocess,importlib.util,struct,json
from unicorn.arm64_const import UC_ARM64_REG_FP
r=Path(__file__).resolve().parent;out=r/'i64-transport-cases';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
cases={
'chain':('''FUNCTION Main()
LOCAL x:=10000000000
? "inject"
LOCAL y:=F(x)
? "maincheck"
? x,y
RETURN
FUNCTION F(n)
IF n<0
RETURN n
ENDIF
? "fcheck"
LOCAL y:=G(n)
? "freturn"
RETURN y
FUNCTION G(n)
IF n<0
RETURN n
ENDIF
? "gcheck"
RETURN n
''',{'inject':[(8,0)],'fcheck':[(8,0)],'gcheck':[(8,0)],'freturn':[(8,0),(24,0)],'maincheck':[(8,0),(24,0)]}),
'eight':('''FUNCTION Main()
'''+''.join(f'LOCAL x{i}:={10000000000+i}\n'for i in range(8))+'''? "inject"
LOCAL y:=F('''+','.join('x'+str(i)for i in range(8))+''')
? "maincheck"
? y
RETURN
FUNCTION F(a,b,c,d,e,f,g,h)
IF a<0
RETURN h
ENDIF
IF b<0
RETURN h
ENDIF
IF c<0
RETURN h
ENDIF
IF d<0
RETURN h
ENDIF
IF e<0
RETURN h
ENDIF
IF f<0
RETURN h
ENDIF
IF g<0
RETURN h
ENDIF
IF h<0
RETURN h
ENDIF
? "eightcheck"
RETURN h
''',{'inject':[(8+16*i,i%2)for i in range(8)],'eightcheck':[(8+16*i,i%2)for i in range(8)],'maincheck':[(136,1)]}),
}
records=[]
for name,(source,checks)in cases.items():
 f=out/(name+'.prg');f.write_text(source);arm=out/(name+'.arm');linux=out/(name+'.linux')
 for compiler,target,dest in[(r/'hbc-arm64-research','macho-arm64',arm),(r/'hbc-baseline','linux',linux)]:
  p=subprocess.run([str(compiler),str(f),str(dest),'--target='+target],capture_output=True);assert p.returncode==0,p.stderr
 ref=subprocess.run([str(linux)],capture_output=True);assert ref.returncode==0 and not ref.stderr
 for short,intr,fp in[(None,False,(0,0)),(1,False,(3<<22|1<<24,0x0800009f)),(3,True,(1<<22|1<<25,0x1f))]:
  got=m.execute(arm,short,intr,fp_state=fp);assert got['rc']==0 and bytes.fromhex(got['stdout_hex'])==ref.stdout
  seen=set()
  def observe(uc,n,args):
   if n!=4:return
   text=bytes(uc.mem_read(args[1],args[2])).decode()
   if text not in checks or text in seen:return
   seen.add(text);base=uc.reg_read(UC_ARM64_REG_FP)
   # rt_write has its own native frame; caller source FP is its saved x29.
   base=struct.unpack('<Q',uc.mem_read(base,8))[0]
   for off,want in checks[text]:
    if text=='inject':uc.mem_write(base-off,struct.pack('<Q',want))
    else:assert struct.unpack('<Q',uc.mem_read(base-off,8))[0]==want,(name,text,off,want)
  got=m.execute(arm,short,intr,fp_state=fp,observer=observe);assert got['rc']==0 and seen==set(checks),(name,seen)
 records.append({'name':name,'modes':3,'source_output_exact':True,'raw_injected_metadata_preserved':True,'markers':list(checks)})
(out/'results.json').write_text(json.dumps({'cases':records,'scope':'literal source transport plus explicit raw local metadata injection; no source computed-I64 arithmetic admission'},indent=2)+'\n')
print(len(cases),'source programs x3 exact; raw injected metadata survives nested/eight-argument calls and return/copy')

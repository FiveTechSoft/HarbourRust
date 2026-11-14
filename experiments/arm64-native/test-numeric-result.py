"""Raw kernel/result contract controls, deliberately not source ARM codegen."""
from pathlib import Path
import subprocess,importlib.util,json,struct,os
r=Path(__file__).resolve().parent;out=r/'numeric-result-cases';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
def run(*args):return subprocess.run(list(map(str,args)),capture_output=True)
def bits(v):return struct.unpack('<Q',struct.pack('<d',float(v)))[0]
mask=(1<<64)-1
vals=['0','1','-1','9999999999','10000000000','-999999999','-1000000000','9223372036854775807','(-9223372036854775807-1)','1.250','-0.0']
def pair(v):
 if '.'in v:return bits(v),(10<<16)|len(v.split('.')[1])
 return ((-2**63 if v.startswith('(')else int(v))&mask),1
cases=[];rows=[]
for i,(a,b)in enumerate([(x,'1')for x in vals]+[('9223372036854775807','2'),('(-9223372036854775807-1)','-1'),('1.250','2.50'),('1.250','0'),('1','-0.0')]):
 for op in '+-*/':
  for mode in [0,1]:
   name=f'op-{i}-{ord(op)}-{mode}';pa,fa=pair(a);pb,fb=pair(b)
   if mode==0 and fa==fb==1 and op in '+-*':
    ia=pa-(1<<64)if pa>>63 else pa;ib=pb-(1<<64)if pb>>63 else pb
    z={'+':lambda:ia+ib,'-':lambda:ia-ib,'*':lambda:ia*ib}[op]()
    if not -2**63<=z<2**63:continue # fixed I64 wraps; private mixed kernel does not
   prefix=''if mode==0 else ('IF .F.\nx:='+('1'if fa>1 else'1.0')+'\nENDIF\n')
   expr=f'x{op}y';body=f'LOCAL z:={expr}\n? z'if mode==0 else f'LOCAL z:=0\nz:={expr}\n? z'
   f=out/(name+'.prg');f.write_text(f'FUNCTION Main()\nLOCAL x:={a}\nLOCAL y:={b}\n{prefix}{body}\nRETURN\n')
   linux=out/(name+'.linux');p=run(r/'hbc-baseline',f,linux,'--target=linux');assert p.returncode==0,(name,p.stderr)
   ref=run(linux);assert ref.returncode in[0,1]and not ref.stderr
   cases.append((name,ref.returncode,ref.stdout));rows.append([name,op,pa,fa,pb,fb,0,mode])
# Raw result words test provenance and metadata without inventing source support.
for i,n in enumerate([0,1,-1,9999999999,10000000000,-999999999,-1000000000,2**63-1,-2**63]):
 for form in[0,1]:
  name=f'raw-int-{i}-{form}';text=str(n);w=(10 if len(text)<=10 else 20)if form==0 else(20 if n<0 and len(text)>10 else max(10,len(text)+1)if n>=0 else 10)
  f=out/(name+'.prg');literal=str(n)if n!=-2**63 else'(-9223372036854775807-1)'
  f.write_text(f'FUNCTION Main()\nLOCAL x:={literal}\nLOCAL y:=0\nLOCAL z:='+('x+y'if form==0 else'x')+'\n? z\nRETURN\n')
  dest=out/(name+'.linux');p=run(r/'hbc-baseline',f,dest,'--target=linux');assert p.returncode==0,p.stderr
  ref=run(dest);assert ref.returncode==0 and not ref.stderr and ref.stdout==b'\n'+text.rjust(w).encode()
  cases.append((name,0,ref.stdout));rows.append([name,'r',n&mask,form,0,0,0,0])
invalid=[(bits(1),3,0,0),(bits(1),10<<16|17,0,0),(bits(1),30<<16,0,0),(bits(float('inf')),10<<16,0,0),(0x7ff8000000000123,10<<16,0,0),(1,1,2,0),(1,1,3,0),(1,1,99,0),(1,1,0,2)]
for i,(p,f,status,mode)in enumerate(invalid):
 name=f'invalid-{i}';cases.append((name,75,b''));rows.append([name,'r',p,f,0,0,status,mode])
(out/'cases.tsv').write_text('\n'.join('\t'.join(map(str,row))for row in rows)+'\n')
p=run(os.environ.get('RUSTC','rustc'),'--edition=2021','-O','-C','strip=symbols',r/'result-fixtures.rs','-o',r/'result-fixtures');assert p.returncode==0,p.stderr
p=run(r/'result-fixtures',out);assert p.returncode==0,p.stderr
records=[]
for name,rc,want in cases:
 for short,intr,fp in[(None,False,(0,0)),(1,False,(3<<22|1<<24,0x0800009f)),(3,True,(1<<22|1<<25,0x1f))]:
  got=m.execute(out/(name+'.arm'),short,intr,fp_state=fp);assert got['rc']==rc and bytes.fromhex(got.pop('stdout_hex'))==want,(name,short,got,want)
 if want:
  for fault in ['zero','oversize','failure']:
   got=m.execute(out/(name+'.arm'),failure=fault=='failure',fault=None if fault=='failure'else fault)
   assert got['rc']==74 and got['stdout_hex']=='',(name,fault,got)
 records.append({'name':name,'exit':rc,'modes':3,'stdout':want.decode(),'io_failure_controls':3 if want else 0})
(out/'results.json').write_text(json.dumps({'cases':records,'count':len(cases),'modes':3,'source_codegen':False,'scope':'raw own numeric kernel + validated result output, current x86 controls; not ARM source arithmetic or caught exceptions'},indent=2)+'\n')
print(len(cases),'raw result controls x3 exact, no source arithmetic admission')

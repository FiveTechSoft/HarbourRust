"""Differential isolated AST experiment against current hbc Linux backend.
Execution here means ARM64 instruction emulation plus our syscall model, NOT Mac.
"""
from pathlib import Path
import subprocess,sys,json,importlib.util,struct
r=Path(__file__).resolve().parent;out=r/'scalar-battery';out.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');emu=importlib.util.module_from_spec(s);s.loader.exec_module(emu)
# Optional development packages are imported normally from PYTHONPATH/venv.
from capstone import Cs,CS_ARCH_ARM64,CS_MODE_ARM
from capstone.arm64 import ARM64_REG_X18
cs=Cs(CS_ARCH_ARM64,CS_MODE_ARM);cs.detail=True
pos={
'empty':'',
'newline':'?\n?',
'inline-empty':'??\n??',
'literals':'? 0,1,42,9999999999,10000000000,9223372036854775807',
'negative':'? -1,-999999999,-1000000000,-9223372036854775808',
'logical':'? .T.,.F.,.NOT. .T.,.NOT. .F.',
'unicode':'? "hola", "áéí", "東京"',
'locals':'LOCAL a:=1\nLOCAL b:=a\n? a,b\na:=9223372036854775807\nb:=a\n? b',
'assign-bool':'LOCAL a:=.F.\na:=.T.\n? a',
'assign-seq':'LOCAL a:=1\n? (a:=9),a\n? (a:=3,a:=5,a),a',
'if-else':'IF 1<2\n? "then"\nELSE\n? "bad"\nENDIF\nIF 1>2\n? "bad"\nELSE\n? "else"\nENDIF',
'nested-if':'IF .T.\nIF .F.\n? "bad"\nELSE\n? "nested"\nENDIF\nENDIF',
'while':'LOCAL go:=.T.\nDO WHILE go\n? "once"\ngo:=.F.\nENDDO',
'while-exit':'DO WHILE .T.\n? "once"\nEXIT\n? "never"\nENDDO',
'while-loop':'LOCAL go:=.T.\nDO WHILE go\ngo:=.F.\nLOOP\n? "never"\nENDDO\n? "done"',
'inline':'?? "one",1\n?? "two",2\n? "three",3',
'early-return':'? "before"\nIF .T.\nRETURN\nENDIF\n? "unreachable"',
'call-print-first':'? Before(),After()\nRETURN\nFUNCTION Before()\n? "before"\nRETURN 11\nFUNCTION After()\n? "after"\nRETURN 22',
'call-void':'Side()\n? "done"\nRETURN\nFUNCTION Side()\n? "effect"\nRETURN',
'call-param':'? Echo(99)\nRETURN\nFUNCTION Echo(n)\nIF n<0\nRETURN 0\nENDIF\nRETURN n',
'call-bool':'? Flip(.T.),Flip(.F.)\nRETURN\nFUNCTION Flip(b)\nIF b\nRETURN .F.\nENDIF\nRETURN .T.',
'recursion':'? Recur(.T.)\nRETURN\nFUNCTION Recur(b)\nIF b\nRETURN Recur(.F.)\nENDIF\nRETURN 17',
'short-circuit':'? .F. .AND. Side(), .T. .OR. Side(), .T. .AND. Side(), .F. .OR. Side()\nRETURN\nFUNCTION Side()\n? "effect"\nRETURN .T.',
'call-stack-local':'LOCAL a:=123\n? a,Echo(a),a\nRETURN\nFUNCTION Echo(n)\nLOCAL b:=n\nIF n<0\nRETURN 0\nENDIF\nRETURN b',
'constant-fold':'? 2+3,2*7,8-5,8/2',
}
for i,op in enumerate(['=','==','<>','<','<=','>','>=']):
 pos[f'cmp-{i}']='? '+','.join(f'({a}{op}{b})'for a,b in [(0,0),(1,2),(2,1),(-9223372036854775808,9223372036854775807),(9223372036854775807,-9223372036854775808)])
params=','.join('abcdefgh')
checks='\n'.join('IF '+n+'<0\nRETURN 0\nENDIF'for n in 'abcdefgh')
pos['eight-args']='? Last(1,2,3,4,5,6,7,8)\nRETURN\nFUNCTION Last('+params+')\n'+checks+'\nRETURN h'
neg={
'runtime-div':'LOCAL x:=8\n? x/2',

'static':'STATIC n:=1\n? n',
'heap':'LOCAL a:={1,2}\n? a',
'string-local':'LOCAL s:="str"\n? s',
'pending-empty':'? ""',
'pending-space':'? "tail "',
'pending-multiline':'? "a"+Chr(10)+"b"',
'builtin':'? Len("a")',
'for':'LOCAL n:=0\nFOR n:=1 TO 3\n? n\nNEXT',
'nil':'? NIL',
'dead-code-static':'IF .F.\nSTATIC n:=1\nENDIF',
'dead-after-return':'RETURN\nLOCAL x:=1.25\n? x+1.0',
'try':'TRY\n? "x"\nCATCH\n? "y"\nEND',
'dead-try':'IF .F.\nTRY\n? "x"\nCATCH\n? "y"\nEND\nENDIF',
}
pos['nested-eight-args']='? Last('+','.join('Echo('+str(i)+')'for i in range(1,9))+')\nRETURN\nFUNCTION Last('+params+')\n'+checks+'\nRETURN h\nFUNCTION Echo(n)\nIF n<0\nRETURN 0\nENDIF\n? n\nRETURN n'
pos['nested-loops']='LOCAL go:=.T.\nDO WHILE go\nDO WHILE .T.\n? "inner"\nEXIT\nENDDO\n? "outer"\ngo:=.F.\nENDDO'
pos['short-circuit-set']='LOCAL b:=.F.\n? .T. .OR. (b:=.T.),b\n? .F. .AND. (b:=.T.),b'
neg['dead-short-circuit']='? .F. .AND. (Len("a")=1)'
neg['unused-heap-function']='RETURN\nFUNCTION Never()\nLOCAL a:={1}\nRETURN 0'
neg['recursion-dyn-return']=pos.pop('recursion')
records=[]
def run(argv):return subprocess.run(list(map(str,argv)),capture_output=True)
def source(body):return 'FUNCTION Main()\n'+body+('\n' if '\nFUNCTION ' in body else '\nRETURN\n')
for name,body in pos.items():
 f=out/(name+'.prg');f.write_text(source(body).replace('-9223372036854775808','(-9223372036854775807-1)'));arm=out/(name+'.arm');lin=out/(name+'.linux')
 a=run([r/'hbc-arm64-research',f,arm,'--target=macho-arm64']);assert a.returncode==0,(name,a.stderr.decode())
 b=run([r/'hbc-baseline',f,lin,'--target=linux']);assert b.returncode==0,(name,b.stderr.decode())
 l=run([lin]);assert l.returncode==0,(name,l.stderr.decode())
 modes=[]
 for short,intr in [(None,False),(1,False),(3,True)]:
  v=emu.execute(arm,short,intr);assert v['rc']==0,(name,v);got=bytes.fromhex(v.pop('stdout_hex'));assert got==l.stdout,(name,got,l.stdout);modes.append({'short':short,'eintr':intr,**v})
 # Decode every instruction, including unreachable code. Never reserve x18.
 data=arm.read_bytes();offset=32;code=None
 for _ in range(struct.unpack_from('<I',data,16)[0]):
  cmd,n=struct.unpack_from('<II',data,offset)
  if cmd==25:
   for j in range(struct.unpack_from('<I',data,offset+64)[0]):
    p=offset+72+j*80
    if data[p:p+16].split(b'\0')[0]==b'__text':
     size,off=struct.unpack_from('<QI',data,p+40);code=data[off:off+size]
  offset+=n
 assert code is not None
 decoded=list(cs.disasm(code,0));assert len(decoded)*4==len(code)
 for ins in decoded:
  regs=set(sum((list(x)for x in ins.regs_access()),[]));assert ARM64_REG_X18 not in regs,(name,ins.mnemonic,ins.op_str)
 records.append({'name':name,'status':'emulated-exact-linux-baseline','stdout_bytes':len(l.stdout),'instructions_static':len(decoded),'modes':modes})
for name,body in neg.items():
 f=out/(name+'.prg');f.write_text(source(body).replace('-9223372036854775808','(-9223372036854775807-1)'));arm=out/(name+'.arm');arm.unlink(missing_ok=True)
 a=run([r/'hbc-arm64-research',f,arm,'--target=macho-arm64']);assert a.returncode!=0 and not arm.exists(),name
 records.append({'name':name,'status':'rejected-no-output','diagnostic':a.stderr.decode().strip()})
for flag in ['--instrument','--experimental-llvm','--external-as']:
 f=out/'empty.prg';arm=out/('flag-'+flag[2:]+'.arm');arm.unlink(missing_ok=True)
 a=run([r/'hbc-arm64-research',f,arm,'--target=macho-arm64',flag]);assert a.returncode!=0 and not arm.exists(),flag
 records.append({'name':flag,'status':'flag-rejected-no-output','diagnostic':a.stderr.decode().strip()})
# The untouched compiler must still reject even the easiest ARM source.
a=run([r/'hbc-baseline',out/'empty.prg',out/'production-arm','--target=macho-arm64']);assert a.returncode!=0 and b'not implemented' in a.stderr
(out/'results.json').write_text(json.dumps({'base':'e5bf1bb640fb4befcd661e65bb75ba501f3c5ab9','positive':len(pos),'negative':len(neg),'production_arm_still_rejects':True,'scope':'isolated frontend copy, ARM64 emulator + own syscall model; no macOS loading/execution','cases':records},indent=2)+'\n')
print(len(pos),'positive x3 model modes differential-exact;',len(neg),'negative no-output; real hbc ARM rejection intact')

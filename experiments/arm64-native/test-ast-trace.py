"""Observe source-mapped native records during real checked scalar AST calls."""
from pathlib import Path
import subprocess,importlib.util,json,struct
from unicorn.arm64_const import UC_ARM64_REG_X19
r=Path(__file__).resolve().parent;out=r/'ast-trace-cases';out.mkdir(exist_ok=True)
spec=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
program='''FUNCTION Main()
LOCAL go:=1
? Outer(8)
DO WHILE Again(go)>0
go:=0
? "body"
ENDDO
#include "line-origin.ch"
RETURN
FUNCTION Outer(n)
IF n<0
RETURN 0
ENDIF
LOCAL a:=n
? "outer"
RETURN Leaf(a)
FUNCTION Leaf(n)
IF n<0
RETURN 0
ENDIF
LOCAL b:=n
? "leaf"
RETURN b
FUNCTION Again(go)
? "condition"
IF go>0
RETURN 1
ENDIF
RETURN 0
'''
f=out/'native-chain.prg';f.write_text(program);inc=out/'line-origin.ch';inc.write_text('? "included"\n')
arm=out/'native-chain.arm';lin=out/'native-chain.linux'
def compile(compiler,src,dest,target):
 v=subprocess.run([str(compiler),str(src),str(dest),'--target='+target],capture_output=True)
 assert v.returncode==0,v.stderr.decode()
compile(r/'hbc-arm64-research',f,arm,'macho-arm64');compile(r/'hbc-baseline',f,lin,'linux')
ref=subprocess.run([str(lin)],capture_output=True);assert ref.returncode==0 and not ref.stderr
snapshots=[]
def observe(u,n,args):
 if n!=4:return
 fd,p,length=args;data=bytes(u.mem_read(p,length));top=u.reg_read(UC_ARM64_REG_X19);chain=[]
 while top:
  assert len(chain)<100,'cycle/dead frame'
  prev,textp,textlen=struct.unpack('<3Q',bytes(u.mem_read(top,24)))
  chain.append(bytes(u.mem_read(textp,textlen)).decode()if textlen else '')
  top=prev
 snapshots.append({'data':data.decode(),'chain':chain})
got=m.execute(arm,observer=observe);assert bytes.fromhex(got.pop('stdout_hex'))==ref.stdout
# Every syscall must have valid youngest-first metadata. Check source origins,
# call-site parent lines, return restoration, and second WHILE condition refresh.
def chain(*items):return [f'  at {name} ({path}:{line})\n'for name,path,line in items]
line=lambda text:program.splitlines().index(text)+1
expected={
 'outer':chain(('outer',f,line('? "outer"')),('main',f,3)),
 'leaf':chain(('leaf',f,line('? "leaf"')),('outer',f,line('RETURN Leaf(a)')),('main',f,3)),
 'condition':chain(('again',f,line('? "condition"')),('main',f,4)),
 'body':chain(('main',f,6)),
 'included':chain(('main',inc,1)),
}
seen={k:0 for k in expected}
for row in snapshots:
 assert row['chain']
 if row['data']in expected:
  assert row['chain']==expected[row['data']],row
  seen[row['data']]+=1
assert seen=={'outer':1,'leaf':1,'condition':2,'body':1,'included':1},seen
(out/'results.json').write_text(json.dumps({'observed_writes':len(snapshots),'named_checks':seen,'stdout_bytes':len(ref.stdout),'scope':'checked scalar AST/native source frame metadata under emulator vs current native x86 stdout, no numeric AST/TRY admission','snapshots':snapshots},indent=2)+'\n')
print(len(snapshots),'source AST syscall observations; nested calls, locals, early return, loop refresh and include origin exact')
# Trace storage must not consume any of the established 255 scalar local slots.
for count in [255,256]:
 f=out/f'frame-{count}.prg';f.write_text('FUNCTION Main()\n'+''.join(f'LOCAL v{i}:={i}\n'for i in range(count))+f'? v{count-1}\nRETURN\n')
 arm=out/f'frame-{count}.arm';arm.unlink(missing_ok=True)
 result=subprocess.run([str(r/'hbc-arm64-research'),str(f),str(arm),'--target=macho-arm64'],capture_output=True)
 if count==255:
  assert result.returncode==0,result.stderr.decode()
  lin=out/f'frame-{count}.linux';compile(r/'hbc-baseline',f,lin,'linux')
  ref=subprocess.run([str(lin)],capture_output=True)
  got=m.execute(arm);assert got['rc']==ref.returncode==0 and bytes.fromhex(got['stdout_hex'])==ref.stdout
 else:assert result.returncode!=0 and b'frame exceeds 4080 bytes'in result.stderr and not arm.exists()
p=out/'results.json';d=json.loads(p.read_text());d['old_frame_255_locals_preserved']=True;d['frame_256_rejects_no_output']=True;p.write_text(json.dumps(d,indent=2)+'\n')
print('Existing255-local frame limit preserved;256locals still fail-closed')

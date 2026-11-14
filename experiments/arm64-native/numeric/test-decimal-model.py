"""Design-model differential against existing x86 helper, NOT Harbour or ARM."""
from pathlib import Path
import struct,subprocess,random,json,math
r=Path(__file__).resolve().parent;src=(Path(__import__('os').environ['HARBOURRUST_REPO'])/'src'/'hbc.rs').read_text()
helper=src.split('const F64_HELPER: &str = r#"',1)[1].split('"#;',1)[0]
# Include only integer formatter referenced by the mixed integral fast path.
a=src.index('\nhbc_print_i64c:',src.index('const HELPERS_WIN')) if 'const HELPERS_WIN'in src else src.rindex('\nhbc_print_i64c:')
a=src.rindex('\nhbc_print_i64c:');end=src.index('\n# hbc_print_dyn:',a)
integer=src[a:end]
rng=random.Random(6436);cases=[]
base=[0.,-0.,0.125,0.665,9.995,0.0999,1.5,2.25,1e-17,1e-18,1e19,1e20,9007199254740992.,9007199254740994.,float(-2**63),float(2**63),float('inf'),float('-inf'),float('nan')]
for v in base:
 for dec in [0,1,2,6,17,255,435]:
  for length in [10,20]:
   for mixed in [0,1]:cases.append((v,length,dec,mixed))
for _ in range(2000):
 v=rng.uniform(-1.,1.)*10**rng.randrange(-17,21);dec=rng.choice([0,1,2,3,9,17,35]);length=rng.choice([10,20]);mixed=rng.randrange(2);cases.append((v,length,dec,mixed))
cases=[c for c in cases if not(math.isfinite(c[0])and c[2]==435 and abs(c[0])>=1e19)]
assembly=['.text','.global _start','_start:']
for v,length,dec,mixed in cases:
 bits=struct.unpack('<Q',struct.pack('<d',v))[0]
 assembly.extend([f'movabs ${bits},%rax','movq %rax,%xmm0',f'mov ${length<<16|dec},%edi',f'call '+('hbc_print_num_f64'if mixed else'hbc_print_f64'),'lea delimiter(%rip),%rax','mov $1,%edx','call hbc_print_str'])
assembly.extend(['mov $60,%eax','xor %edi,%edi','syscall',helper,integer,'''
hbc_print_str:
 push %rax
 push %rdi
 push %rsi
 push %rcx
 push %r11
 mov %rax,%rsi
 mov $1,%eax
 mov $1,%edi
 syscall
 pop %r11
 pop %rcx
 pop %rsi
 pop %rdi
 pop %rax
 ret
hbc_f64range_error:
 mov $60,%eax
 mov $99,%edi
 syscall
.section .rodata
.Lpad20:
 .ascii "                    "
delimiter:
 .byte 0
'''])
(r/'decimal-reference.s').write_text('\n'.join(assembly))
subprocess.run(['as','decimal-reference.s','-o','decimal-reference.o'],cwd=r,check=True)
subprocess.run(['ld','-o','decimal-reference','decimal-reference.o'],cwd=r,check=True)
p=subprocess.run([str(r/'decimal-reference')],capture_output=True);assert p.returncode==0,p.returncode
reference=p.stdout.split(b'\0');assert reference.pop()==b'';assert len(reference)==len(cases)
inputs=b''.join(struct.pack('<dIIB',*c)for c in cases)
p=subprocess.run([str(r/'decimal-model')],input=inputs,capture_output=True);assert p.returncode==0,p.stderr
out=p.stdout;off=0;different=[]
for i,(case,want)in enumerate(zip(cases,reference)):
 n=struct.unpack_from('<I',out,off)[0];off+=4;got=out[off:off+n];off+=n
 if got!=want:different.append({'case':i,'value':repr(case[0]),'length':case[1],'dec':case[2],'mixed':case[3],'model':got.decode(),'x86':want.decode()})
assert off==len(out)
(r/'decimal-model-results.json').write_text(json.dumps({'cases':len(cases),'exact':len(cases)-len(different),'differences':different,'scope':'host Rust design model vs existing x86 helper, neither ARM runtime nor Harbour oracle'},indent=2)+'\n')
print(len(cases),'decimal cases,',len(different),'differences')
for d in different[:10]:print(d)
assert not different

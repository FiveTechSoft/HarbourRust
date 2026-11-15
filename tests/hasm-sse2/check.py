#!/usr/bin/env python3
"""Instruction byte oracle. Containers verified without a native Mac claim."""
import argparse,pathlib,subprocess,struct,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--driver',required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
regs=['%xmm0','%xmm3','%xmm8','%xmm15'];mem=['(%rax)','(%r8)','8(%rbp)','-128(%r13)','128(%rsp)','4096(%r12,%r9,4)'];cases=[]
for m in ['movdqu','movdqa','pcmpeqb','pcmpgtb','pand','pxor','punpcklbw','punpcklwd']:
 for d in regs:
  for src in regs+mem:cases.append(f'{m} {src}, {d}')
 if m=='movdqu':
  for src in regs:
   for d in mem:cases.append(f'{m} {src}, {d}')
for g in ['%eax','%r8d','%r15d']:
 for x in regs:cases.extend([f'movd {g}, {x}',f'pmovmskb {x}, {g}'])
for d in regs:
 for src in regs+mem:
  for imm in [0,27,255]:cases.append(f'pshufd ${imm}, {src}, {d}')
for d in ['%eax','%r8d','%r15d']:
 for src in ['%eax','%ecx','%r8d','%r15d']+mem:cases.append(f'bsf {src}, {d}')
# Fixed .text constant target exercises RIP relative displacement resolution.
for m in ['movdqu','movdqa','pcmpeqb','pcmpgtb','pand','pxor','punpcklbw','punpcklwd']:
 cases.append(f'{m} datum(%rip), %xmm9')
cases.append('pshufd $27, datum(%rip), %xmm10')
# GNU-as oracle deliberately includes only instructions, never executed.
source='.text\n.globl _start\n_start:\n'+'\n'.join(cases)+'\nret\ndatum: .byte 90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90\n';src=a.output/'all.s';src.write_text(source)
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,timeout=30)
q=run(['as',src,'-o',a.output/'gnu.o']);assert q.returncode==0,q.stderr
q=run(['objcopy','-O','binary','-j','.text',a.output/'gnu.o',a.output/'gnu.text']);assert q.returncode==0,q.stderr
want=(a.output/'gnu.text').read_bytes()
def text(blob,target):
 if target=='elf':
  off=struct.unpack_from('<Q',blob,40)[0];n=struct.unpack_from('<H',blob,60)[0]
  for i in range(n):
   k=off+64*i;flags=struct.unpack_from('<Q',blob,k+8)[0]
   if flags&4:
    start,size=struct.unpack_from('<QQ',blob,k+24);return blob[start:start+size]
 if target=='pe':
  p=struct.unpack_from('<I',blob,60)[0];n=struct.unpack_from('<H',blob,p+6)[0];opt=struct.unpack_from('<H',blob,p+20)[0]
  for i in range(n):
   k=p+24+opt+40*i
   if blob[k:k+5]==b'.text':size=struct.unpack_from('<I',blob,k+8)[0];start=struct.unpack_from('<I',blob,k+20)[0];return blob[start:start+size]
 if target=='macho':
  k=32
  for i in range(struct.unpack_from('<I',blob,16)[0]):
   cmd,size=struct.unpack_from('<II',blob,k)
   if cmd==0x19 and blob[k+8:k+14]==b'__TEXT':start,length=struct.unpack_from('<QQ',blob,k+40);return blob[4096:start+length]
   k+=size
 raise AssertionError(('text missing',target))
rows=[]
for target in ['elf','pe','macho']:
 out=a.output/target;targetsrc=src
 if target=='pe':
  targetsrc=a.output/'pe.s';targetsrc.write_text(source+'call ExitProcess\n')
 q=run([a.driver,target,targetsrc,out]);assert q.returncode==0,(target,q.stderr)
 got=text(out.read_bytes(),target);assert got[:len(want)]==want,(target,len(got),len(want),next((i for i,(x,y) in enumerate(zip(got,want)) if x!=y),None));rows.append(dict(target=target,instructions=len(cases),bytes=len(want),sha256=hashlib.sha256(want).hexdigest()))
# No panics or partial output for unsupported forms, widths or immediates.
invalid=['movd %rax, %xmm0','movd %xmm0, %eax','movdqu %eax, %xmm0','movdqa %xmm0, (%rax)','pmovmskb %xmm0, %rax','pshufd $256, %xmm0, %xmm1','pshufd $-1, %xmm0, %xmm1','pshufd %eax, %xmm0, %xmm1','bsf %rax, %eax','bsf %eax, %rax']
for i,ins in enumerate(invalid):
 path=a.output/f'bad{i}.s';path.write_text('.text\n.globl _start\n_start:\n'+ins+'\nret\n');out=a.output/f'bad{i}';q=run([a.driver,'elf',path,out]);assert q.returncode!=0 and b'panicked' not in q.stderr and not out.exists(),(ins,q.returncode,q.stderr);(a.output/f'bad{i}.stderr').write_bytes(q.stderr)
(a.output/'results.json').write_text(json.dumps({'rows':rows,'negative_forms':len(invalid)},indent=2)+'\n');print(len(cases),'instructions x3 targets,',len(invalid),'negatives PASS')

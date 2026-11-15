#!/usr/bin/env python3
"""GNU as/ld StrTran helper canaries: bytes, ABI, headers, logical balance."""
import argparse,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--compiler',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.compiler=a.compiler.resolve();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
cases=[]
for seek in [b'a',b'aa',b'aba']:
 for start,count in [(0,1),(1,0),(-1,2),(1,-2),(2,-1),(2,1),(2,17),(1,18),(99,3)]:
  for repl in [b'',b'X',b'YZ']:
   cases.append((b'abaaababa',seek,repl,start,count))
cases.extend([(b'ab'*50,b'a',b'XYZ',2,17),(b'ab'*50,b'a',b'',17,18),(b'A\0BA\0B',b'\0',b'XY',2,1),(b'abc',b'',b'X',0,1),(b'abc',b'',b'X',1,0)])
rows=[]
for index,(text,seek,repl,start,count) in enumerate(cases):
 expected=b'' if start==0 or count==0 else text
 if start>0 and count!=0 and seek:
  i=0;found=0;used=0;out=bytearray()
  while i<len(text):
   if text.startswith(seek,i):
    found+=1
    if found>=start and (count<0 or used<count):out.extend(repl);used+=1
    else:out.extend(seek)
    i+=len(seek)
   else:out.append(text[i]);i+=1
  expected=bytes(out)
 for instrument in [False,True]:
  label=str(index)+'-'+str(instrument);src=a.output/(label+'.prg');asm=src.with_suffix('.s');obj=src.with_suffix('.o');exe=src.with_suffix('.program')
  src.write_text('function Main()\nreturn nil\n')
  cmd=[a.compiler,src,asm,'--target=linux']+(['--instrument'] if instrument else [])
  q=subprocess.run(list(map(str,cmd)),capture_output=True);assert q.returncode==0,q.stderr
  code=asm.read_text().replace('call hbc_fn_main','call hbc_strtran_test',1)
  code+='''
.text
hbc_strtran_test:
 push %rbp
 mov %rsp, %rbp
 push %rbx
 push %r12
 push %r13
 push %r14
 push %r15
 sub $24, %rsp
 mov $101, %ebx
 mov $102, %r12d
 mov $103, %r13d
 mov $104, %r14d
 mov $105, %r15d
 lea test_text(%rip), %rdi
 mov $TEXTLEN, %rsi
 lea test_seek(%rip), %rdx
 mov $SEEKLEN, %rcx
 lea test_repl(%rip), %r8
 mov $REPLLEN, %r9
 mov $START, %r10
 mov $COUNT, %r11
 call hbc_strtran_limit
 mov %rax, (%rsp)
 cmp $OUTLEN, %rdx
 jne .Lstrtran_abi_fail
 cmpq $OUTLEN, -16(%rax)
 jne .Lstrtran_abi_fail
 cmpq $OUTLEN, -8(%rax)
 jne .Lstrtran_abi_fail
 cmp $101, %rbx
 jne .Lstrtran_abi_fail
 cmp $102, %r12
 jne .Lstrtran_abi_fail
 cmp $103, %r13
 jne .Lstrtran_abi_fail
 cmp $104, %r14
 jne .Lstrtran_abi_fail
 cmp $105, %r15
 jne .Lstrtran_abi_fail
 mov %rsp, %rcx
 and $15, %ecx
 jnz .Lstrtran_abi_fail
 xor %ecx, %ecx
 lea test_expected(%rip), %rdi
1: cmp $OUTLEN, %rcx
 jae 2f
 movzbl (%rax,%rcx), %r8d
 cmp %r8b, (%rdi,%rcx)
 jne .Lstrtran_abi_fail
 inc %rcx
 jmp 1b
2: mov (%rsp), %rdi
 call hbc_freestr
 mov hbc_mem_allocs(%rip), %rax
 cmp hbc_mem_frees(%rip), %rax
 jne .Lstrtran_abi_fail
 add $24, %rsp
 pop %r15
 pop %r14
 pop %r13
 pop %r12
 pop %rbx
 pop %rbp
 ret
.Lstrtran_abi_fail:
 mov $60, %eax
 mov $99, %edi
 syscall
.section .rodata
'''.replace('START',str(start)).replace('COUNT',str(count)).replace('TEXTLEN',str(len(text))).replace('SEEKLEN',str(len(seek))).replace('REPLLEN',str(len(repl))).replace('OUTLEN',str(len(expected)))
  for name,data in [('text',text),('seek',seek),('repl',repl),('expected',expected)]:
   code+='test_'+name+': .byte '+','.join(map(str,data or b'\0'))+'\n'
  asm.write_text(code)
  for cmd in [['as',str(asm),'-o',str(obj)],['ld',str(obj),'-o',str(exe)]]:
   q=subprocess.run(cmd,capture_output=True);assert q.returncode==0,q.stderr
  q=subprocess.run([str(exe)],capture_output=True,timeout=30)
  assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(label,q.returncode,q.stderr)
  exe.unlink();obj.unlink();asm.unlink();src.unlink();rows.append(dict(case=index,instrument=instrument,exact=True,callee_saved=True,headers=True,logical_balance=True))
(a.output/'summary.json').write_text(json.dumps(rows,indent=2)+'\n')
print('PASS',len(rows),'GNU helper canaries')

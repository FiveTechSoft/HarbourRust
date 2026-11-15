#!/usr/bin/env python3
"""GNU as/ld StrTran helper canaries: bytes, ABI, headers, logical balance."""
import argparse,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--compiler',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.compiler=a.compiler.resolve();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
cases=[]
for seek in [b'a',b'aa',b'aba']:
 for replace in [b'',b'X',b'YZ',b'P\0Q',b'R'*129]:cases.append((b'abaaababa',seek,replace))
cases.extend([(b'A\0BA\0B',b'\0',b'XY'),(b'',b'a',b'X'),(b'abc',b'',b'X'),(b'aaaaa',b'aa',b'X'),(b'abc',b'z',b'X')])
rows=[]
for index,(text,seek,repl) in enumerate(cases):
 expected=text.replace(seek,repl) if seek else text
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
 call hbc_strtran
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
'''.replace('TEXTLEN',str(len(text))).replace('SEEKLEN',str(len(seek))).replace('REPLLEN',str(len(repl))).replace('OUTLEN',str(len(expected)))
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

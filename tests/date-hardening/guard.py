import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--driver',required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);r=a.output
src=r/'probe.prg';src.write_text('function Main()\n? CToD("")\nreturn nil\n');asm=r/'emitted.s';q=subprocess.run([a.compiler,str(src),str(asm)],capture_output=True);assert q.returncode==0,q.stderr;s=asm.read_text();helper=s[s.index('\nhbc_dtos:'):s.index('\n# hbc_stod:')]
# Empty path only, stub allocation returns an8byte payload ending at a guard.
code='''.text
.globl _start
_start:
 xor %edi,%edi
 mov $8192,%esi
 xor %edx,%edx
 mov $34,%r10d
 mov $-1,%r8
 xor %r9d,%r9d
 mov $9,%eax
 syscall
 test %rax,%rax
 js fail
 mov %rax,%r15
 mov %rax,%rdi
 mov $4096,%esi
 mov $3,%edx
 mov $10,%eax
 syscall
 test %rax,%rax
 jnz fail
 xor %edi,%edi
 call hbc_dtos
 cmp $8,%rdx
 jne fail
 movabs $0x2020202020202020,%r8
 cmp %r8,(%rax)
 jne fail
 mov $60,%eax
 xor %edi,%edi
 syscall
hbc_stralloc:
 cmp $8,%rsi
 jne fail
 lea 4088(%r15),%rax
 mov $8,%edx
 ret
fail:
 mov $60,%eax
 mov $99,%edi
 syscall
'''+helper
# Nonempty helper references no outside runtime, but include return label targets.
asm.write_text(code);exe=r/'guard';q=subprocess.run([a.driver,'elf',str(asm),str(exe)],capture_output=True);assert q.returncode==0,q.stderr;exe.chmod(0o755);q=subprocess.run([str(exe)],capture_output=True);assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(q.returncode,q.stderr);(r/'results.json').write_text(json.dumps({'payload8bytes_at_guard':True,'empty8spaces':True,'native_encoder':True})+'\n');print('exact8byte payload guard PASS')

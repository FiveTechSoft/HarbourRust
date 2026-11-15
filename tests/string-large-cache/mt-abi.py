#!/usr/bin/env python3
"""Two-thread GNU Linux cache-local accounting canary, normal mode only."""
import argparse,subprocess,json
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for k in ['compiler','output']:p.add_argument('--'+k,required=True,type=Path)
a=p.parse_args();a.output=a.output.resolve();a.compiler=a.compiler.resolve();a.output.mkdir(parents=True,exist_ok=False)
src=a.output/'mt.prg';asm=a.output/'mt.s';obj=a.output/'mt.o';exe=a.output/'mt.program'
src.write_text('procedure Main()\nlocal a:=hb_threadStart(@Worker())\nlocal b:=hb_threadStart(@Worker())\nhb_threadJoin(a)\nhb_threadJoin(b)\nreturn\nfunction Worker()\nreturn nil\n')
q=subprocess.run([str(a.compiler),str(src),str(asm)],capture_output=True);assert q.returncode==0,q.stderr
code=asm.read_text();assert 'hbc_fn_worker:' in code
# The worker's entry RSP is8mod16; align the injected call without disturbing
# the compiler's own function prologue, arguments or trace chain.
code=code.replace('hbc_fn_worker:','hbc_fn_worker:\n    sub $8,%rsp\n    call cache_mt_probe\n    add $8,%rsp',1)
body=['.text','cache_mt_probe:','push %rbp','mov %rsp,%rbp','sub $64,%rsp','mov %fs:120,%rax','mov %rax,48(%rsp)','movq $40,56(%rsp)']
for n in [65537,131072,262144,524288,1048576,1048577]:
 body += [f'.Lmt_cycle{n}:',f'mov ${n},%rsi','call hbc_stralloc','mov %rax,(%rsp)',f'cmp ${n},%rdx','jne cache_mt_fail','mov %rax,%rdi','call hbc_freestr','call cache_mt_check']
body += ['decq 56(%rsp)','jnz .Lmt_cycle65537','call hbc_str_cache_flush','mov %fs:48,%rax','cmpq $0,-64(%rax)','jne cache_mt_fail','mov %fs:120,%rax','cmp 48(%rsp),%rax','jne cache_mt_fail','leave','ret']
body += ['cache_mt_check:','mov %fs:48,%rdi','mov $-7,%rcx','xor %edx,%edx','1: mov (%rdi,%rcx,8),%rax','test %rax,%rax','jz 2f','mov (%rax),%r8','add $16,%r8','add %r8,%rdx','2: inc %rcx','cmp $-5,%rcx','jne 3f','xor %ecx,%ecx','3: cmp $16,%rcx','jl 1b','cmp $1048832,%rdx','ja cache_mt_fail','cmp %rdx,-64(%rdi)','jne cache_mt_fail','ret','cache_mt_fail:','mov $231,%eax','mov $99,%edi','syscall']
asm.write_text(code+'\n'+'\n'.join(body)+'\n')
for cmd in [['as',str(asm),'-o',str(obj)],['ld',str(obj),'-o',str(exe)]]:
 q=subprocess.run(cmd,capture_output=True);assert q.returncode==0,q.stderr
for _ in range(5):
 q=subprocess.run([str(exe)],capture_output=True,timeout=30);assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(q.returncode,q.stderr)
exe.unlink();obj.unlink()
(a.output/'summary.json').write_text(json.dumps(dict(repeats=5,workers=2,cycles_per_worker=40,sizes=6,independent_tls_sum=True,thread_owner_unchanged=True,flush0=True))+'\n')
print('PASS5 two-worker GNU TLS accounting runs')

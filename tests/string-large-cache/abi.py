#!/usr/bin/env python3
"""GNU Linux accounting/budget/flush/registry canary, independent cache scan."""
import argparse,subprocess,json,random,os
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--compiler',required=True,type=Path);p.add_argument('--output',required=True,type=Path);p.add_argument('--wine',type=Path);p.add_argument('--wine-prefix',type=Path);p.add_argument('--mingw',type=Path);p.add_argument('--mlib',type=Path);a=p.parse_args();a.compiler=a.compiler.resolve();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
plan=[];live={};nextid=0
# Fill every small slot with matching-bucket distinct lengths; consume ~1MiB.
for n in range(65521,65537):plan.append(('alloc',nextid,n));live[nextid]=n;nextid+=1
for i in list(live):plan.append(('free',i,live.pop(i)))
plan.append(('flush',0,0))
# Exhaustion and two-slot associativity, including full1MiB blocks.
for sizes in [[65537]*3,[131072,262144,524288],[1048576]*3,[1048577]*2,[327680,327680,327680,327680]]:
 for n in sizes:plan.append(('alloc',nextid,n));live[nextid]=n;nextid+=1
 for i in list(live):plan.append(('free',i,live.pop(i)))
 plan.append(('flush',0,0))
r=random.Random(184281)
for _ in range(160):
 if live and (len(live)>7 or r.randrange(2)):
  i=r.choice(list(live));plan.append(('free',i,live.pop(i)))
 else:
  n=r.choice([0,1,7,8,65535,65536,65537,65544,131072,262144,524288,1048576,1048577]);plan.append(('alloc',nextid,n));live[nextid]=n;nextid+=1
for i,n in live.items():plan.append(('free',i,n))
plan.append(('flush',0,0))
rows=[]
for target,instrument in [(t,i) for t in (['linux','windows'] if a.wine else ['linux']) for i in [False,True]]:
 src=a.output/'probe.prg';asm=a.output/'probe.s';obj=a.output/'probe.o';exe=a.output/'probe.program';src.write_text('function Main()\nreturn nil\n')
 q=subprocess.run([str(a.compiler),str(src),str(asm),'--target='+target]+(['--instrument'] if instrument else []),capture_output=True);assert q.returncode==0,q.stderr
 code=asm.read_text().replace('call hbc_fn_main','call cache_probe',1)
 model=[None]*18;used=0
 body=['.text','cache_probe:','push %rbp','mov %rsp,%rbp','push %rbx','push %r12','push %r13','push %r14','push %r15','sub $8,%rsp','mov $101,%ebx','mov $102,%r12d','mov $103,%r13d','mov $104,%r14d','mov $105,%r15d']
 for op,i,n in plan:
  slots=range((n&7)*2,(n&7)*2+2) if n<=65536 else range(16,18)
  if op=='alloc':
   for z in slots:
    if model[z]==n:model[z]=None;used-=n+16;break
  elif op=='free':
   if n<=1048576 and used+n+16<=1048832:
    for z in slots:
     if model[z] is None:model[z]=n;used+=n+16;break
  else:model=[None]*18;used=0
  if op=='alloc':body += [f'mov ${n},%rsi','call hbc_stralloc',f'mov %rax,test_live+{i*8}(%rip)',f'cmp ${n},%rdx','jne cache_fail',f'cmpq ${n},-16(%rax)','jne cache_fail',f'cmpq ${n},-8(%rax)','jne cache_fail']
  elif op=='free':
   body += [f'mov test_live+{i*8}(%rip),%rdi','mov $901,%r10','call hbc_freestr',f'movq $0,test_live+{i*8}(%rip)']
   if target=='linux':body += ['cmp $901,%r10','jne cache_fail']
  else:body += ['call hbc_str_cache_flush','cmpq $0,hbc_str_cache-64(%rip)','jne cache_fail']
  body += [f'cmpq ${used},hbc_str_cache-64(%rip)','jne cache_fail']
  for z,cap in enumerate(model):
   off=z*8 if z<16 else -56+(z-16)*8
   body += [f'mov hbc_str_cache+{off}(%rip),%rax','test %rax,%rax',('jz cache_fail' if cap is not None else 'jnz cache_fail')]
   if cap is not None:body += [f'cmpq ${cap},(%rax)','jne cache_fail']
  body+=['call cache_check','cmp $101,%rbx','jne cache_fail','cmp $102,%r12','jne cache_fail','cmp $103,%r13','jne cache_fail','cmp $104,%r14','jne cache_fail','cmp $105,%r15','jne cache_fail','mov %rsp,%rax','and $15,%eax','jnz cache_fail']
 body+=['mov hbc_mem_allocs(%rip),%rax','cmp hbc_mem_frees(%rip),%rax','jne cache_fail']
 if instrument:body+=['cmpq $0,hbc_reg_count(%rip)','jne cache_fail']
 body+=['add $8,%rsp','pop %r15','pop %r14','pop %r13','pop %r12','pop %rbx','pop %rbp','ret']
 # Independently sum18entries, compare budget counter, no cached/live alias,
 # and no duplicate pointer. Physical sizes use retained CAPACITY not length.
 body+=['cache_check:','lea hbc_str_cache(%rip),%rdi','xor %edx,%edx','mov $-7,%rcx','1: mov (%rdi,%rcx,8),%rax','test %rax,%rax','jz 5f','mov (%rax),%r8','add $16,%r8','add %r8,%rdx','cmp $1048832,%rdx','ja cache_fail','xor %r9d,%r9d',f'2: cmp ${nextid},%r9','jae 3f','lea test_live(%rip),%r10','cmp %rax,(%r10,%r9,8)','je cache_fail','inc %r9','jmp 2b','3: mov %rcx,%r9','4: inc %r9','cmp $-5,%r9','jne 41f','xor %r9d,%r9d','41: cmp $16,%r9','jge 5f','cmp %rax,(%rdi,%r9,8)','je cache_fail','jmp 4b','5: inc %rcx','cmp $-5,%rcx','jne 6f','xor %ecx,%ecx','6: cmp $16,%rcx','jl 1b','cmp %rdx,-64(%rdi)','jne cache_fail','ret','cache_fail:','mov $60,%eax','mov $99,%edi','syscall','.bss','.align 8',f'test_live: .zero {nextid*8}']
 if target=='windows':
  at=body.index('cache_fail:');body=body[:at]+['cache_fail:','sub $40,%rsp','mov $99,%ecx','call ExitProcess']+body[at+4:]
 asm.write_text(code+'\n'+'\n'.join(body)+'\n')
 commands=([['as',str(asm),'-o',str(obj)],['ld',str(obj),'-o',str(exe)]] if target=='linux' else [[str(a.mingw/'x86_64-w64-mingw32-as'),str(asm),'-o',str(obj)],[str(a.mingw/'x86_64-w64-mingw32-ld'),str(obj),'-o',str(exe),'-e','_start','--subsystem','console','-L'+str(a.mlib),'-lkernel32']])
 for cmd in commands:
  q=subprocess.run(cmd,capture_output=True);assert q.returncode==0,q.stderr
 env=dict(os.environ,WINEDEBUG='-all');
 if a.wine_prefix:env['WINEPREFIX']=str(a.wine_prefix.resolve())
 q=subprocess.run([str(a.wine),str(exe)] if target=='windows' else [str(exe)],capture_output=True,env=env);assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(instrument,q.returncode,q.stderr)
 rows.append(dict(target=target,instrument=instrument,operations=len(plan),independent_budget_sum=True,no_live_or_duplicate_cached=True,all_headers=True,callee_saved=True,final_registry0=instrument,logical_balance=True))
 exe.unlink();obj.unlink();asm.unlink();src.unlink()
(a.output/'summary.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',len(plan),'accounting steps x '+str(len(rows))+' target/mode runs')

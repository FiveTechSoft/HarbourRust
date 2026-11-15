#!/usr/bin/env python3
"""Direct Upper/Lower empty and nonempty owned pointer/ABI probes, GNU ELF/PE."""
import argparse,subprocess,json,os
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for k in ['compiler','output']:p.add_argument('--'+k,type=Path,required=True)
for k in ['wine','wine-prefix','mingw','mlib']:p.add_argument('--'+k,type=Path)
a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=str(a.wine_prefix.resolve())
rows=[]
for target in ['linux','windows'] if a.wine else ['linux']:
 for inst in [False,True]:
  src=a.output/'probe.prg';asm=a.output/'probe.s';obj=a.output/'probe.o';exe=a.output/'probe.program'
  src.write_text('function Main()\nreturn nil\n');q=subprocess.run([str(a.compiler),str(src),str(asm),'--target='+target]+(['--instrument'] if inst else []),capture_output=True);assert q.returncode==0,q.stderr
  code=asm.read_text().replace('call hbc_fn_main','call case_probe',1)
  body=['.text','case_probe:','push %rbp','mov %rsp,%rbp','push %rbx','push %r12','push %r13','push %r14','push %r15','sub $24,%rsp','mov $101,%ebx','mov $102,%r12d','mov $103,%r13d','mov $104,%r14d','mov $105,%r15d']
  cases=0
  for helper in ['upper','lower']:
   for n in [0,1,3]:
    for repeat in range(3):
     cases+=1
     body+=['lea case_input(%rip),%rdi',f'mov ${n},%rsi','mov $99,%r10',f'call hbc_{helper}','test %rax,%rax','jz case_fail','cmp $99,%rax','je case_fail',f'cmp ${n},%rdx','jne case_fail',f'cmpq ${n},-8(%rax)','jne case_fail',f'cmpq ${n},-16(%rax)','jb case_fail','mov %rax,(%rsp)']
     for i,byte in enumerate(([65,0,90] if helper=='upper' else [97,0,122])[:n]):body += [f'cmpb ${byte},{i}(%rax)','jne case_fail']
     body+=['cmp $101,%rbx','jne case_fail','cmp $102,%r12','jne case_fail','cmp $103,%r13','jne case_fail','cmp $104,%r14','jne case_fail','cmp $105,%r15','jne case_fail','mov %rsp,%rcx','and $15,%ecx','jnz case_fail','mov (%rsp),%rdi','call hbc_freestr']
  body+=['call hbc_str_cache_flush','mov hbc_mem_allocs(%rip),%rax','cmp hbc_mem_frees(%rip),%rax','jne case_fail']
  if inst:body+=['cmpq $0,hbc_reg_count(%rip)','jne case_fail']
  body+=['add $24,%rsp','pop %r15','pop %r14','pop %r13','pop %r12','pop %rbx','pop %rbp','ret','case_fail:']
  body+=['sub $40,%rsp','mov $99,%ecx','call ExitProcess'] if target=='windows' else ['mov $60,%eax','mov $99,%edi','syscall']
  body+=['.section .rodata','case_input: .byte 97,0,90']
  asm.write_text(code+'\n'+'\n'.join(body)+'\n')
  cmds=[['as',asm,'-o',obj],['ld',obj,'-o',exe]] if target=='linux' else [[a.mingw/'x86_64-w64-mingw32-as',asm,'-o',obj],[a.mingw/'x86_64-w64-mingw32-ld',obj,'-o',exe,'-e','_start','--subsystem','console','-L'+str(a.mlib),'-lkernel32']]
  for cmd in cmds:
   q=subprocess.run(list(map(str,cmd)),capture_output=True);assert q.returncode==0,q.stderr
  q=subprocess.run(list(map(str,[a.wine,exe] if target=='windows' else [exe])),capture_output=True,env=env,timeout=30);assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(target,inst,q.returncode,q.stdout,q.stderr)
  rows.append(dict(target=target,instrument=inst,cases=cases,owned_pointer=True,headers=True,all_bytes=True,callee_saved=True,stack=True,final_logical_balance0=True,final_registry0=inst))
  for f in [src,asm,obj,exe]:f.unlink()
(a.output/'summary.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',cases,'pointer/ABI cases x',len(rows),'target/modes')

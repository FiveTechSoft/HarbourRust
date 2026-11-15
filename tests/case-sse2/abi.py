#!/usr/bin/env python3
"""Upper/Lower all-byte real-allocator pointer/header/ABI probes, native ELF/PE/MachO."""
import argparse,subprocess,json,os
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for k in ['compiler','driver','output']:p.add_argument('--'+k,type=Path,required=True)
for k in ['wine','wine-prefix']:p.add_argument('--'+k,type=Path,required=True)
a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=str(a.wine_prefix.resolve())
rows=[]
for target in ['linux','windows','macho']:
 for inst in [False,True]:
  src=a.output/'probe.prg';asm=a.output/'probe.s';exe=a.output/'probe.program'
  src.write_text('function Main()\nreturn nil\n');q=subprocess.run([str(a.compiler),str(src),str(asm),'--target='+target]+(['--instrument'] if inst else []),capture_output=True);assert q.returncode==0,q.stderr
  code=asm.read_text().replace('call hbc_fn_main','call case_probe',1)
  body=['.text','case_probe:','push %rbp','mov %rsp,%rbp','push %rbx','push %r12','push %r13','push %r14','push %r15','sub $24,%rsp','mov $101,%ebx','mov $102,%r12d','mov $103,%r13d','mov $104,%r14d','mov $105,%r15d']
  body+=['mov $12345,%eax']
  for x in range(6,16):body += [f'movd %eax,%xmm{x}',f'pshufd $0,%xmm{x},%xmm{x}']
  cases=0
  for helper in ['upper','lower']:
   for n in list(range(66))+[127,128,129,255,256,257,4095,4096,4097]:
    for repeat in range(2):
     cases+=1
     body+=['lea case_input(%rip),%rdi',f'mov ${n},%rsi','mov $99,%r10',f'call hbc_{helper}','test %rax,%rax','jz case_fail','cmp $99,%rax','je case_fail',f'cmp ${n},%rdx','jne case_fail',f'cmpq ${n},-8(%rax)','jne case_fail',f'cmpq ${n},-16(%rax)','jb case_fail','mov %rax,(%rsp)']
     tag='check_'+str(cases)
     lo,hi,op=(97,122,'sub') if helper=='upper' else (65,90,'add')
     body+=['xor %r8d,%r8d',tag+':',f'cmp ${n},%r8','jae '+tag+'_done','mov %r8d,%r9d','and $255,%r9d',f'cmp ${lo},%r9d','jb '+tag+'_value',f'cmp ${hi},%r9d','ja '+tag+'_value',f'{op} $32,%r9d',tag+'_value:','cmp %r9b,(%rax,%r8)','jne case_fail','inc %r8','jmp '+tag,tag+'_done:']
     body+=['cmp $101,%rbx','jne case_fail','cmp $102,%r12','jne case_fail','cmp $103,%r13','jne case_fail','cmp $104,%r14','jne case_fail','cmp $105,%r15','jne case_fail','mov %rsp,%rcx','and $15,%ecx','jnz case_fail','mov (%rsp),%rdi','call hbc_freestr']
  body += ['mov $53021371281465,%r11']
  for x in range(6,16):body += [f'movq %xmm{x},%rax','cmp %r11,%rax','jne case_fail',f'pshufd $78,%xmm{x},%xmm0','movq %xmm0,%rax','cmp %r11,%rax','jne case_fail']
  body+=['call hbc_str_cache_flush','mov hbc_mem_allocs(%rip),%rax','cmp hbc_mem_frees(%rip),%rax','jne case_fail']
  if inst:body+=['cmpq $0,hbc_reg_count(%rip)','jne case_fail']
  body+=['add $24,%rsp','pop %r15','pop %r14','pop %r13','pop %r12','pop %rbx','pop %rbp','ret','case_fail:']
  body+=['sub $40,%rsp','mov $99,%ecx','call ExitProcess'] if target=='windows' else ['mov $60,%eax','mov $99,%edi','syscall']
  body+=['.section .rodata','case_input: .byte '+','.join(map(str,list(range(256))*17))]
  asm.write_text(code+'\n'+'\n'.join(body)+'\n')
  q=subprocess.run(list(map(str,[a.driver,{'linux':'elf','windows':'pe','macho':'macho'}[target],asm,exe])),capture_output=True,timeout=60);assert q.returncode==0,q.stderr
  if target!='macho':
   exe.chmod(0o755);q=subprocess.run(list(map(str,[a.wine,exe] if target=='windows' else [exe])),capture_output=True,env=env,timeout=30);assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(target,inst,q.returncode,q.stdout,q.stderr)
  rows.append(dict(target=target,instrument=inst,cases=cases,owned_pointer=target!='macho',headers=target!='macho',all_bytes=target!='macho',callee_saved=target!='macho',stack=target!='macho',xmm6_to_15_preserved=target!='macho',status='emission only' if target=='macho' else 'executed',final_logical_balance0=target!='macho',final_registry0=inst and target!='macho'))
  for f in [src,asm,exe]:f.unlink()
(a.output/'summary.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',cases,'pointer/ABI cases x',len(rows),'target/modes')

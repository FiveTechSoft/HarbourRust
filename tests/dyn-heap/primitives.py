#!/usr/bin/env python3
"""Internal checkpoint: native-encoder heap primitives, real string allocator.
Can append the pending blob to an older compiler's output before enablement.
"""
import argparse,pathlib,subprocess,json,os
p=argparse.ArgumentParser()
for k in ['compiler','driver','output','wine','wine-prefix']:p.add_argument('--'+k,required=True)
a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(parents=True,exist_ok=False);env=dict(os.environ,WINEDEBUG='-all',WINEPREFIX=a.wine_prefix);root=pathlib.Path(__file__).resolve().parents[2];blob=(root/'src/dyn_float.rs').read_text().split('r#"',1)[1].split('"#;',1)[0];rows=[]
for target in ['linux','windows','macho']:
 for inst in [False,True]:
  src=r/'empty.prg';src.write_text('function Main()\nreturn nil\n');asm=r/'probe.s';q=subprocess.run([a.compiler,str(src),str(asm),'--target='+target]+(['--instrument'] if inst else []),capture_output=True);assert q.returncode==0,q.stderr;code=asm.read_text().replace('call hbc_fn_main','call float_probe',1);injected='\nhbc_float_new:\n' not in code
  if injected:code+='\n'+blob
  b=['.text','float_probe:','push %rbp','mov %rsp,%rbp','push %rbx','push %r12','push %r13','push %r14','push %r15','sub $40,%rsp','mov $101,%ebx','mov $102,%r12d','mov $103,%r13d','mov $104,%r14d','mov $105,%r15d']
  bits=[0,0x8000000000000000,0x4004000000000000,0xc004000000000000,0x7ff0000000000000,0x7ff8000000000001]
  for idx,bit in enumerate(bits):
   meta=(10<<16)|idx
   b += [f'mov ${bit},%rdi',f'mov ${meta},%esi','call hbc_float_new','mov %rax,(%rsp)','mov %rdx,8(%rsp)','mov $0x8000000000000005,%r10','cmp %r10,%rax','jne float_fail','test %rdx,%rdx','jz float_fail','cmpq $16,-8(%rdx)','jne float_fail',f'mov ${bit},%r10','cmp %r10,(%rdx)','jne float_fail',f'cmpq ${meta},8(%rdx)','jne float_fail','call hbc_float_unpack','movq %xmm0,%r10',f'mov ${bit},%r11','cmp %r11,%r10','jne float_fail',f'cmp ${meta},%rdi','jne float_fail','mov (%rsp),%rax','mov 8(%rsp),%rdx','call hbc_float_clone','cmp 8(%rsp),%rdx','je float_fail','mov %rax,16(%rsp)','mov %rdx,24(%rsp)',f'mov ${bit},%r10','cmp %r10,(%rdx)','jne float_fail',f'cmpq ${meta},8(%rdx)','jne float_fail','call hbc_float_release','mov (%rsp),%rax','mov 8(%rsp),%rdx','call hbc_float_release']
   # Invalid pointer-like payload is safe with legacy tag5, proves no deref/free.
   b += [f'mov ${5|(idx<<8)},%eax',f'mov ${bit},%rdx','call hbc_float_clone',f'cmp ${5|(idx<<8)},%rax','jne float_fail',f'mov ${bit},%r10','cmp %r10,%rdx','jne float_fail','call hbc_float_release']
  b+=['cmp $101,%rbx','jne float_fail','cmp $102,%r12','jne float_fail','cmp $103,%r13','jne float_fail','cmp $104,%r14','jne float_fail','cmp $105,%r15','jne float_fail','mov %rsp,%rax','and $15,%eax','jnz float_fail','call hbc_str_cache_flush','mov hbc_mem_allocs(%rip),%rax','cmp hbc_mem_frees(%rip),%rax','jne float_fail']
  if inst:b+=['cmpq $0,hbc_reg_count(%rip)','jne float_fail']
  b+=['add $40,%rsp','pop %r15','pop %r14','pop %r13','pop %r12','pop %rbx','leave','ret','float_fail:']
  b+=['sub $40,%rsp','mov $99,%ecx','call ExitProcess'] if target=='windows' else ['mov $60,%eax','mov $99,%edi','syscall']
  asm.write_text(code+'\n'+'\n'.join(b)+'\n');exe=r/'probe';q=subprocess.run([a.driver,{'linux':'elf','windows':'pe','macho':'macho'}[target],str(asm),str(exe)],capture_output=True);assert q.returncode==0,(target,q.stderr)
  if target!='macho':
   exe.chmod(0o755);q=subprocess.run([a.wine,str(exe)] if target=='windows' else [str(exe)],capture_output=True,env=env,timeout=15);assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(target,inst,q.returncode,q.stderr)
  rows.append(dict(target=target,instrument=inst,injected_pending_blob=injected,status='emission only' if target=='macho' else 'executed',cases=len(bits)));exe.unlink()
(r/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('primitive checkpoint6configs PASS (MachO emission only)')

#!/usr/bin/env python3
import argparse,pathlib,subprocess,json,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--driver',required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--wine',required=True);p.add_argument('--wine-prefix',required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);r=a.output;rows=[];env=dict(os.environ,WINEDEBUG='-all',WINEPREFIX=a.wine_prefix)
for target in ['linux','windows','macho']:
 for inst in [False,True]:
  label=target+str(inst);src=r/'empty.prg';src.write_text('function Main()\nreturn nil\n');asm=r/(label+'.s');q=subprocess.run([a.compiler,str(src),str(asm),'--target='+target]+(['--instrument'] if inst else []),capture_output=True);assert q.returncode==0,q.stderr
  code=asm.read_text().replace('call hbc_fn_main','call abi_probe',1);b=['.text','abi_probe:','push %rbp','mov %rsp,%rbp','push %rbx','push %r12','push %r13','push %r14','push %r15','sub $8,%rsp','mov $101,%ebx','mov $102,%r12d','mov $103,%r13d','mov $104,%r14d','mov $105,%r15d','mov $12345,%eax']
  for x in range(6,16):b.append(f'movq %rax,%xmm{x}')
  count=0
  for off in range(16):
   for byte in range(256):
    # Repeated0..255 sequence: first desired byte at exactbyte+1 from offset.
    count+=1;b+=['lea abi_needle(%rip),%rdi',f'movb ${byte},(%rdi)','mov $1,%esi','lea abi_data(%rip),%rdx',f'add ${off},%rdx','mov $256,%ecx','call hbc_at',f'cmp ${(byte-off)%256+1},%rax','jne abi_fail']
  b+=['cmp $101,%rbx','jne abi_fail','cmp $102,%r12','jne abi_fail','cmp $103,%r13','jne abi_fail','cmp $104,%r14','jne abi_fail','cmp $105,%r15','jne abi_fail','mov %rsp,%rax','and $15,%eax','jnz abi_fail']
  for x in range(6,16):b += [f'movq %xmm{x},%rax','cmp $12345,%rax','jne abi_fail']
  b+=['mov hbc_mem_allocs(%rip),%rax','cmp hbc_mem_frees(%rip),%rax','jne abi_fail']
  if inst:b+=['cmpq $0,hbc_reg_count(%rip)','jne abi_fail']
  b+=['add $8,%rsp','pop %r15','pop %r14','pop %r13','pop %r12','pop %rbx','leave','ret','abi_fail:']
  b+=['sub $40,%rsp','mov $99,%ecx','call ExitProcess'] if target=='windows' else ['mov $60,%eax','mov $99,%edi','syscall']
  b+=['.data','abi_needle: .byte 0','abi_data: .byte '+','.join(map(str,list(range(256))*2))]
  asm.write_text(code+'\n'+'\n'.join(b)+'\n');exe=r/label;q=subprocess.run([a.driver,{'linux':'elf','windows':'pe','macho':'macho'}[target],str(asm),str(exe)],capture_output=True,timeout=30);assert q.returncode==0,(target,q.stderr)
  if target!='macho':
   exe.chmod(0o755);q=subprocess.run([a.wine,str(exe)] if target=='windows' else [str(exe)],capture_output=True,timeout=15,env=env);assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(target,inst,q.returncode,q.stderr)
  rows.append({'target':target,'instrument':inst,'cases':count,'native_encoder':True,'status':'emission only' if target=='macho' else 'PASS ABI+alignment+registry'})
  asm.unlink();exe.unlink()
(r/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('4096 all-byte/alignment ABI cases x6 configs PASS (MachO emission only)')

import sys,pathlib
p=pathlib.Path(sys.argv[1]);s=p.read_text()
windows=len(sys.argv)>2 and sys.argv[2]=='windows'
# Wrappers use the target C ABI for LLVM, preserve its nonvolatile registers.
for name,helper,params in [('nl','hbc_print_nl',0),('sep','hbc_print_sep',0),('int','hbc_print_i64',1),('computed','hbc_print_i64c',1),('str','hbc_print_str',2),('inc_error','hbc_inc_overflow',0),('bound_error','hbc_bound_error',0)]:
 s+='\n.text\n.globl rt_'+name+'\nrt_'+name+':\n'
 regs=['rbx','rbp','r12','r13','r14','r15']+(['rdi','rsi'] if windows else [])
 for r in regs:s+='    push %'+r+'\n'
 # Entry is 8 mod16; six/eight pushes preserve8. sub40 includes shadowspace.
 s+='    sub $40, %rsp\n'
 if windows:
  s+='    sub $160, %rsp\n'
  for j in range(10):s+=f'    movdqu %xmm{j+6}, {32+j*16}(%rsp)\n'
 if params:s+='    mov %'+('rcx' if windows else 'rdi')+', %rax\n'
 if params==2 and not windows:s+='    mov %rsi, %rdx\n'
 s+='    call '+helper+'\n'
 if windows:
  for j in range(10):s+=f'    movdqu {32+j*16}(%rsp), %xmm{j+6}\n'
  s+='    add $160, %rsp\n'
 s+='    add $40, %rsp\n'
 for r in reversed(regs):s+='    pop %'+r+'\n'
 s+='    ret\n'
p.write_text(s)

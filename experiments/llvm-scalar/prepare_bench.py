import pathlib
s=pathlib.Path('current.s').read_text();a=s.index('_start:');b=s.index('hbc_fn_sumloop:');s=s[:a]+s[b:];s=s.replace('    .globl _start','')
s+='\n.globl hbc_trace_top\n'
for name in ['sumloop','branchloop','fact','recurrence']:
 s+='\n.text\n.globl cur_'+name+'\ncur_'+name+':\n'
 for r in ['rbx','rbp','r12','r13','r14','r15']:s+='    push %'+r+'\n'
 s+='    sub $24, %rsp\n    mov %rdi, (%rsp)\n    call hbc_fn_'+name+'\n    add $24, %rsp\n'
 for r in ['r15','r14','r13','r12','rbp','rbx']:s+='    pop %'+r+'\n'
 s+='    ret\n'
# LLVM's main references wrappers even when not called; retain shared runtime adapters.
r=pathlib.Path('corpus.ll.runtime.s').read_text();s+=r[r.index('\n.text\n.globl rt_nl'):]
pathlib.Path('bench_current.s').write_text(s)

import re
text=s
# Analysis control only: remove explicit diagnostic trace bookkeeping, not arithmetic.
text=re.sub(r'    mov hbc_trace_top\(%rip\), %r11\n    mov %r11, -[0-9]+\(%rbp\)\n    movq \$0, -[0-9]+\(%rbp\)\n    movq \$0, -[0-9]+\(%rbp\)\n    lea -[0-9]+\(%rbp\), %r11\n    mov %r11, hbc_trace_top\(%rip\)\n','',text)
text=re.sub(r'    lea \.Lstr[0-9]+\(%rip\), %r11\n    mov %r11, -[0-9]+\(%rbp\)\n    movq \$[0-9]+, -[0-9]+\(%rbp\)\n','',text)
text=re.sub(r'    mov -[0-9]+\(%rbp\), %r11\n    mov %r11, hbc_trace_top\(%rip\)\n','',text)
pathlib.Path('bench_current_notrace.s').write_text(text)

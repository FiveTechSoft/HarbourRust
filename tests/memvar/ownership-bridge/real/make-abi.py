from pathlib import Path
R=Path(__file__).resolve().parent
for target in ['linux','windows']:
 win=target=='windows';s='.text\n.globl hrbt_abi_gate\nhrbt_abi_gate:\n'
 s+='push %rbp\nmov %rsp,%rbp\npush %rbx\npush %r12\npush %r13\npush %r14\npush %r15\nsub $184,%rsp\nmov %rdi,32(%rsp)\nmovq $0,128(%rsp)\n'
 for reg in ['rbx','r12','r13','r14','r15']+(['rdi','rsi'] if win else []):s+='mov $0x12345678,%'+reg+'\n'
 if win:
  for i in range(6,16):s+=f'movdqu .Labi_pattern(%rip),%xmm{i}\n'
  s+='xor %ecx,%ecx\nmov $0x4014000000000000,%rdx\nmov $655362,%r8d\nlea 64(%rsp),%r9\n'
 else:s+='xor %edi,%edi\nmov $0x4014000000000000,%rsi\nmov $655362,%edx\nlea 64(%rsp),%rcx\n'
 s+='mov 32(%rsp),%r11\ncall *%r11\ntest %eax,%eax\njz 1f\norq $1,128(%rsp)\n1:\n'
 for reg in ['rbx','r12','r13','r14','r15']+(['rdi','rsi'] if win else []):s+='cmp $0x12345678,%'+reg+'\nje 2f\norq $2,128(%rsp)\n2:\n'
 if win:
  for i in range(6,16):s+=f'movdqa %xmm{i},%xmm0\npcmpeqb .Labi_pattern(%rip),%xmm0\npmovmskb %xmm0,%eax\ncmp $65535,%eax\nje 3f\norq $4,128(%rsp)\n3:\n'
 s+='mov 72(%rsp),%rdi\ncall hrbt_free\nmov 128(%rsp),%rax\nlea -40(%rbp),%rsp\npop %r15\npop %r14\npop %r13\npop %r12\npop %rbx\npop %rbp\nret\n'
 s+='.globl hrbt_native_probe\nhrbt_native_probe:\nmov %rsp,%r10\nand $15,%r10\ncmp $8,%r10\nje 4f\nmovq $1,hrbt_bad_alignment(%rip)\n4:\n'
 if win:s+='movq $11,8(%rsp)\nmovq $22,16(%rsp)\nmovq $33,24(%rsp)\nmovq $44,32(%rsp)\n'
 s+='jmp real_float\n.data\n.balign 16\n.Labi_pattern:\n.quad 0x1234567890abcdef,0xfedcba0987654321\n.globl hrbt_bad_alignment\nhrbt_bad_alignment: .quad 0\n'
 s+='\n.text\n.globl hrbt_parity_gate\nhrbt_parity_gate:\npush %rbp\nmov %rsp,%rbp\npush %rbx\npush %r12\npush %r13\npush %r14\n'
 s+='xor %ebx,%ebx\n'
 for parity in [0,8]:
  s+=f'sub ${parity},%rsp\nmov %rsp,%r12\nmov $0x4014000000000000,%rdi\nmov $655362,%esi\ncall hrbt_new\ncmp %rsp,%r12\nje 5f\nor $1,%ebx\n5:\nmov %rdx,%rdi\ncall hrbt_free\nadd ${parity},%rsp\n'
 s+='mov %rbx,%rax\npop %r14\npop %r13\npop %r12\npop %rbx\npop %rbp\nret\n'
 (R/(target+'-abi.s')).write_text(s)

# hrm_call(id,argc,borrowed compiler-owned argv,out) ->1 success,0 unknown.
# Evaluator owns all arguments and releases them after this returns.
# Runtime C validates arity/types/range before entering any helper.
.text
hrm_call:
    push %rbp
    mov %rsp,%rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    and $-16,%rsp
    sub $32,%rsp
    mov %rcx,(%rsp)
    mov %rdx,8(%rsp)
    cmp $1,%edi
    je .Lhrm_call_upper
    cmp $2,%edi
    je .Lhrm_call_lower
    cmp $3,%edi
    je .Lhrm_call_round
    cmp $4,%edi
    je .Lhrm_call_chr
    cmp $5,%edi
    je .Lhrm_call_asc
    xor %eax,%eax
    jmp .Lhrm_call_done
.Lhrm_call_upper:
    mov 8(%rdx),%rdi
    mov -8(%rdi),%rsi
    call hbc_upper
    jmp .Lhrm_call_string
.Lhrm_call_lower:
    mov 8(%rdx),%rdi
    mov -8(%rdi),%rsi
    call hbc_lower
.Lhrm_call_string:
    mov (%rsp),%rcx
    movq $4,(%rcx)
    mov %rax,8(%rcx)
    jmp .Lhrm_call_ok
.Lhrm_call_chr:
    # The C evaluator validated tag 0 (int) or 5 (heap float {double,meta}):
    # a float truncates toward zero (oracle Chr(65.7)="A"); hbc_chr wraps
    # to the low byte (oracle Chr(256)=0x00, Chr(-1)=0xFF) and returns an
    # owned one-byte string.
    mov 8(%rdx),%rdi
    cmpb $5,(%rdx)
    jne .Lhrm_call_chr_int
    movsd (%rdi),%xmm0
    cvttsd2siq %xmm0,%rdi
.Lhrm_call_chr_int:
    call hbc_chr
    jmp .Lhrm_call_string
.Lhrm_call_asc:
    # Validated tag 4 (string): the unsigned first byte; empty input is 0
    # (oracle Asc("")=0, no error).
    mov 8(%rdx),%rdi
    mov -8(%rdi),%rsi
    call hbc_asc
    mov (%rsp),%rcx
    movq $0,(%rcx)
    mov %rax,8(%rcx)
    jmp .Lhrm_call_ok
.Lhrm_call_round:
    mov 8(%rdx),%rax
    cmpb $5,(%rdx)
    jne .Lhrm_call_int
    movsd (%rax),%xmm0
    jmp .Lhrm_call_dec
.Lhrm_call_int:
    cvtsi2sdq %rax,%xmm0
.Lhrm_call_dec:
    mov 24(%rdx),%rdi
    cmpb $5,16(%rdx)
    jne .Lhrm_call_round_do
    movsd (%rdi),%xmm1
    cvttsd2siq %xmm1,%rdi
.Lhrm_call_round_do:
    call hbc_round
    mov %rdi,%rsi
    movq %xmm0,%rdi
    call hbc_float_new
    mov (%rsp),%rcx
    mov %rax,(%rcx)
    mov %rdx,8(%rcx)
.Lhrm_call_ok:
    mov $1,%eax
.Lhrm_call_done:
    lea -40(%rbp),%rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

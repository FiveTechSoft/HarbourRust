# Own MIT callback sort. rdi=cells,rsi=len,rdx=start,rcx=count,r8=block,
# r10=owner frame. No temporary heap or borrowed-cell gaps across calls.
# Recursive split floor(n/2), then stable right,left comparisons. Rotate
# a selected right cell into the left run using whole-cell swaps.
.text
hbc_asort_callback_shared:
    test %rsi,%rsi
    jz .Lascbdone
    test %rdx,%rdx
    js .Lascbdone
    jnz .Lascbstart
    mov $1,%edx
.Lascbstart:
    cmp %rsi,%rdx
    jg .Lascbdone
    sub %rdx,%rsi
    inc %rsi
    test %rcx,%rcx
    jle .Lascbcount
    cmp %rsi,%rcx
    jle .Lascbcountok
.Lascbcount:
    mov %rsi,%rcx
.Lascbcountok:
    dec %rdx
    shl $4,%rdx
    add %rdx,%rdi
    mov %rcx,%rsi
    jmp hbc_asort_callback_merge
.Lascbdone:
    ret
# rdi=first cell,rsi=count,r8=callback,r10=owner
hbc_asort_callback_merge:
    cmp $2,%rsi
    jb .Lascbdone
    push %rbp
    mov %rsp,%rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $24,%rsp
    mov %rdi,%rbx
    mov %rsi,%r12
    mov %r8,%r13
    mov %r10,-48(%rbp)
    shr $1,%rsi
    mov %rsi,%r14
    call hbc_asort_callback_merge
    mov %r14,%rax
    shl $4,%rax
    lea (%rbx,%rax),%rdi
    mov %r12,%rsi
    sub %r14,%rsi
    mov %r13,%r8
    mov -48(%rbp),%r10
    call hbc_asort_callback_merge
    xor %r15d,%r15d
.Lascbcompare:
    cmp %r14,%r15
    jae .Lascbret
    cmp %r12,%r14
    jae .Lascbret
    mov %r14,%rax
    shl $4,%rax
    lea (%rbx,%rax),%rcx
    sub $32,%rsp
    mov (%rcx),%rax
    mov 8(%rcx),%rdx
    mov %rax,16(%rsp)
    mov %rdx,24(%rsp)
    mov %r15,%rax
    shl $4,%rax
    lea (%rbx,%rax),%rcx
    mov (%rcx),%rax
    mov 8(%rcx),%rdx
    mov %rax,(%rsp)
    mov %rdx,8(%rsp)
    mov -48(%rbp),%r10
    call *%r13
    add $32,%rsp
    test %rax,%rax
    jz .Lascbnext
    mov %r14,%rsi
.Lascbrotate:
    cmp %r15,%rsi
    jbe .Lascbselected
    mov %rsi,%rax
    shl $4,%rax
    lea (%rbx,%rax),%rcx
    mov (%rcx),%rax
    mov 8(%rcx),%rdx
    mov -16(%rcx),%r8
    mov -8(%rcx),%r9
    mov %r8,(%rcx)
    mov %r9,8(%rcx)
    mov %rax,-16(%rcx)
    mov %rdx,-8(%rcx)
    dec %rsi
    jmp .Lascbrotate
.Lascbselected:
    inc %r14
.Lascbnext:
    inc %r15
    jmp .Lascbcompare
.Lascbret:
    add $24,%rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

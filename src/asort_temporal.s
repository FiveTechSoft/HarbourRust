# Own MIT default temporal comparison, block ABI: (right,left) on stack.
# A Date/timestamp pair compares date portions only. Two timestamps compare
# full packed values. This does not change expression comparison operators.
.text
hbc_asort_temporal_before:
    push %rbp
    mov %rsp,%rbp
    sub $32,%rsp
    mov 32(%rbp),%rax
    mov 40(%rbp),%rdx
    mov 16(%rbp),%rcx
    mov 24(%rbp),%r8
    cmp $17,%rax
    je .Lasttimeright
    cmp $17,%rcx
    je .Lasttimeleft
.Lastordinary:
    call hbc_asort_flat_cmp
    test %rax,%rax
    setl %al
    movzbq %al,%rax
    leave
    ret
.Lasttimeright:
    cmp $17,%rcx
    je .Lastboth
    cmp $11,%rcx
    je .Lastmixed
    # Only the right is temporal. Delegate using Date's family rank.
    mov $11,%eax
    jmp .Lastordinary
.Lasttimeleft:
    cmp $11,%rax
    je .Lastmixed
    mov $11,%ecx
    jmp .Lastordinary
.Lastboth:
    xor %eax,%eax
    cmp %r8,%rdx
    setb %al
    leave
    ret
.Lastmixed:
    mov %rdx,(%rsp)
    mov %r8,8(%rsp)
    cmp $17,%rax
    jne .Lastconvertleft
    mov %rdx,%rdi
    call hbc_ts_to_date
    mov %rax,(%rsp)
    jmp .Lastdatecmp
.Lastconvertleft:
    mov %r8,%rdi
    call hbc_ts_to_date
    mov %rax,8(%rsp)
.Lastdatecmp:
    xor %eax,%eax
    mov (%rsp),%rdx
    cmp 8(%rsp),%rdx
    setl %al
    leave
    ret

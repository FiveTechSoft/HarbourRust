# I3 dedicated flat array family. All pointers here are data=base+24.
.bss
.align 8
hbc_vlive: .quad 0
hbc_vreserved: .quad 0
hbc_vcommitted: .quad 0
hbc_vreserve_calls: .quad 0
hbc_vcommit_calls: .quad 0
hbc_vpage: .quad 0
hbc_von: .byte 0
.align 8
@VREG_DATA@
.text
# Legacy emitter adapter: bytes=8+16*cap, result=data-8 for cap write.
hbc_valloc:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    sub $8, %rdi
    shr $4, %rdi
    call hbc_vnew
    sub $8, %rax
    leave
    ret

# cap -> checked exact bytes, then optional page rounding. Never wrap.
hbc_vbytes:
    mov $576460752303423486, %rax
    cmp %rax, %rdi
    ja hbc_oom
    mov %rdi, %rax
    shl $4, %rax
    add $24, %rax
    ret

# New backing, cap in rdi. rax=data. Header set before registration.
hbc_vnew:
    push %rbp
    mov %rsp, %rbp
    sub $96, %rsp
    mov %rdi, -8(%rbp)
    call hbc_vbytes
    mov %rax, -16(%rbp)
    cmpb $0, hbc_von(%rip)
    je .Lvnew_heap
    mov hbc_vpage(%rip), %rcx
    dec %rcx
    add %rcx, %rax
    jo hbc_oom
    not %rcx
    and %rcx, %rax
    mov %rax, -24(%rbp)
    cmp $16777216, %rax
    ja .Lvnew_heap
@VFAIL_RESERVE@    call hbc_vreserve
    test %rax, %rax
    je .Lvnew_heap
    mov %rax, -32(%rbp)
@VFAIL_INITIAL@    mov %rax, %rdi
    mov -24(%rbp), %rsi
    call hbc_vcommit
    test %rax, %rax
    je .Lvnew_unreserve
    mov -32(%rbp), %rax
    movq $16777216, (%rax)
    mov -24(%rbp), %rcx
    mov %rcx, 8(%rax)
    addq $16777216, hbc_vreserved(%rip)
    add %rcx, hbc_vcommitted(%rip)
    jmp .Lvnew_done
.Lvnew_unreserve:
    mov -32(%rbp), %rdi
    mov $16777216, %esi
    mov $1, %edx
    call hbc_vrelease
.Lvnew_heap:
@VFAIL_HEAP@    mov -16(%rbp), %rdi
    call hbc_vheap
    test %rax, %rax
    je hbc_oom
    movq $0, (%rax)
    mov -16(%rbp), %rcx
    mov %rcx, 8(%rax)
.Lvnew_done:
    mov -8(%rbp), %rcx
    mov %rcx, 16(%rax)
    add $24, %rax
@VREG_ADD@    incq hbc_mem_allocs(%rip)
    incq hbc_vlive(%rip)
    leave
    ret

# Dedicated free preserves the generic family entirely. Null is no-op.
hbc_vfree:
    test %rdi, %rdi
    je .Lvfree_ret
    push %rbp
    mov %rsp, %rbp
    sub $80, %rsp
    mov %rdi, -8(%rbp)
@VREG_CHECK@    mov -24(%rdi), %rdx
    mov %rdx, -16(%rbp)
    mov -16(%rdi), %rsi
    mov %rsi, -24(%rbp)
    test %rdx, %rdx
    cmovnz %rdx, %rsi
    sub $24, %rdi
@VFAIL_FREE@    call hbc_vrelease
@VREG_REMOVE@    mov -16(%rbp), %rdx
    test %rdx, %rdx
    je .Lvfree_count
    sub %rdx, hbc_vreserved(%rip)
    mov -24(%rbp), %rdx
    sub %rdx, hbc_vcommitted(%rip)
.Lvfree_count:
    decq hbc_vlive(%rip)
    incq hbc_mem_frees(%rip)
    leave
.Lvfree_ret:
    ret

# Ensure backing capacity for requested length. Does NOT mutate slot len.
# Replacement fills exposed NIL cells before publishing pointer.
hbc_vensure:
    push %rbp
    mov %rsp, %rbp
    sub $128, %rsp
    mov %rdx, -80(%rbp)
    mov %rdi, -8(%rbp)
    mov %rsi, -16(%rbp)
    mov (%rdi), %rax
    mov %rax, -24(%rbp)
    mov 8(%rdi), %rcx
    mov %rcx, -32(%rbp)
    xor %edx, %edx
    test %rax, %rax
    je .Lvensure_cap
@VREG_ENSURE@    mov -8(%rax), %rdx
.Lvensure_cap:
    cmp %rdx, %rsi
    jle .Lvensure_ret
    mov $4, %edi
    test %rdx, %rdx
    je .Lvensure_next
    # Guard before doubling, not after shift/carry has disappeared.
    mov $288230376151711743, %rcx
    cmp %rcx, %rdx
    ja hbc_oom
    lea (%rdx,%rdx), %rdi
.Lvensure_next:
    cmp %rsi, %rdi
    cmovl %rsi, %rdi
    mov %rdi, -40(%rbp)
    call hbc_vbytes
    mov %rax, -48(%rbp)
    mov -24(%rbp), %rcx
    test %rcx, %rcx
    je .Lvensure_first
    cmpq $0, -24(%rcx)
    je .Lvensure_move
    mov hbc_vpage(%rip), %rdx
    dec %rdx
    add %rdx, %rax
    jo hbc_oom
    not %rdx
    and %rdx, %rax
    mov %rax, -56(%rbp)
    cmp -24(%rcx), %rax
    ja .Lvensure_move
    cmp -16(%rcx), %rax
    jbe .Lvensure_setcap
@VFAIL_COMMIT@    mov -16(%rcx), %rdx
    lea -24(%rcx,%rdx), %rdi
    sub %rdx, %rax
    mov %rax, %rsi
    call hbc_vcommit
    test %rax, %rax
    je .Lvensure_move
    mov -24(%rbp), %rcx
    mov -56(%rbp), %rdx
    sub -16(%rcx), %rdx
    add %rdx, hbc_vcommitted(%rip)
    mov -56(%rbp), %rdx
    mov %rdx, -16(%rcx)
.Lvensure_setcap:
    mov -40(%rbp), %rdx
    mov %rdx, -8(%rcx)
@VREG_GROW@    jmp .Lvensure_ret
.Lvensure_first:
    mov -40(%rbp), %rdi
    call hbc_vnew
    jmp .Lvensure_copy
.Lvensure_move:
    # Fallback stays fallback: temporarily suppress only the reservation
    # attempt. Single-thread eligibility makes this scoped flag safe.
    movzbq hbc_von(%rip), %rax
    mov %rax, -64(%rbp)
    movb $0, hbc_von(%rip)
    mov -40(%rbp), %rdi
    call hbc_vnew
    mov -64(%rbp), %rcx
    mov %cl, hbc_von(%rip)
.Lvensure_copy:
    mov %rax, -72(%rbp)
    mov -24(%rbp), %rsi
    mov %rax, %rdi
    mov -32(%rbp), %rcx
    shl $1, %rcx
.Lvensure_copywords:
    test %rcx, %rcx
    je .Lvensure_copydone
    mov (%rsi), %rdx
    mov %rdx, (%rdi)
    add $8, %rsi
    add $8, %rdi
    dec %rcx
    jmp .Lvensure_copywords
.Lvensure_copydone:
    mov -32(%rbp), %rcx
    mov -16(%rbp), %rdx
.Lvensure_nil:
    cmp %rdx, %rcx
    jge .Lvensure_publish
    mov %rcx, %rax
    shl $4, %rax
    movq $1, (%rdi)
    movq $0, 8(%rdi)
    add $16, %rdi
    inc %rcx
    jmp .Lvensure_nil
.Lvensure_publish:
    # An AAdd source is a snapshotted cell, not a pointer into old backing.
    # Install it into replacement storage before publishing the owner pair.
    mov -80(%rbp), %rdx
    test %rdx, %rdx
    je .Lvensure_ready
    mov -32(%rbp), %rcx
    shl $4, %rcx
    add -72(%rbp), %rcx
    mov (%rdx), %rax
    mov %rax, (%rcx)
    mov 8(%rdx), %rax
    mov %rax, 8(%rcx)
.Lvensure_ready:
    mov -8(%rbp), %rcx
    mov -72(%rbp), %rax
    mov %rax, (%rcx)
    mov -24(%rbp), %rdi
    call hbc_vfree
.Lvensure_ret:
    leave
    ret

# slot, element-size(16), evaluated temporary cell -> append.
hbc_vaadd:
    push %rbp
    mov %rsp, %rbp
    sub $80, %rsp
    mov %rdi, -8(%rbp)
    # Snapshot source before ensure can free old backing.
    mov (%rdx), %rax
    mov %rax, -32(%rbp)
    mov 8(%rdx), %rax
    mov %rax, -24(%rbp)
    mov 8(%rdi), %rsi
    add $1, %rsi
    jo hbc_oom
    lea -32(%rbp), %rdx
    call hbc_vensure
    mov -8(%rbp), %rcx
    mov (%rcx), %rdi
    mov 8(%rcx), %rax
    shl $4, %rax
    add %rax, %rdi
    mov -32(%rbp), %rax
    mov %rax, (%rdi)
    mov -24(%rbp), %rax
    mov %rax, 8(%rdi)
    incq 8(%rcx)
    leave
    ret

# slot, new length, cell-size16, deep-kind0. Exposed cells are NIL.
hbc_vasize:
    test %rsi, %rsi
    js hbc_asize_neg
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rdi, -8(%rbp)
    mov %rsi, -16(%rbp)
    mov 8(%rdi), %rax
    mov %rax, -24(%rbp)
    cmp %rax, %rsi
    jle .Lvasize_store
    xor %edx, %edx
    call hbc_vensure
    mov -8(%rbp), %rdx
    mov (%rdx), %rdi
    mov -24(%rbp), %rcx
.Lvasize_nil:
    cmp -16(%rbp), %rcx
    jge .Lvasize_store
    mov %rcx, %rax
    shl $4, %rax
    movq $1, (%rdi,%rax)
    movq $0, 8(%rdi,%rax)
    inc %rcx
    jmp .Lvasize_nil
.Lvasize_store:
    mov -8(%rbp), %rdx
    mov -16(%rbp), %rax
    mov %rax, 8(%rdx)
    leave
    ret

@VREG_HELPERS@

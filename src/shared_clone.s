# Own MIT graph clone for registered shared arrays. Map entries preserve
# repeated children and cycles. No collector safe point inside this helper.
.text
hbc_sarr_clone:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    movq $0, (%rsp)
    lea (%rsp), %rsi
    call hbc_sarr_clone_graph
    mov %rax, 8(%rsp)
.Lsc_free_map:
    mov (%rsp), %rdi
    test %rdi, %rdi
    jz .Lsc_done
    mov 16(%rdi), %rax
    mov %rax, (%rsp)
    mov $1, %esi
    call hbc_free
    jmp .Lsc_free_map
.Lsc_done:
    mov 8(%rsp), %rdx
    mov $16, %eax
    leave
    ret

# rdi source object, rsi address of linked old/new map -> rax clone object.
hbc_sarr_clone_graph:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $24, %rsp
    mov %rdi, %rbx
    mov %rsi, (%rsp)
    mov (%rsi), %r14
.Lsc_find:
    test %r14, %r14
    jz .Lsc_new
    cmp (%r14), %rbx
    je .Lsc_found
    mov 16(%r14), %r14
    jmp .Lsc_find
.Lsc_found:
    mov 8(%r14), %rax
    jmp .Lsc_return
.Lsc_new:
    lea .Lsc_empty(%rip), %rdi
    call hbc_sarr_build
    mov %rax, %r12
    mov (%rbx), %r15
    mov %r12, %rdi
    mov %r15, %rax
    call hbc_sarr_asize
    mov $32, %edi
    call hbc_alloc
    movq $24, (%rax)
    add $8, %rax
    mov %rbx, (%rax)
    mov %r12, 8(%rax)
    mov (%rsp), %rsi
    mov (%rsi), %rcx
    mov %rcx, 16(%rax)
    mov %rax, (%rsi)
    xor %r13d, %r13d
.Lsc_cells:
    cmp %r15, %r13
    jae .Lsc_finish
    mov %r13, %r14
    shl $4, %r14
    mov 24(%rbx), %r11
    add %r14, %r11
    mov (%r11), %rax
    mov 8(%r11), %rdx
    cmp $16, %rax
    jne .Lsc_scalar
    mov %rdx, %rdi
    mov (%rsp), %rsi
    call hbc_sarr_clone_graph
    mov %rax, %rdx
    mov $16, %eax
    jmp .Lsc_store
.Lsc_scalar:
    call hbc_float_clone
    cmp $2, %rax
    je .Lsc_string
    cmp $4, %rax
    jne .Lsc_store
.Lsc_string:
    mov %rdx, %rdi
    mov -8(%rdx), %rsi
    call hbc_strcpy
    mov %rax, %rdx
    mov $4, %eax
.Lsc_store:
    mov 24(%r12), %r11
    add %r14, %r11
    mov %rax, (%r11)
    mov %rdx, 8(%r11)
    inc %r13
    jmp .Lsc_cells
.Lsc_finish:
    mov %r12, %rax
.Lsc_return:
    add $24, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    leave
    ret
.data
.align 8
.Lsc_empty: .quad 0
.text

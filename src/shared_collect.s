# Own MIT conservative safe-point collector for registered tag-16 arrays.
# Called only at statement boundaries. Scan the active language stack for
# exact {16, registered-object} pairs, then close the graph and sweep.
# Candidate pointers are compared to registry entries BEFORE dereferencing.
# Conservative roots may retain dead arrays until the containing frame leaves.
.bss
.align 8
hbc_sarr_stack_top: .quad 0
.text
hbc_sarr_collect:
    lea 8(%rsp), %r11
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    sub $16, %rsp
    mov %r11, %r12
    mov hbc_sarr_stack_top(%rip), %r13
    test %r13, %r13
    jz .Lgc_done
.Lgc_stack:
    lea 16(%r12), %rax
    cmp %r13, %rax
    ja .Lgc_globals
    cmpq $16, (%r12)
    jne .Lgc_nextword
    mov 8(%r12), %rdx
    mov hbc_sarr_registry(%rip), %rax
.Lgc_find:
    test %rax, %rax
    jz .Lgc_nextword
    cmp %rdx, %rax
    je .Lgc_root
    mov 16(%rax), %rax
    jmp .Lgc_find
.Lgc_root:
    movq $1, 32(%rax)
.Lgc_nextword:
    add $8, %r12
    jmp .Lgc_stack
.Lgc_globals:
    call hbc_sarr_mark_globals
    mov hbc_seq_exc_depth(%rip), %r12
    lea hbc_seq_exc(%rip), %r13
.Lgc_exceptions:
    test %r12, %r12
    jz .Lgc_close
    cmpq $16, (%r13)
    jne .Lgc_nextexception
    mov 8(%r13), %rax
    movq $1, 32(%rax)
.Lgc_nextexception:
    dec %r12
    add $16, %r13
    jmp .Lgc_exceptions
# Repeated graph scan avoids recursive marking on cycles or deep arrays.
.Lgc_close:
    xor %r14d, %r14d
    mov hbc_sarr_registry(%rip), %rbx
.Lgc_object:
    test %rbx, %rbx
    jz .Lgc_closed
    cmpq $1, 32(%rbx)
    jne .Lgc_nextobject
    movq $2, 32(%rbx)
    mov (%rbx), %r12
    mov 24(%rbx), %r13
.Lgc_cells:
    test %r12, %r12
    jz .Lgc_nextobject
    cmpq $16, (%r13)
    jne .Lgc_nextcell
    mov 8(%r13), %rax
    cmpq $0, 32(%rax)
    jne .Lgc_nextcell
    movq $1, 32(%rax)
    mov $1, %r14d
.Lgc_nextcell:
    add $16, %r13
    dec %r12
    jmp .Lgc_cells
.Lgc_nextobject:
    mov 16(%rbx), %rbx
    jmp .Lgc_object
.Lgc_closed:
    test %r14d, %r14d
    jnz .Lgc_close
    lea hbc_sarr_registry(%rip), %r12
    mov (%r12), %rbx
.Lgc_sweep:
    test %rbx, %rbx
    jz .Lgc_done
    mov 16(%rbx), %r13
    cmpq $0, 32(%rbx)
    je .Lgc_dead
    movq $0, 32(%rbx)
    lea 16(%rbx), %r12
    jmp .Lgc_swept
.Lgc_dead:
    mov %r13, (%r12)
    mov 24(%rbx), %rdi
    test %rdi, %rdi
    jz .Lgc_freeobject
    mov (%rbx), %rdx
    call hbc_sarr_cells_release
    mov 24(%rbx), %rdi
    mov $16, %esi
    call hbc_free
.Lgc_freeobject:
    mov %rbx, %rdi
    mov $1, %esi
    call hbc_free
.Lgc_swept:
    mov %r13, %rbx
    jmp .Lgc_sweep
.Lgc_done:
    add $16, %rsp
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    leave
    ret

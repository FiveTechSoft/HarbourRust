# Own MIT shared-array comparison guard. Inputs follow hbc_dyn_eq.
# = and <> reject a registered array against any non-NIL value.
# The caller still owns the final inversion for <>.
.text
hbc_sarr_equal_guard:
    mov $0, %r9d
    jmp .Lsaeq_check
hbc_sarr_unequal_guard:
    mov $1, %r9d
.Lsaeq_check:
    cmp $1, %rax
    je hbc_dyn_eq
    cmp $1, %rcx
    je hbc_dyn_eq
    cmp $16, %rax
    je hbc_sarr_cmp_error
    cmp $16, %rcx
    jne hbc_dyn_eq
hbc_sarr_cmp_error:
    cmpq $0, hbc_seq_depth(%rip)
    jne .Lsaeq_throw
    test %r9d, %r9d
    jnz hbc_dyncmp_ne_error
    jmp hbc_dyncmp_eq_error
.Lsaeq_throw:
    lea .LseqD_roundarg(%rip), %rsi
    jmp hbc_seq_throw_error

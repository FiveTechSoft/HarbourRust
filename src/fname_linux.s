# Own MIT hb_FNameExt/Name/Dir, measured Linux oracle path limit263.
# rdi/rsi=counted path, edx=0 ext /1 name /2 dir /3 nameext -> owned copy.
.text
hbc_fname_linux:
    cmp $263, %rsi
    jbe .Lfn_cap
    mov $263, %esi
.Lfn_cap:
    xor %eax, %eax
    xor %r8d, %r8d
    mov $-1, %r9
.Lfn_scan:
    cmp %rsi, %rax
    jae .Lfn_done
    movzbl (%rdi,%rax), %ecx
    test %cl, %cl
    jz .Lfn_done
    cmp $47, %cl
    jne .Lfn_dot
    lea 1(%rax), %r8
    mov $-1, %r9
    jmp .Lfn_next
.Lfn_dot:
    cmp $46, %cl
    jne .Lfn_next
    cmp %r8, %rax
    je .Lfn_next
    mov %rax, %r9
.Lfn_next:
    inc %rax
    jmp .Lfn_scan
.Lfn_done:
    cmp $3, %edx
    je .Lfn_nameext
    cmp $2, %edx
    je .Lfn_dir
    test %edx, %edx
    jnz .Lfn_name
    cmp $-1, %r9
    cmove %rax, %r9
    lea (%rdi,%r9), %rdi
    sub %r9, %rax
    mov %rax, %rsi
    jmp hbc_strcpy
.Lfn_name:
    cmp $-1, %r9
    cmovne %r9, %rax
    add %r8, %rdi
    sub %r8, %rax
    mov %rax, %rsi
    jmp hbc_strcpy
.Lfn_dir:
    mov %r8, %rsi
    jmp hbc_strcpy
.Lfn_nameext:
    add %r8, %rdi
    sub %r8, %rax
    cmp $262, %rax
    jbe .Lfn_nameext_copy
    mov $262, %eax
.Lfn_nameext_copy:
    mov %rax, %rsi
    jmp hbc_strcpy

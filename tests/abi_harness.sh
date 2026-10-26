#!/bin/bash
# ABI harness: assembles a canary test against the emitted runtime helpers
# for both targets and runs it (natively on Linux, via Wine for Windows).
# Verifies that hbc_asize / hbc_aadd / hbc_arraym / hbc_array3m / hbc_array4m / hbc_free / hbc_free2 /
# hbc_dyn_eq (incl. tag-3 logical casillas) / hbc_dyn_to_log
# hbc_rfree preserve rbx/r12-r15, keep rsp 16-aligned at internal call boundaries
# and leave the stack balanced. Prints "ABI OK" on success; any canary,
# alignment or stack mismatch prints "ABI FAIL <what>" and exits 1.
set -e
cd "$(dirname "$0")/.."
mkdir -p gen
printf 'function main()\nreturn\n' > gen/abi_empty.hb
./hbc gen/abi_empty.hb gen/abi_l.s --target=linux -I tests >/dev/null
./hbc gen/abi_empty.hb gen/abi_w.s --target=windows -I tests >/dev/null

inject() { # $1 = input .s, $2 = output .s, $3 = linux|windows
  sed '0,/call hbc_fn_main/s//call hbc_abi_test/' "$1" > "$2"
  cat >> "$2" <<'ASM_EOF'

# --- hbc_abi_test: canary ABI harness (appended by tests/abi_harness.sh) ---
    .text
hbc_abi_test:
    push %rbp
    mov %rsp, %rbp
    sub $128, %rsp
    # entry invariant: caller aligned rsp to 16 before the call, so it is
    # 8 here and 0 after push rbp.
    mov %rsp, %rax
    and $15, %rax
    jnz abi_fail_align
    mov %rsp, -8(%rbp)
    call abi_canary_set
    # hbc_asize: grow flat 0 -> 5 (elemsize 16, shallow), then shrink 5 -> 2
    movq $0, -32(%rbp)
    movq $0, -24(%rbp)
    lea -32(%rbp), %rdi
    mov $5, %esi
    mov $16, %edx
    xor %ecx, %ecx
    call hbc_asize
    call abi_check
    lea -32(%rbp), %rdi
    mov $2, %esi
    mov $16, %edx
    xor %ecx, %ecx
    call hbc_asize
    call abi_check
    mov -32(%rbp), %rdi
    mov $16, %esi
    call hbc_free
    call abi_check
    # hbc_aadd: 6 appends force a re-grow (cap 4 -> 8)
    movq $0, -48(%rbp)
    movq $0, -40(%rbp)
    movq $1, -64(%rbp)
    movq $7, -56(%rbp)
    movq $0, -72(%rbp)
90: cmpq $6, -72(%rbp)
    jae 91f
    lea -48(%rbp), %rdi
    mov $16, %esi
    lea -64(%rbp), %rdx
    call hbc_aadd
    call abi_check
    incq -72(%rbp)
    jmp 90b
91: mov -48(%rbp), %rdi
    mov $16, %esi
    call hbc_free
    call abi_check
    # hbc_arraym (3x2) + hbc_free2 deep free
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea -96(%rbp), %rdi
    mov $3, %esi
    mov $2, %edx
    call hbc_arraym
    call abi_check
    mov -96(%rbp), %rdi
    mov $3, %esi
    call hbc_free2
    call abi_check
    # hbc_asize deep shrink with a live child (child free route), then free2
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea -96(%rbp), %rdi
    mov $2, %esi
    mov $2, %edx
    call hbc_arraym
    call abi_check
    lea -96(%rbp), %rdi
    mov $1, %esi
    mov $16, %edx
    mov $1, %ecx
    call hbc_asize
    call abi_check
    mov -96(%rbp), %rdi
    mov $1, %esi
    call hbc_free2
    call abi_check
    # hbc_rfree: outer pair block wrapping a live DArr2 (depth 2)
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea -96(%rbp), %rdi
    mov $2, %esi
    mov $2, %edx
    call hbc_arraym
    call abi_check
    mov $24, %rdi
    call hbc_alloc
    mov %rax, -32(%rbp)
    call abi_check
    mov -32(%rbp), %rax
    movq $1, (%rax)
    add $8, %rax
    mov %rax, -32(%rbp)
    mov -96(%rbp), %rcx
    mov %rcx, (%rax)
    mov -88(%rbp), %rcx
    mov %rcx, 8(%rax)
    mov -32(%rbp), %rdi
    mov $1, %esi
    mov $2, %edx
    call hbc_rfree
    call abi_check
    # hbc_array3m (2x2x2) + hbc_rfree depth-3 free
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea -96(%rbp), %rdi
    mov $2, %esi
    mov $2, %edx
    mov $2, %ecx
    call hbc_array3m
    call abi_check
    # DArr3 frees via rfree at pair-levels 2: each child is a DArr2 block,
    # freed by hbc_free2 (same route as the generated DArr3 epilogue).
    mov -96(%rbp), %rdi
    mov $2, %esi
    mov $2, %edx
    call hbc_rfree
    call abi_check
    # hbc_array4m (2x2x2x2) + hbc_rfree depth-3 free
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea -96(%rbp), %rdi
    mov $2, %esi
    mov $2, %edx
    mov $2, %ecx
    mov $2, %r8d
    call hbc_array4m
    call abi_check
    # DArr4 frees via rfree at pair-levels 3 (same route as the generated
    # DArr4 epilogue).
    mov -96(%rbp), %rdi
    mov $2, %esi
    mov $3, %edx
    call hbc_rfree
    call abi_check
    # hbc_hkeys on a 2-entry hash: keys come out in insertion order, each
    # an owned copy; hbc_strcpy makes an independent copy of one;
    # hbc_sfree frees the array, hbc_hfree the hash.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $1, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k2(%rip), %rax
    mov %rax, -32(%rbp)
    movq $1, -24(%rbp)
    movq $0, -48(%rbp)
    movq $2, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    call hbc_hkeys
    # Save the result BEFORE abi_check: the canary check clobbers rax.
    mov %rax, -32(%rbp)
    mov %rdx, -24(%rbp)
    call abi_check
    cmpq $2, -24(%rbp)
    jne abi_fail_hk
    mov -32(%rbp), %rax
    cmpq $2, (%rax)
    jne abi_fail_hk
    mov 8(%rax), %rcx
    cmpq $2, -8(%rcx)
    jne abi_fail_hk
    cmpw $0x6261, (%rcx)
    jne abi_fail_hk
    cmpq $2, 16(%rax)
    jne abi_fail_hk
    mov 24(%rax), %rcx
    cmpq $1, -8(%rcx)
    jne abi_fail_hk
    cmpb $0x63, (%rcx)
    jne abi_fail_hk
    mov 8(%rax), %rdi
    mov -8(%rdi), %rsi
    call hbc_strcpy
    # Save the copy pointer BEFORE abi_check (it clobbers rax).
    mov %rax, -16(%rbp)
    call abi_check
    mov -16(%rbp), %rcx
    cmpq $2, -8(%rcx)
    jne abi_fail_hk
    cmpw $0x6261, (%rcx)
    jne abi_fail_hk
    mov %rcx, %rdi
    call hbc_freestr
    call abi_check
    # hbc_strcat (iteration 63e, new helper): copies both operands into a
    # fresh owned buffer (len at -8). Canaries, stack balance and
    # 16-alignment after the call; the result is freed via hbc_freestr like any owned
    # string. Operands here are rodata (nothing to free on that side).
    lea .Labi_ok(%rip), %rdi
    mov $7, %esi
    lea .Labi_ok(%rip), %rdx
    mov $7, %ecx
    call hbc_strcat
    mov %rax, -16(%rbp)
    mov %rdx, -24(%rbp)
    call abi_check
    mov -16(%rbp), %rcx
    cmpq $14, -8(%rcx)
    jne abi_fail_sc
    cmpq $14, -24(%rbp)
    jne abi_fail_sc
    cmpl $0x20494241, (%rcx)
    jne abi_fail_sc
    cmpw $0x4b4f, 4(%rcx)
    jne abi_fail_sc
    cmpb $0x0a, 6(%rcx)
    jne abi_fail_sc
    cmpb $0x41, 7(%rcx)
    jne abi_fail_sc
    mov %rcx, %rdi
    call hbc_freestr
    call abi_check
    mov -32(%rbp), %rdi
    mov $2, %esi
    call hbc_sfree
    call abi_check
    mov -96(%rbp), %rdi
    mov $2, %esi
    call hbc_hfree
    call abi_check
    # hbc_str_xeq: exact comparison - same (ptr,len) pair is 1, a shorter
    # right operand over the same bytes is 0 (lengths must match).
    lea .Labi_ok(%rip), %rax
    mov $7, %edx
    lea .Labi_ok(%rip), %rcx
    mov $7, %r8d
    call hbc_str_xeq
    cmp $1, %rax
    jne abi_fail_sx
    call abi_check
    lea .Labi_ok(%rip), %rax
    mov $7, %edx
    lea .Labi_ok(%rip), %rcx
    mov $6, %r8d
    call hbc_str_xeq
    test %rax, %rax
    jnz abi_fail_sx
    call abi_check
    # hbc_dynxeq_dd: NIL x NIL is 1; NIL x number is 0; number x number
    # by value (1 equal, 0 different); string x string exact via the -8
    # length header (1 equal, 0 different content).
    mov $1, %eax
    xor %edx, %edx
    mov $1, %ecx
    xor %r8d, %r8d
    call hbc_dynxeq_dd
    cmp $1, %rax
    jne abi_fail_xd
    call abi_check
    mov $1, %eax
    xor %edx, %edx
    xor %ecx, %ecx
    mov $7, %r8d
    call hbc_dynxeq_dd
    test %rax, %rax
    jnz abi_fail_xd
    call abi_check
    xor %eax, %eax
    mov $7, %edx
    xor %ecx, %ecx
    mov $7, %r8d
    call hbc_dynxeq_dd
    cmp $1, %rax
    jne abi_fail_xd
    call abi_check
    xor %eax, %eax
    mov $7, %edx
    xor %ecx, %ecx
    mov $8, %r8d
    call hbc_dynxeq_dd
    test %rax, %rax
    jnz abi_fail_xd
    call abi_check
    lea .Labi_ok(%rip), %rdi
    mov $7, %esi
    call hbc_strcpy
    mov %rax, -16(%rbp)
    call abi_check
    lea .Labi_ok(%rip), %rdi
    mov $7, %esi
    call hbc_strcpy
    mov %rax, -48(%rbp)
    call abi_check
    mov $2, %eax
    mov -16(%rbp), %rdx
    mov $2, %ecx
    mov -48(%rbp), %r8
    call hbc_dynxeq_dd
    cmp $1, %rax
    jne abi_fail_xd
    call abi_check
    mov -48(%rbp), %rax
    movb $0x21, (%rax)
    mov $2, %eax
    mov -16(%rbp), %rdx
    mov $2, %ecx
    mov -48(%rbp), %r8
    call hbc_dynxeq_dd
    test %rax, %rax
    jnz abi_fail_xd
    call abi_check
    mov -16(%rbp), %rdi
    call hbc_freestr
    call abi_check
    mov -48(%rbp), %rdi
    call hbc_freestr
    call abi_check
    # hbc_dyn_eq (iteration 44): regressions of the original branches
    # plus the NEW string-content branch, which tail-calls hbc_str_eq -
    # canaries (rbx/r12-r15), stack balance and 16-alignment must survive
    # every call, checked after EACH one. int x int:
    xor %eax, %eax
    mov $7, %edx
    xor %ecx, %ecx
    mov $7, %r8d
    call hbc_dyn_eq
    cmp $1, %rax
    jne abi_fail_de
    call abi_check
    xor %eax, %eax
    mov $7, %edx
    xor %ecx, %ecx
    mov $8, %r8d
    call hbc_dyn_eq
    test %rax, %rax
    jnz abi_fail_de
    call abi_check
    # NIL x NIL is 1, NIL x int is 0:
    mov $1, %eax
    xor %edx, %edx
    mov $1, %ecx
    xor %r8d, %r8d
    call hbc_dyn_eq
    cmp $1, %rax
    jne abi_fail_de
    call abi_check
    mov $1, %eax
    xor %edx, %edx
    xor %ecx, %ecx
    mov $7, %r8d
    call hbc_dyn_eq
    test %rax, %rax
    jnz abi_fail_de
    call abi_check
    # string x NIL is 0 (hk147 branch):
    mov $2, %eax
    xor %edx, %edx
    mov $1, %ecx
    xor %r8d, %r8d
    call hbc_dyn_eq
    test %rax, %rax
    jnz abi_fail_de
    call abi_check
    # string x string: equal content in two DISTINCT heap blocks is 1
    # (content compare via the hbc_str_eq tail call, not pointer):
    lea .Labi_s3(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    mov %rax, -16(%rbp)
    call abi_check
    lea .Labi_s3(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    mov %rax, -48(%rbp)
    call abi_check
    mov $2, %eax
    mov -16(%rbp), %rdx
    mov $2, %ecx
    mov -48(%rbp), %r8
    call hbc_dyn_eq
    cmp $1, %rax
    jne abi_fail_de
    call abi_check
    # different content is 0:
    mov -48(%rbp), %rax
    movb $0x21, (%rax)
    mov $2, %eax
    mov -16(%rbp), %rdx
    mov $2, %ecx
    mov -48(%rbp), %r8
    call hbc_dyn_eq
    test %rax, %rax
    jnz abi_fail_de
    call abi_check
    mov -16(%rbp), %rdi
    call hbc_freestr
    call abi_check
    mov -48(%rbp), %rdi
    call hbc_freestr
    call abi_check
    # prefix rule (hk145): "abcdef" = "abc" is 1, the mirror is 0:
    lea .Labi_s6(%rip), %rdi
    mov $6, %esi
    call hbc_strcpy
    mov %rax, -16(%rbp)
    call abi_check
    lea .Labi_s3(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    mov %rax, -48(%rbp)
    call abi_check
    mov $2, %eax
    mov -16(%rbp), %rdx
    mov $2, %ecx
    mov -48(%rbp), %r8
    call hbc_dyn_eq
    cmp $1, %rax
    jne abi_fail_de
    call abi_check
    mov $2, %eax
    mov -48(%rbp), %rdx
    mov $2, %ecx
    mov -16(%rbp), %r8
    call hbc_dyn_eq
    test %rax, %rax
    jnz abi_fail_de
    call abi_check
    mov -16(%rbp), %rdi
    call hbc_freestr
    call abi_check
    mov -48(%rbp), %rdi
    call hbc_freestr
    call abi_check
    # hbc_dyn_eq tag 3 (iteration 62b): logical casillas compare payloads -
    # .T. = .F. is 0 and .T. = .T. is 1 (the old tag-only shortcut made
    # both 1); a logical is neither the number 1 nor NIL even when the
    # payload bits coincide.
    mov $3, %eax
    mov $1, %edx
    mov $3, %ecx
    xor %r8d, %r8d
    call hbc_dyn_eq
    test %rax, %rax
    jnz abi_fail_de
    call abi_check
    mov $3, %eax
    mov $1, %edx
    mov $3, %ecx
    mov $1, %r8d
    call hbc_dyn_eq
    cmp $1, %rax
    jne abi_fail_de
    call abi_check
    mov $3, %eax
    mov $1, %edx
    xor %ecx, %ecx
    mov $1, %r8d
    call hbc_dyn_eq
    test %rax, %rax
    jnz abi_fail_de
    call abi_check
    mov $3, %eax
    xor %edx, %edx
    mov $1, %ecx
    xor %r8d, %r8d
    call hbc_dyn_eq
    test %rax, %rax
    jnz abi_fail_de
    call abi_check
    # hbc_dyn_to_log (iteration 62b, new helper): a logical casilla keeps
    # its payload - canaries, stack balance and 16-alignment after EACH
    # call. (NIL, integer and string casillas tail-jump to hbc_type_error:
    # Harbour's error condition for a non-logical condition - hk210, the
    # dialog hangs headless - so that route ends the process and is not
    # exercised here.)
    mov $3, %eax
    mov $1, %edx
    call hbc_dyn_to_log
    cmp $1, %rax
    jne abi_fail_dl
    call abi_check
    mov $3, %eax
    xor %edx, %edx
    call hbc_dyn_to_log
    test %rax, %rax
    jnz abi_fail_dl
    call abi_check
    # hbc_dynxcmp (iteration 45): int x int signs (-1/0/1), then the new
    # string x string branch (tail call into hbc_str_cmp) for lt/eq/gt -
    # canaries, stack balance and alignment checked after EACH call.
    xor %eax, %eax
    mov $7, %edx
    xor %ecx, %ecx
    mov $8, %r8d
    mov $1, %r9d
    call hbc_dynxcmp
    cmp $-1, %rax
    jne abi_fail_dc
    call abi_check
    xor %eax, %eax
    mov $7, %edx
    xor %ecx, %ecx
    mov $7, %r8d
    mov $1, %r9d
    call hbc_dynxcmp
    test %rax, %rax
    jnz abi_fail_dc
    call abi_check
    xor %eax, %eax
    mov $8, %edx
    xor %ecx, %ecx
    mov $7, %r8d
    mov $2, %r9d
    call hbc_dynxcmp
    cmp $1, %rax
    jne abi_fail_dc
    call abi_check
    # string x string: "abc" vs "abd" is -1; equal content is 0; the
    # byte-wise comparison goes through the hbc_str_cmp tail call.
    lea .Labi_s3(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    mov %rax, -16(%rbp)
    call abi_check
    lea .Labi_s3(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    mov %rax, -48(%rbp)
    call abi_check
    mov -48(%rbp), %rax
    movb $0x64, 2(%rax)
    mov $2, %eax
    mov -16(%rbp), %rdx
    mov $2, %ecx
    mov -48(%rbp), %r8
    mov $1, %r9d
    call hbc_dynxcmp
    cmp $-1, %rax
    jne abi_fail_dc
    call abi_check
    mov $2, %eax
    mov -48(%rbp), %rdx
    mov $2, %ecx
    mov -16(%rbp), %r8
    mov $2, %r9d
    call hbc_dynxcmp
    cmp $1, %rax
    jne abi_fail_dc
    call abi_check
    mov -48(%rbp), %rax
    movb $0x63, 2(%rax)
    mov $2, %eax
    mov -16(%rbp), %rdx
    mov $2, %ecx
    mov -48(%rbp), %r8
    mov $3, %r9d
    call hbc_dynxcmp
    test %rax, %rax
    jnz abi_fail_dc
    call abi_check
    mov -16(%rbp), %rdi
    call hbc_freestr
    call abi_check
    mov -48(%rbp), %rdi
    call hbc_freestr
    call abi_check
    # hbc_hvalues (iteration 46): a 2-entry hash yields a NEW array of
    # the value cells in insertion order - count, tags and payloads
    # verified, then freed; canaries/stack/alignment after each call.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k2(%rip), %rax
    mov %rax, -32(%rbp)
    movq $1, -24(%rbp)
    movq $0, -48(%rbp)
    movq $9, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    call hbc_hvalues
    # Save the result BEFORE abi_check (it clobbers rax).
    mov %rax, -32(%rbp)
    mov %rdx, -24(%rbp)
    call abi_check
    cmpq $2, -24(%rbp)
    jne abi_fail_hv
    mov -32(%rbp), %rax
    cmpq $0, (%rax)
    jne abi_fail_hv
    cmpq $7, 8(%rax)
    jne abi_fail_hv
    cmpq $0, 16(%rax)
    jne abi_fail_hv
    cmpq $9, 24(%rax)
    jne abi_fail_hv
    mov %rax, %rdi
    mov $16, %esi
    call hbc_free
    call abi_check
    mov -96(%rbp), %rdi
    mov $2, %esi
    call hbc_hfree
    call abi_check
    # hbc_hdel (iteration 47): three entries "ab"/"c"/"zz"; deleting the
    # middle key frees its copy and shifts "zz" down (count 2, values and
    # order verified); a second delete of the now-missing key is a no-op.
    # Canaries/stack/alignment after every call.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $1, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k2(%rip), %rax
    mov %rax, -32(%rbp)
    movq $1, -24(%rbp)
    movq $0, -48(%rbp)
    movq $2, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k3(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $3, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    lea .Labi_k2(%rip), %rsi
    mov $1, %edx
    call hbc_hdel
    call abi_check
    cmpq $2, -88(%rbp)
    jne abi_fail_hd
    mov -96(%rbp), %rax
    cmpq $2, 8(%rax)
    jne abi_fail_hd
    mov (%rax), %rcx
    cmpw $0x6261, (%rcx)
    jne abi_fail_hd
    cmpq $1, 24(%rax)
    jne abi_fail_hd
    cmpq $2, 40(%rax)
    jne abi_fail_hd
    mov 32(%rax), %rcx
    cmpw $0x7a7a, (%rcx)
    jne abi_fail_hd
    cmpq $3, 56(%rax)
    jne abi_fail_hd
    lea -96(%rbp), %rdi
    lea .Labi_k2(%rip), %rsi
    mov $1, %edx
    call hbc_hdel
    call abi_check
    cmpq $2, -88(%rbp)
    jne abi_fail_hd
    mov -96(%rbp), %rdi
    mov $2, %esi
    call hbc_hfree
    call abi_check
    # hbc_hhaskey (iteration 48): a 1-entry hash answers 1 for its key
    # and 0 for a missing one; leaf helper, canaries/stack/alignment
    # after every call.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    lea .Labi_k1(%rip), %rsi
    mov $2, %edx
    call hbc_hhaskey
    # Save the result BEFORE abi_check: the canary check clobbers rax.
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $1, -32(%rbp)
    jne abi_fail_hh
    lea -96(%rbp), %rdi
    lea .Labi_k2(%rip), %rsi
    mov $1, %edx
    call hbc_hhaskey
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    jne abi_fail_hh
    mov -96(%rbp), %rdi
    mov $1, %esi
    call hbc_hfree
    call abi_check
    # hbc_hget canary (iteration 49): a 1-entry hash returns a pointer
    # to the entry's {tag, payload} on a hit (verified) and 0 on a miss;
    # read-only. Results saved BEFORE abi_check (it clobbers rax).
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    lea .Labi_k1(%rip), %rsi
    mov $2, %edx
    call hbc_hget
    mov %rax, -32(%rbp)
    call abi_check
    mov -32(%rbp), %rax
    test %rax, %rax
    je abi_fail_hg
    cmpq $0, (%rax)
    jne abi_fail_hg
    cmpq $7, 8(%rax)
    jne abi_fail_hg
    lea -96(%rbp), %rdi
    lea .Labi_k2(%rip), %rsi
    mov $1, %edx
    call hbc_hget
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    jne abi_fail_hg
    mov -96(%rbp), %rdi
    mov $1, %esi
    call hbc_hfree
    call abi_check
    # hbc_hpos canary (iteration 51): a 2-entry hash answers the
    # 1-based live position on a hit (1 and 2) and 0 on a miss; leaf,
    # read-only. Results saved BEFORE abi_check (it clobbers rax).
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k2(%rip), %rax
    mov %rax, -32(%rbp)
    movq $1, -24(%rbp)
    movq $0, -48(%rbp)
    movq $9, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    lea .Labi_k1(%rip), %rsi
    mov $2, %edx
    call hbc_hpos
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $1, -32(%rbp)
    jne abi_fail_hp
    lea -96(%rbp), %rdi
    lea .Labi_k2(%rip), %rsi
    mov $1, %edx
    call hbc_hpos
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $2, -32(%rbp)
    jne abi_fail_hp
    lea -96(%rbp), %rdi
    lea .Labi_k3(%rip), %rsi
    mov $2, %edx
    call hbc_hpos
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    jne abi_fail_hp
    # hbc_hscan canary (iteration 57): the same 2-entry hash
    # {"k1"=>7, "k2"=>9} answers the 1-based position on a value hit
    # (9 -> 2), honours the start offset (7 from start 2 -> 0) and
    # answers 0 for a NIL value against integer entries. Leaf,
    # read-only. Results saved BEFORE abi_check (it clobbers rax).
    lea -96(%rbp), %rdi
    xor %esi, %esi
    mov $9, %edx
    xor %ecx, %ecx
    call hbc_hscan
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $2, -32(%rbp)
    jne abi_fail_hs
    lea -96(%rbp), %rdi
    xor %esi, %esi
    mov $7, %edx
    mov $2, %ecx
    call hbc_hscan
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    jne abi_fail_hs
    lea -96(%rbp), %rdi
    mov $1, %esi
    xor %edx, %edx
    xor %ecx, %ecx
    call hbc_hscan
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    jne abi_fail_hs
    # hbc_hkeyat / hbc_hvalueat canary (iteration 58): the same
    # 2-entry hash {"ab"=>7, "c"=>9} answers the key ptr/len at
    # position 1 ("ab", len 2), 0 for an out-of-range key position,
    # and the value {tag 0, payload 9} at position 2. Leaf,
    # read-only. Results saved BEFORE abi_check (it clobbers rax).
    lea -96(%rbp), %rdi
    mov $1, %esi
    call hbc_hkeyat
    mov %rax, -32(%rbp)
    mov %rdx, -24(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    je abi_fail_hka
    cmpq $2, -24(%rbp)
    jne abi_fail_hka
    mov -32(%rbp), %rax
    cmpb $97, (%rax)
    jne abi_fail_hka
    lea -96(%rbp), %rdi
    mov $3, %esi
    call hbc_hkeyat
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    jne abi_fail_hka
    lea -96(%rbp), %rdi
    mov $2, %esi
    call hbc_hvalueat
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    je abi_fail_hka
    mov -32(%rbp), %rax
    cmpq $0, (%rax)
    jne abi_fail_hka
    cmpq $9, 8(%rax)
    jne abi_fail_hka
    mov -96(%rbp), %rdi
    mov $2, %esi
    call hbc_hfree
    call abi_check
    # hbc_hdelat canary (iteration 59): a fresh 2-entry hash
    # {"ab"=>7, "c"=>9} loses position 1 (count 1, "c"/9 compacts to
    # the first slot); an out-of-range position answers 0 and changes
    # nothing. Frame-based (hbc_free): canaries, stack balance and
    # alignment after every call; the registry checks the freed key.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k2(%rip), %rax
    mov %rax, -32(%rbp)
    movq $1, -24(%rbp)
    movq $0, -48(%rbp)
    movq $9, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    mov $1, %esi
    call hbc_hdelat
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $1, -32(%rbp)
    jne abi_fail_hda
    cmpq $1, -88(%rbp)
    jne abi_fail_hda
    mov -96(%rbp), %rax
    mov (%rax), %rcx
    cmpb $99, (%rcx)
    jne abi_fail_hda
    cmpq $9, 24(%rax)
    jne abi_fail_hda
    lea -96(%rbp), %rdi
    mov $2, %esi
    call hbc_hdelat
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    jne abi_fail_hda
    cmpq $1, -88(%rbp)
    jne abi_fail_hda
    mov -96(%rbp), %rdi
    mov $1, %esi
    call hbc_hfree
    call abi_check
    # hbc_hfill canary (iteration 60): a fresh 2-entry hash
    # {"ab"=>7, "c"=>9} gets every value overwritten with
    # {tag 0, payload 42}; keys, count and insertion order survive
    # (hk192). Leaf helper, no allocation: canaries, stack balance
    # and alignment after the call.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k2(%rip), %rax
    mov %rax, -32(%rbp)
    movq $1, -24(%rbp)
    movq $0, -48(%rbp)
    movq $9, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    xor %esi, %esi
    mov $42, %edx
    call hbc_hfill
    call abi_check
    cmpq $2, -88(%rbp)
    jne abi_fail_hf
    mov -96(%rbp), %rax
    cmpq $42, 24(%rax)
    jne abi_fail_hf
    cmpq $42, 56(%rax)
    jne abi_fail_hf
    mov (%rax), %rcx
    cmpb $97, (%rcx)
    jne abi_fail_hf
    mov 32(%rax), %rcx
    cmpb $99, (%rcx)
    jne abi_fail_hf
    # hbc_hclear canary (iteration 60): the filled 2-entry hash
    # empties: the slot goes to (0, 0), the key copies and the data
    # block are released (the instrumented registry verifies every
    # free) and the hash stays reusable (hk191/hk193). Clearing an
    # empty slot is a no-op. Frame-based (hbc_free/hbc_hfreeblock):
    # canaries, stack balance and alignment after the call.
    lea -96(%rbp), %rdi
    call hbc_hclear
    call abi_check
    cmpq $0, -96(%rbp)
    jne abi_fail_hcl
    cmpq $0, -88(%rbp)
    jne abi_fail_hcl
    lea -96(%rbp), %rdi
    call hbc_hclear
    call abi_check
    # hbc_hmerge canary (iteration 54): dst {ab=>7} + src {ab=>9, c=>5}
    # leaves dst with the source winning in place and the new key
    # appended (hk164); the source keeps its 2 entries (hk165).
    # Frame-based helper (hbc_hput allocates): canaries, stack balance
    # and alignment after every call; hget verifies the merged values.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    movq $0, -128(%rbp)
    movq $0, -120(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $9, -40(%rbp)
    lea -128(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k2(%rip), %rax
    mov %rax, -32(%rbp)
    movq $1, -24(%rbp)
    movq $0, -48(%rbp)
    movq $5, -40(%rbp)
    lea -128(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    lea -128(%rbp), %rsi
    call hbc_hmerge
    call abi_check
    cmpq $2, -88(%rbp)
    jne abi_fail_hm
    cmpq $2, -120(%rbp)
    jne abi_fail_hm
    lea -96(%rbp), %rdi
    lea .Labi_k1(%rip), %rsi
    mov $2, %edx
    call hbc_hget
    mov %rax, -32(%rbp)
    call abi_check
    mov -32(%rbp), %rax
    test %rax, %rax
    je abi_fail_hm
    cmpq $9, 8(%rax)
    jne abi_fail_hm
    lea -96(%rbp), %rdi
    lea .Labi_k2(%rip), %rsi
    mov $1, %edx
    call hbc_hget
    mov %rax, -32(%rbp)
    call abi_check
    mov -32(%rbp), %rax
    test %rax, %rax
    je abi_fail_hm
    cmpq $5, 8(%rax)
    jne abi_fail_hm
    mov -96(%rbp), %rdi
    mov $2, %esi
    call hbc_hfree
    call abi_check
    mov -128(%rbp), %rdi
    mov $2, %esi
    call hbc_hfree
    call abi_check
    # hbc_hclone canary (iteration 55): clone {ab=>7, c=>5}, overwrite
    # ab=>9 in the ORIGINAL, the clone must keep 7 (deep independence,
    # hk166). Frame-based helper (hput allocates): canaries, stack
    # balance and alignment after every call.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k2(%rip), %rax
    mov %rax, -32(%rbp)
    movq $1, -24(%rbp)
    movq $0, -48(%rbp)
    movq $5, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    call hbc_hclone
    mov %rax, -128(%rbp)
    mov %rdx, -120(%rbp)
    call abi_check
    cmpq $2, -120(%rbp)
    jne abi_fail_hc
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $9, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -128(%rbp), %rdi
    lea .Labi_k1(%rip), %rsi
    mov $2, %edx
    call hbc_hget
    mov %rax, -32(%rbp)
    call abi_check
    mov -32(%rbp), %rax
    test %rax, %rax
    je abi_fail_hc
    cmpq $7, 8(%rax)
    jne abi_fail_hc
    mov -96(%rbp), %rdi
    mov $2, %esi
    call hbc_hfree
    call abi_check
    mov -128(%rbp), %rdi
    mov $2, %esi
    call hbc_hfree
    call abi_check
    # hbc_hcasematch / hbc_hsetcasematch canary (iteration 56): the
    # default on an untouched empty slot is 1 (hk169); setting 0 on a
    # fresh empty slot grows a header-only block (hk176); the flag reads
    # back; a case-variant lookup then matches case-insensitively and
    # the grow frees the header-only block through hbc_hfreeblock.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea -96(%rbp), %rdi
    call hbc_hcasematch
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $1, -32(%rbp)
    jne abi_fail_hc
    lea -96(%rbp), %rdi
    xor %esi, %esi
    call hbc_hsetcasematch
    call abi_check
    lea -96(%rbp), %rdi
    call hbc_hcasematch
    mov %rax, -32(%rbp)
    call abi_check
    cmpq $0, -32(%rbp)
    jne abi_fail_hc
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    lea .Labi_k4(%rip), %rsi
    mov $2, %edx
    call hbc_hget
    mov %rax, -32(%rbp)
    call abi_check
    mov -32(%rbp), %rax
    test %rax, %rax
    je abi_fail_hc
    cmpq $7, 8(%rax)
    jne abi_fail_hc
    mov -96(%rbp), %rdi
    mov $1, %esi
    call hbc_hfree
    call abi_check
    # a header-only block (never grown) freed through hbc_hfree ->
    # hbc_hfreeblock, both targets' registry
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea -96(%rbp), %rdi
    mov $1, %esi
    call hbc_hsetcasematch
    call abi_check
    mov -96(%rbp), %rdi
    xor %esi, %esi
    call hbc_hfree
    call abi_check
    # hbc_hsetdef canary (iteration 61): on {ab=>7} - hit with the
    # same tag keeps 7; a miss adds the default; a hit with a
    # DIFFERENT tag overwrites (stored NIL family, hk196b); a hit
    # with NO default always keeps (hk196d). Frame-based helper
    # (hbc_hget/hbc_hput): canaries, balance and alignment after
    # every call.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    # hit, same tag (0), def 99 -> keeps 7, returns (0, 7)
    movq $0, -48(%rbp)
    movq $99, -40(%rbp)
    lea -96(%rbp), %rdi
    lea .Labi_k1(%rip), %rsi
    mov $2, %edx
    lea -48(%rbp), %rcx
    mov $1, %r8d
    call hbc_hsetdef
    mov %rax, -64(%rbp)
    mov %rdx, -72(%rbp)
    call abi_check
    mov -64(%rbp), %rax
    mov -72(%rbp), %rdx
    test %rax, %rax
    jne abi_fail_hsdA
    cmpq $7, %rdx
    jne abi_fail_hsdA
    cmpq $1, -88(%rbp)
    jne abi_fail_hsdA
    # miss with def 42 -> adds c=42, returns (0, 42), count 2
    movq $0, -48(%rbp)
    movq $42, -40(%rbp)
    lea -96(%rbp), %rdi
    lea .Labi_k2(%rip), %rsi
    mov $1, %edx
    lea -48(%rbp), %rcx
    mov $1, %r8d
    call hbc_hsetdef
    mov %rax, -64(%rbp)
    mov %rdx, -72(%rbp)
    call abi_check
    mov -64(%rbp), %rax
    mov -72(%rbp), %rdx
    test %rax, %rax
    jne abi_fail_hsdB
    cmpq $42, %rdx
    jne abi_fail_hsdB
    cmpq $2, -88(%rbp)
    jne abi_fail_hsdB
    # hit with a DIFFERENT tag (NIL def) -> overwrites ab to NIL
    movq $1, -48(%rbp)
    movq $0, -40(%rbp)
    lea -96(%rbp), %rdi
    lea .Labi_k1(%rip), %rsi
    mov $2, %edx
    lea -48(%rbp), %rcx
    mov $1, %r8d
    call hbc_hsetdef
    mov %rax, -64(%rbp)
    call abi_check
    mov -64(%rbp), %rax
    cmpq $1, %rax
    jne abi_fail_hsdC
    # hit with NO default -> keeps the stored NIL (hk196d)
    lea -96(%rbp), %rdi
    lea .Labi_k1(%rip), %rsi
    mov $2, %edx
    lea -48(%rbp), %rcx
    xor %r8d, %r8d
    call hbc_hsetdef
    mov %rax, -64(%rbp)
    call abi_check
    mov -64(%rbp), %rax
    cmpq $1, %rax
    jne abi_fail_hsdD
    mov -96(%rbp), %rdi
    mov $1, %esi
    call hbc_hfree
    call abi_check
    # hbc_hcopy canary (iteration 61): src {ab=>7, c=>42}, dst
    # {zz=>1}; a full copy upserts both (new keys append, zz
    # survives -> count 3, hk195) and a start past the end is a
    # no-op (hk195b). Frame-based helper (hbc_hput allocates):
    # canaries, balance and alignment after every call.
    movq $0, -96(%rbp)
    movq $0, -88(%rbp)
    movq $0, -128(%rbp)
    movq $0, -120(%rbp)
    lea .Labi_k1(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $7, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k2(%rip), %rax
    mov %rax, -32(%rbp)
    movq $1, -24(%rbp)
    movq $42, -40(%rbp)
    lea -96(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea .Labi_k3(%rip), %rax
    mov %rax, -32(%rbp)
    movq $2, -24(%rbp)
    movq $0, -48(%rbp)
    movq $1, -40(%rbp)
    lea -128(%rbp), %rdi
    mov -32(%rbp), %rsi
    mov -24(%rbp), %rdx
    lea -48(%rbp), %rcx
    call hbc_hput
    call abi_check
    lea -96(%rbp), %rdi
    lea -128(%rbp), %rsi
    mov $1, %edx
    mov $-1, %rcx
    call hbc_hcopy
    call abi_check
    cmpq $3, -120(%rbp)
    jne abi_fail_hcp
    lea -128(%rbp), %rdi
    lea .Labi_k1(%rip), %rsi
    mov $2, %edx
    call hbc_hget
    mov %rax, -64(%rbp)
    call abi_check
    mov -64(%rbp), %rax
    test %rax, %rax
    je abi_fail_hcp
    cmpq $7, 8(%rax)
    jne abi_fail_hcp
    lea -128(%rbp), %rdi
    lea .Labi_k3(%rip), %rsi
    mov $2, %edx
    call hbc_hget
    mov %rax, -64(%rbp)
    call abi_check
    mov -64(%rbp), %rax
    test %rax, %rax
    je abi_fail_hcp
    cmpq $1, 8(%rax)
    jne abi_fail_hcp
    lea -96(%rbp), %rdi
    lea -128(%rbp), %rsi
    mov $99, %edx
    mov $-1, %rcx
    call hbc_hcopy
    call abi_check
    cmpq $3, -120(%rbp)
    jne abi_fail_hcp
    mov -96(%rbp), %rdi
    mov $1, %esi
    call hbc_hfree
    call abi_check
    mov -128(%rbp), %rdi
    mov $1, %esi
    call hbc_hfree
    call abi_check
    # hbc_strgrow (63h): realloc path frees the old buffer itself and
    # doubles capacity (max(2*cap, needed)); the in-place path returns the
    # SAME pointer; header cap at -16, len at -8; hbc_freestr releases the
    # final buffer (registry-validated). strcpy("ab") starts cap==len==2.
    lea .Lsg_a(%rip), %rdi
    mov $2, %esi
    call hbc_strcpy
    mov %rax, -104(%rbp)
    call abi_check
    # grow 1: need 8 > cap 2 -> realloc, cap = max(4, 8) = 8, len 8
    mov -104(%rbp), %rdi
    lea .Lsg_b(%rip), %rsi
    mov $6, %edx
    call hbc_strgrow
    mov %rax, -104(%rbp)
    call abi_check
    cmp $8, %rdx
    jne abi_fail_sg
    mov -104(%rbp), %rax
    cmpq $8, -16(%rax)
    jne abi_fail_sg
    cmpq $8, -8(%rax)
    jne abi_fail_sg
    # grow 2: need 9 > cap 8 -> realloc, cap = max(16, 9) = 16
    mov -104(%rbp), %rdi
    lea .Lsg_c(%rip), %rsi
    mov $1, %edx
    call hbc_strgrow
    mov %rax, -104(%rbp)
    call abi_check
    mov -104(%rbp), %rax
    cmpq $16, -16(%rax)
    jne abi_fail_sg
    # grow 3: need 11 <= cap 16 -> IN PLACE, same data pointer
    mov %rax, -112(%rbp)
    mov -104(%rbp), %rdi
    lea .Lsg_d(%rip), %rsi
    mov $2, %edx
    call hbc_strgrow
    cmp %rax, -112(%rbp)
    jne abi_fail_sg
    cmp $11, %rdx
    jne abi_fail_sg
    mov %rax, -104(%rbp)
    call abi_check
    # content: "ab" + "cdefgh" + "x" + "yz" = "abcdefghxyz"
    mov -104(%rbp), %rax
    mov $11, %edx
    lea .Lsg_full(%rip), %rcx
    mov $11, %r8d
    call hbc_str_eq
    cmp $1, %rax
    jne abi_fail_sg
    call abi_check
    mov -104(%rbp), %rdi
    call hbc_freestr
    call abi_check
    # --- Dyn tag-4 owned-string casillas (63j): the changed Dyn helpers.
    # tag 4 must behave exactly like tag 2 (borrowed) in comparisons and
    # printing; canaries cover both operands, callee-saved registers and
    # stack alignment through every call.
    lea .Lt4_a(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    mov %rax, -104(%rbp)
    call abi_check
    lea .Lt4_b(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    mov %rax, -112(%rbp)
    call abi_check
    lea .Lt4_c(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    mov %rax, -120(%rbp)
    call abi_check
    # hbc_dyn_eq: {4,a} x {4,b} equal content -> 1 (prefix rule, right len)
    mov $4, %eax
    mov -104(%rbp), %rdx
    mov $4, %ecx
    mov -112(%rbp), %r8
    call hbc_dyn_eq
    cmp $1, %rax
    jne abi_fail_t4
    call abi_check
    # hbc_dyn_eq: {4,a} x {4,c} different content -> 0
    mov $4, %eax
    mov -104(%rbp), %rdx
    mov $4, %ecx
    mov -120(%rbp), %r8
    call hbc_dyn_eq
    test %rax, %rax
    jnz abi_fail_t4
    call abi_check
    # hbc_dyn_eq: {4,a} owned x {2,b} borrowed, same content -> 1
    # (normalization fires on BOTH operands)
    mov $4, %eax
    mov -104(%rbp), %rdx
    mov $2, %ecx
    mov -112(%rbp), %r8
    call hbc_dyn_eq
    cmp $1, %rax
    jne abi_fail_t4
    call abi_check
    # hbc_dynxeq_dd (==): {4,a} x {4,b} -> 1; {4,a} x {4,c} -> 0
    mov $4, %eax
    mov -104(%rbp), %rdx
    mov $4, %ecx
    mov -112(%rbp), %r8
    call hbc_dynxeq_dd
    cmp $1, %rax
    jne abi_fail_t4
    call abi_check
    mov $4, %eax
    mov -104(%rbp), %rdx
    mov $4, %ecx
    mov -120(%rbp), %r8
    call hbc_dynxeq_dd
    test %rax, %rax
    jnz abi_fail_t4
    call abi_check
    # hbc_dynxcmp: {4,a} vs {4,c} -> -1; {4,c} vs {4,a} -> 1; equal -> 0
    mov $4, %eax
    mov -104(%rbp), %rdx
    mov $4, %ecx
    mov -120(%rbp), %r8
    mov $1, %r9d
    call hbc_dynxcmp
    cmp $-1, %rax
    jne abi_fail_t4
    call abi_check
    mov $4, %eax
    mov -120(%rbp), %rdx
    mov $4, %ecx
    mov -104(%rbp), %r8
    mov $2, %r9d
    call hbc_dynxcmp
    cmp $1, %rax
    jne abi_fail_t4
    call abi_check
    mov $4, %eax
    mov -104(%rbp), %rdx
    mov $4, %ecx
    mov -112(%rbp), %r8
    mov $1, %r9d
    call hbc_dynxcmp
    test %rax, %rax
    jnz abi_fail_t4
    call abi_check
    # hbc_print_dyn: tag-4 dispatch on an EMPTY owned string prints zero
    # bytes (the harness output must stay exactly "ABI OK"); the dispatch
    # and the header read at payload-8 still execute.
    mov -104(%rbp), %rdi
    xor %esi, %esi
    call hbc_strcpy
    mov %rax, -80(%rbp)
    call abi_check
    mov $4, %eax
    mov -80(%rbp), %rdx
    call hbc_print_dyn
    call abi_check
    mov -80(%rbp), %rdi
    call hbc_freestr
    call abi_check
    # teardown: the registry validates each free against its allocation
    mov -104(%rbp), %rdi
    call hbc_freestr
    call abi_check
    mov -112(%rbp), %rdi
    call hbc_freestr
    call abi_check
    mov -120(%rbp), %rdi
    call hbc_freestr
    call abi_check
    # hbc_print_f64 canary (63x/63za): value in %xmm0, PACKED metadata in
    # %rdi (Harbour item length 10 in the high byte, written decimals in
    # the low byte; 63za runtime division sets length 20 for |d|>9999999999).
    # xmm6-xmm15 sentinels (callee-saved on Windows, all clobber-suspect on
    # SysV) + rbx/r12-r15 + stack balance/alignment must survive the call.
    movabs $0x3FF8000000000000, %rax   # 1.5
    movq %rax, %xmm0
    mov $655361, %edi                   # (10 << 16) | 1
    movabs $0x0606060606060601, %rax
    movq %rax, %xmm6
    movabs $0x0707070707070701, %rax
    movq %rax, %xmm7
    movabs $0x0808080808080801, %rax
    movq %rax, %xmm8
    movabs $0x0909090909090901, %rax
    movq %rax, %xmm9
    movabs $0x1010101010101001, %rax
    movq %rax, %xmm10
    movabs $0x1111111111111101, %rax
    movq %rax, %xmm11
    movabs $0x1212121212121202, %rax
    movq %rax, %xmm12
    movabs $0x1313131313131302, %rax
    movq %rax, %xmm13
    movabs $0x1414141414141402, %rax
    movq %rax, %xmm14
    movabs $0x1515151515151502, %rax
    movq %rax, %xmm15
    call hbc_print_f64
    movabs $0x0606060606060601, %rax
    movq %xmm6, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x0707070707070701, %rax
    movq %xmm7, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x0808080808080801, %rax
    movq %xmm8, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x0909090909090901, %rax
    movq %xmm9, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x1010101010101001, %rax
    movq %xmm10, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x1111111111111101, %rax
    movq %xmm11, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x1212121212121202, %rax
    movq %xmm12, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x1313131313131302, %rax
    movq %xmm13, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x1414141414141402, %rax
    movq %xmm14, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x1515151515151502, %rax
    movq %xmm15, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    call abi_check
    # hbc_round canary (63zp, new symbol): n in %xmm0, raw d in %rdi;
    # result pair %xmm0 + PACKED %rdi (dec | length<<16). Round(1.005, 2)
    # = 1.01 exactly (the HB_DBLFL_PREC_FACTOR ulp-lift case, hk386).
    # xmm6/xmm7 sentinels survive; abi_check owns rbx/r12-r15/stk.
    movabs $0x3ff0147ae147ae14, %rax
    movq %rax, %xmm0
    mov $2, %edi
    movabs $0x2121212121212101, %rax
    movq %rax, %xmm6
    movabs $0x2222222222222202, %rax
    movq %rax, %xmm7
    call hbc_round
    movabs $0x3ff028f5c28f5c29, %rax
    movq %xmm0, %rdx
    cmp %rax, %rdx
    jne abi_fail_round
    mov $655362, %eax
    cmp %rax, %rdi
    jne abi_fail_round
    movabs $0x2121212121212101, %rax
    movq %xmm6, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    movabs $0x2222222222222202, %rax
    movq %xmm7, %rdx
    cmp %rax, %rdx
    jne abi_fail_xmm
    call abi_check
    # hbc_print_i64c (63zf, new entry): computed integer field. Positive
    # small, positive at and over the 9999999999 threshold, negative at
    # and over the -999999999 threshold, and the Dyn numeric payload path
    # (tag 0) which now routes here. Canaries, 16-alignment and stack
    # balance around every call; the printed fields land on stdout and
    # are part of the expected output below, on BOTH targets.
    mov $5, %rax
    call hbc_print_i64c
    call abi_check
    mov $9999999999, %rax
    call hbc_print_i64c
    call abi_check
    mov $10000000000, %rax
    call hbc_print_i64c
    call abi_check
    mov $-999999999, %rax
    call hbc_print_i64c
    call abi_check
    mov $-1000000000, %rax
    call hbc_print_i64c
    call abi_check
    xor %eax, %eax
    mov $50000005000000, %rdx
    call hbc_print_dyn
    call abi_check
    lea .Labi_ok(%rip), %rax
    mov $7, %edx
    call hbc_print_str
    xor %eax, %eax
    leave
    ret

abi_canary_set:
    movabs $0x0B0B0B0B0B0B0B01, %rbx
    movabs $0x1212121212121201, %r12
    movabs $0x1313131313131301, %r13
    movabs $0x1414141414141401, %r14
    movabs $0x1515151515151501, %r15
    ret

# abi_check runs inside hbc_abi_test's frame (rbp intact): verifies the
# canaries, the stack balance and the 16-alignment at the call boundary.
abi_check:
    movabs $0x0B0B0B0B0B0B0B01, %rax
    cmp %rax, %rbx
    jne abi_fail_rbx
    movabs $0x1212121212121201, %rax
    cmp %rax, %r12
    jne abi_fail_r12
    movabs $0x1313131313131301, %rax
    cmp %rax, %r13
    jne abi_fail_r13
    movabs $0x1414141414141401, %rax
    cmp %rax, %r14
    jne abi_fail_r14
    movabs $0x1515151515151501, %rax
    cmp %rax, %r15
    jne abi_fail_r15
    lea 8(%rsp), %rax
    cmp -8(%rbp), %rax
    jne abi_fail_stk
    mov %rsp, %rax
    and $15, %rax
    cmp $8, %rax
    jne abi_fail_align
    ret

abi_fail_rbx:
    lea .Labi_f_rbx(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_r12:
    lea .Labi_f_r12(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_r13:
    lea .Labi_f_r13(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_r14:
    lea .Labi_f_r14(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_r15:
    lea .Labi_f_r15(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_stk:
    lea .Labi_f_stk(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_align:
    lea .Labi_f_aln(%rip), %rax
    mov $14, %edx
    jmp abi_fail_common
abi_fail_sx:
    lea .Labi_f_sx(%rip), %rax
    mov $11, %edx
    jmp abi_fail_common
abi_fail_hk:
    lea .Labi_f_hk(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_xd:
    lea .Labi_f_xd(%rip), %rax
    mov $11, %edx
    jmp abi_fail_common
abi_fail_de:
    lea .Labi_f_de(%rip), %rax
    mov $13, %edx
    jmp abi_fail_common
abi_fail_sc:
    lea .Labi_f_sc(%rip), %rax
    mov $13, %edx
    jmp abi_fail_common
abi_fail_dl:
    lea .Labi_f_dl(%rip), %rax
    mov $13, %edx
    jmp abi_fail_common
abi_fail_dc:
    lea .Labi_f_dc(%rip), %rax
    mov $13, %edx
    jmp abi_fail_common
abi_fail_hv:
    lea .Labi_f_hv(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_hd:
    lea .Labi_f_hd(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_hh:
    lea .Labi_f_hh(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_hg:
    lea .Labi_f_hg(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_hp:
    lea .Labi_f_hp(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_hs:
    lea .Labi_f_hs(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_hka:
    lea .Labi_f_hka(%rip), %rax
    mov $13, %edx
    jmp abi_fail_common
abi_fail_hda:
    lea .Labi_f_hda(%rip), %rax
    mov $13, %edx
    jmp abi_fail_common
abi_fail_hf:
    lea .Labi_f_hf(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_hcl:
    lea .Labi_f_hcl(%rip), %rax
    mov $13, %edx
    jmp abi_fail_common
abi_fail_hm:
    lea .Labi_f_hm(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_hc:
    lea .Labi_f_hc(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_hsdA:
    lea .Labi_f_hsdA(%rip), %rax
    mov $14, %edx
    jmp abi_fail_common
abi_fail_hsdB:
    lea .Labi_f_hsdB(%rip), %rax
    mov $14, %edx
    jmp abi_fail_common
abi_fail_hsdC:
    lea .Labi_f_hsdC(%rip), %rax
    mov $14, %edx
    jmp abi_fail_common
abi_fail_hsdD:
    lea .Labi_f_hsdD(%rip), %rax
    mov $14, %edx
    jmp abi_fail_common
abi_fail_hcp:
    lea .Labi_f_hcp(%rip), %rax
    mov $13, %edx
    jmp abi_fail_common
abi_fail_sg:
    lea .Labi_f_sg(%rip), %rax
    mov $13, %edx
    jmp abi_fail_common
abi_fail_t4:
    lea .Labi_f_t4(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_xmm:
    lea .Labi_f_xmm(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_round:
    lea .Labi_f_round(%rip), %rax
    mov $12, %edx
    jmp abi_fail_common
abi_fail_common:
    call hbc_print_str
ASM_EOF
  if [ "$3" = linux ]; then
    cat >> "$2" <<'ASM_EOF'
    mov $60, %eax
    mov $1, %edi
    syscall
ASM_EOF
  else
    cat >> "$2" <<'ASM_EOF'
    and $-16, %rsp
    sub $48, %rsp
    mov $1, %ecx
    call ExitProcess
ASM_EOF
  fi
  cat >> "$2" <<'ASM_EOF'
    .section .rodata
.Labi_ok:    .ascii "ABI OK\n"
.Labi_f_rbx: .ascii "ABI FAIL rbx\n"
.Labi_f_r12: .ascii "ABI FAIL r12\n"
.Labi_f_r13: .ascii "ABI FAIL r13\n"
.Labi_f_r14: .ascii "ABI FAIL r14\n"
.Labi_f_r15: .ascii "ABI FAIL r15\n"
.Labi_f_stk: .ascii "ABI FAIL stk\n"
.Labi_f_aln: .ascii "ABI FAIL align\n"
.Labi_f_sx:  .ascii "ABI FAIL xeq\n"
.Labi_f_hk:  .ascii "ABI FAIL hk\n"
.Labi_f_xd:  .ascii "ABI FAIL xd\n"
.Labi_k1:    .ascii "ab"
.Labi_k2:    .ascii "c"
.Labi_k3:    .ascii "zz"
.Labi_k4:    .ascii "AB"
.Labi_f_hd:  .ascii "ABI FAIL hd\n"
.Labi_f_hh:  .ascii "ABI FAIL hh\n"
.Labi_f_hg:  .ascii "ABI FAIL hg\n"
.Labi_f_hp:  .ascii "ABI FAIL hp\n"
.Labi_f_hs:  .ascii "ABI FAIL hs\n"
.Labi_f_hka: .ascii "ABI FAIL hka\n"
.Labi_f_hda: .ascii "ABI FAIL hda\n"
.Labi_f_hf:  .ascii "ABI FAIL hf\n"
.Labi_f_hcl: .ascii "ABI FAIL hcl\n"
.Labi_f_hm:  .ascii "ABI FAIL hm\n"
.Labi_f_hc:  .ascii "ABI FAIL hc\n"
.Labi_f_hsdA: .ascii "ABI FAIL hsdA\n"
.Labi_f_hsdB: .ascii "ABI FAIL hsdB\n"
.Labi_f_hsdC: .ascii "ABI FAIL hsdC\n"
.Labi_f_hsdD: .ascii "ABI FAIL hsdD\n"
.Labi_f_hcp: .ascii "ABI FAIL hcp\n"
.Labi_f_de: .ascii "ABI FAIL deq\n"
.Labi_f_sc: .ascii "ABI FAIL cat\n"
.Labi_f_sg: .ascii "ABI FAIL grw\n"
.Lsg_a:    .ascii "ab"
.Lsg_b:    .ascii "cdefgh"
.Lsg_c:    .ascii "x"
.Lsg_d:    .ascii "yz"
.Lsg_full: .ascii "abcdefghxyz"
.Labi_f_t4: .ascii "ABI FAIL t4\n"
.Labi_f_xmm: .ascii "ABI FAIL xmm\n"
.Labi_f_round: .ascii "ABI FAIL rnd\n"
.Lt4_a:    .ascii "abc"
.Lt4_b:    .ascii "abc"
.Lt4_c:    .ascii "abd"
.Labi_f_dl: .ascii "ABI FAIL d2l\n"
.Labi_s3:    .ascii "abc"
.Labi_s6:    .ascii "abcdef"
.Labi_f_dc: .ascii "ABI FAIL dcp\n"
.Labi_f_hv: .ascii "ABI FAIL hv\n"
ASM_EOF
}

inject gen/abi_l.s gen/abi_l_t.s linux
inject gen/abi_w.s gen/abi_w_t.s windows
as -o gen/abi_l_t.o gen/abi_l_t.s
ld -o gen/abi_l_t gen/abi_l_t.o
"$M/x86_64-w64-mingw32-as" -o gen/abi_w_t.o gen/abi_w_t.s
"$M/x86_64-w64-mingw32-ld" -o gen/abi_w_t.exe gen/abi_w_t.o -e _start --subsystem console -L"$MLIB" -lkernel32
out_l=$(gen/abi_l_t) && rc_l=0 || rc_l=$?
out_w=$("$WINE" gen/abi_w_t.exe 2>/dev/null) && rc_w=0 || rc_w=$?
echo "linux: $out_l (exit $rc_l)"
echo "wine:  $out_w (exit $rc_w)"
if [ "$out_l" = "         1.5         59999999999         10000000000-999999999         -1000000000      50000005000000ABI OK" ] && [ "$out_w" = "         1.5         59999999999         10000000000-999999999         -1000000000      50000005000000ABI OK" ] && [ $rc_l -eq 0 ] && [ $rc_w -eq 0 ]; then
  echo "ABI HARNESS PASS"
else
  echo "ABI HARNESS FAIL"; exit 1
fi

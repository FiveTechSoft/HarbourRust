#!/bin/bash
# Targeted instrumented cache registry and logical balance tests.
set -e
cd "$(dirname "$0")/.."
printf 'function main()\nreturn\n' >gen/cache_empty.prg
for target in linux windows; do
  ./hbc gen/cache_empty.prg gen/cache_${target}.s --target=$target --instrument >/dev/null
  for mode in live double size; do
    sed '0,/call hbc_fn_main/s//call hbc_cache_test/' gen/cache_${target}.s >gen/cache_${target}_${mode}.s
    cat >>gen/cache_${target}_${mode}.s <<'ASM'
.text
hbc_cache_test:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    sub $32, %rsp
    lea cache_input(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    mov %rax, %r12
ASM
    if [ "$mode" = size ]; then
      printf '    movq $4, -16(%%r12)\n' >>gen/cache_${target}_${mode}.s
    fi
    cat >>gen/cache_${target}_${mode}.s <<'ASM'
    mov %r12, %rdi
    call hbc_freestr
ASM
    if [ "$mode" = double ]; then
      printf '    mov %%r12, %%rdi\n    call hbc_freestr\n' >>gen/cache_${target}_${mode}.s
    fi
    cat >>gen/cache_${target}_${mode}.s <<'ASM'
    lea cache_input(%rip), %rdi
    mov $3, %esi
    call hbc_strcpy
    cmp %r12, %rax
    jne hbc_reg_bad
    mov %rax, %rdi
    call hbc_freestr
    cmpq $0, hbc_reg_count(%rip)
    jne hbc_reg_bad
    mov hbc_mem_allocs(%rip), %rax
    cmp hbc_mem_frees(%rip), %rax
    jne hbc_reg_bad
    call hbc_str_cache_flush
    lea hbc_str_cache(%rip), %r12
    xor %r13d, %r13d
97: cmpq $0, (%r12,%r13,8)
    jne hbc_reg_bad
    inc %r13
    cmp $8, %r13
    jb 97b
    add $32, %rsp
    pop %r13
    pop %r12
    pop %rbp
    ret
.section .rodata
cache_input: .byte 97,98,99
ASM
    if [ "$target" = linux ]; then
      as -o gen/cache_${mode}.o gen/cache_${target}_${mode}.s
      ld -o gen/cache_${mode} gen/cache_${mode}.o
      out=$(gen/cache_${mode}) && rc=0 || rc=$?
    else
      "$M/x86_64-w64-mingw32-as" -o gen/cache_${mode}_w.o gen/cache_${target}_${mode}.s
      "$M/x86_64-w64-mingw32-ld" -o gen/cache_${mode}.exe gen/cache_${mode}_w.o -e _start --subsystem console -L"$MLIB" -lkernel32
      out=$("$WINE" gen/cache_${mode}.exe 2>/dev/null) && rc=0 || rc=$?
    fi
    if [ "$mode" = live ]; then
      [ $rc -eq 0 ] && [ -z "$out" ] || { echo "CACHE FAIL $target $mode rc=$rc $out"; exit 1; }
    else
      [ $rc -eq 1 ] && [[ "$out" == 'Internal error: allocation registry mismatch'* ]] || { echo "CACHE FAIL $target $mode rc=$rc $out"; exit 1; }
    fi
  done
done
echo 'CACHE REGISTRY PASS'

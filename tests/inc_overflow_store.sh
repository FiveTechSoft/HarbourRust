#!/bin/bash
# Verify all expression overflow exits branch BEFORE changing the lvalue.
# A test-only replacement exit checks the live slot through r10, old rax,
# and computed r11. This is NOT a returning runtime helper or an ABI claim.
set -eu
cd "$(dirname "$0")/.."
for n in 888 903 904 905; do
  f=tests/t${n}_inc_overflow.prg
  for target in linux windows; do
    stem=gen/inc_store_${n}_${target}
    ./hbc "$f" "$stem.s" --target="$target" >/dev/null
    sed -i 's/^hbc_inc_overflow:/hbc_original_inc_overflow:/' "$stem.s"
    cat >>"$stem.s" <<'ASM'
.text
hbc_inc_overflow:
    cmp %rax, (%r10)
    jne inc_store_bad
    movabs $0x7fffffffffffffff, %rdx
    cmp %rdx, %rax
    je inc_store_up
    movabs $0x8000000000000000, %rdx
    cmp %rdx, %rax
    jne inc_store_bad
    movabs $0x7fffffffffffffff, %rdx
    cmp %rdx, %r11
    jne inc_store_bad
    jmp inc_store_ok
inc_store_up:
    movabs $0x8000000000000000, %rdx
    cmp %rdx, %r11
    jne inc_store_bad
inc_store_ok:
    lea .Linc_store_ok(%rip), %rax
    mov $15, %edx
    call hbc_print_str
ASM
    if [ "$target" = linux ]; then
      cat >>"$stem.s" <<'ASM'
    mov $60, %eax
    xor %edi, %edi
    syscall
inc_store_bad:
    mov $60, %eax
    mov $1, %edi
    syscall
ASM
    else
      cat >>"$stem.s" <<'ASM'
    xor %ecx, %ecx
    sub $32, %rsp
    call ExitProcess
inc_store_bad:
    mov $1, %ecx
    sub $32, %rsp
    call ExitProcess
ASM
    fi
    cat >>"$stem.s" <<'ASM'
.section .rodata
.Linc_store_ok:
    .ascii "INC OVERFLOW OK"
ASM
    if [ "$target" = linux ]; then
      as -o "$stem.o" "$stem.s"
      ld -o "$stem" "$stem.o"
      out=$(timeout 10 "$stem")
    else
      "$M"/x86_64-w64-mingw32-as -o "$stem.o" "$stem.s"
      "$M"/x86_64-w64-mingw32-ld -o "$stem.exe" "$stem.o" -e _start --subsystem console -L"$MLIB" -lkernel32
      out=$(timeout 15 "$WINE" "$stem.exe" 2>/dev/null)
    fi
    [ "$out" = 'INC OVERFLOW OK' ] || { echo "FAIL $n $target: $out"; exit 1; }
    echo "PASS pre-store overflow $n $target"
  done
done

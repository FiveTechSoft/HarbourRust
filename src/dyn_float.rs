// Dyn kind5 representation contract. Bit63 marks an owned heap item;
// legacy inline double bits remain readable when the marker is absent.
pub const KIND: u64 = 5;
pub const HEAP_MARKER: u64 = 1u64 << 63;
pub const HEAP_TAG: u64 = HEAP_MARKER | KIND;
pub const BRIDGE_HEAP_CAP: u64 = 1u64 << 32;
pub const MAX_ARGC: u64 = i32::MAX as u64;
pub fn is_heap(tag: u64) -> bool { tag & 255 == KIND && tag & HEAP_MARKER != 0 }
pub fn bridge_count(raw: u64) -> Option<u32> {
    let count = raw & !BRIDGE_HEAP_CAP;
    if count <= MAX_ARGC { Some(count as u32) } else { None }
}
// hbc-internal ABI, both targets. Reuse the owned-string allocator to obtain
// an accounted 16-byte payload with its established headers/free/cache.
// Emitted with the coherent migration; consumers must preserve this contract.
pub const HELPERS: &str = r#"
.text
# bits rdi, F64 metadata rsi -> owned tag rax / item pointer rdx.
hbc_float_new:
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp
    mov %rdi, (%rsp)
    mov %rsi, 8(%rsp)
    mov $16, %esi
    call hbc_stralloc
    mov (%rsp), %r10
    mov %r10, (%rax)
    mov 8(%rsp), %r10
    mov %r10, 8(%rax)
    mov %rax, %rdx
    mov $0x8000000000000005, %rax
    leave
    ret

# Pair rax/rdx -> xmm0=value, rdi=full F64 metadata. Legacy width/default
# reproduce the established Dyn printer contract; heap metadata is exact.
hbc_float_unpack:
    test %rax, %rax
    jns .Lfloat_unpack_legacy
    movsd (%rdx), %xmm0
    mov 8(%rdx), %rdi
    ret
.Lfloat_unpack_legacy:
    movq %rdx, %xmm0
    shr $8, %rax
    test %rax, %rax
    jnz .Lfloat_unpack_dec
    mov $2, %eax
.Lfloat_unpack_dec:
    mov $10, %edi
    movsd .Ldynw_hi(%rip), %xmm1
    ucomisd %xmm1, %xmm0
    ja .Lfloat_unpack_wide
    movsd .Ldynw_lo(%rip), %xmm1
    ucomisd %xmm1, %xmm0
    jae .Lfloat_unpack_meta
.Lfloat_unpack_wide:
    mov $20, %edi
.Lfloat_unpack_meta:
    shl $16, %rdi
    or %rax, %rdi
    ret

# Pair rax/rdx -> independent owned heap pair if marked; legacy unchanged.
hbc_float_clone:
    cmp $5, %al
    jne .Lfloat_clone_done
    test %rax, %rax
    jns .Lfloat_clone_done
    mov (%rdx), %rdi
    mov 8(%rdx), %rsi
    jmp hbc_float_new
.Lfloat_clone_done:
    ret

# Release marked-float payloads in a flat cell range. RDI=data,RDX=count;
# preserves RDI/RSI/RDX for the final block free. Never used on block moves.
hbc_float_cells_release:
    push %rbp
    mov %rsp,%rbp
    push %rbx
    push %r12
    sub $32,%rsp
    mov %rdi,%rbx
    mov %rdx,%r12
    mov %rdi,(%rsp)
    mov %rsi,8(%rsp)
    mov %rdx,16(%rsp)
.Lfloat_cells_loop:
    test %r12,%r12
    jle .Lfloat_cells_done
    mov (%rbx),%rax
    mov 8(%rbx),%rdx
    call hbc_float_release
    add $16,%rbx
    dec %r12
    jmp .Lfloat_cells_loop
.Lfloat_cells_done:
    mov (%rsp),%rdi
    mov 8(%rsp),%rsi
    mov 16(%rsp),%rdx
    add $32,%rsp
    pop %r12
    pop %rbx
    leave
    ret

# Pair rax/rdx -> release marked heap only; legacy inline owns no item.
hbc_float_release:
    cmp $5, %al
    jne .Lfloat_release_done
    test %rax, %rax
    jns .Lfloat_release_done
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp
    mov %rax, (%rsp)
    mov %rdx, 8(%rsp)
    mov %rdx, %rdi
    call hbc_freestr
    mov (%rsp), %rax
    mov 8(%rsp), %rdx
    leave
.Lfloat_release_done:
    ret
"#;
#[cfg(test)] mod tests {
    use super::*;
    #[test] fn c_contract_matches_reserved_bits() {
        let h=include_str!("../runtime/hrdyn.h");
        assert!(h.contains(&format!("#define HR_DYN_FLOAT_HEAP 0x{:016x}ULL",HEAP_MARKER)));
        assert!(h.contains(&format!("#define HR_DYN_BRIDGE_HEAP_CAP 0x{:016x}ULL",BRIDGE_HEAP_CAP)));
        assert!(h.contains(&format!("#define HR_DYN_ARGC_MAX 0x{:016x}ULL",MAX_ARGC)));
    }
    #[test] fn marker_does_not_confuse_other_kinds() {
        assert!(is_heap(HEAP_TAG));
        for k in 0..=255 { assert_eq!(is_heap(HEAP_MARKER|k),k==KIND); }
        assert!(!is_heap(KIND));
        assert!(!is_heap(KIND | (17<<8) | (255<<16)));
    }
    #[test] fn count_capacity_is_not_a_count() {
        for n in [0,1,4,11,MAX_ARGC] {
            assert_eq!(bridge_count(n),Some(n as u32));
            assert_eq!(bridge_count(n|BRIDGE_HEAP_CAP),Some(n as u32));
        }
        for n in [MAX_ARGC+1,1<<33,1<<63,u64::MAX] {assert_eq!(bridge_count(n),None);}
    }
}

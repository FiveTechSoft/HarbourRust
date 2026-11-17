// Intel Mach-O preparation. This is not an ARM code generator.
// Format facts: Apple xnu EXTERNAL_HEADERS/mach-o/loader.h and
// osfmk/mach/i386/thread_status.h. No Apple implementation code is used.

fn u32at(b: &[u8], p: usize) -> Result<u32, String> {
    b.get(p..p + 4).map(|x| u32::from_le_bytes(x.try_into().unwrap()))
        .ok_or_else(|| "truncated ELF32 field".into())
}
fn u64at(b: &[u8], p: usize) -> Result<u64, String> {
    b.get(p..p + 8).map(|x| u64::from_le_bytes(x.try_into().unwrap()))
        .ok_or_else(|| "truncated ELF64 field".into())
}
fn w32(b: &mut Vec<u8>, n: u32) { b.extend_from_slice(&n.to_le_bytes()); }
fn w64(b: &mut Vec<u8>, n: u64) { b.extend_from_slice(&n.to_le_bytes()); }
fn align(n: u64) -> Result<u64, String> {
    n.checked_add(4095).map(|v| v & !4095).ok_or_else(|| "segment size overflow".into())
}
fn segment(b: &mut Vec<u8>, name: &str, va: u64, size: u64, off: u64, filesz: u64, prot: u32) {
    w32(b, 0x19); w32(b, 72);
    let mut n = [0u8; 16]; n[..name.len()].copy_from_slice(name.as_bytes());
    b.extend_from_slice(&n);
    for x in [va, size, off, filesz] { w64(b, x); }
    w32(b, prot); w32(b, prot); w32(b, 0); w32(b, 0);
}

// Use the existing assembler's fully resolved x86-64 image as input. Keep its
// virtual addresses and relocations, but replace the file container entirely.
// This avoids a second instruction encoder or changing ELF/PE layout rules.
pub fn from_elf(elf: &[u8]) -> Result<Vec<u8>, String> {
    if elf.get(..6) != Some(b"\x7fELF\x02\x01") || u32at(elf, 16)? != 0x003e0002 {
        return Err("Mach-O requires the internal x86-64 little-endian ET_EXEC image".into());
    }
    let entry = u64at(elf, 24)?;
    let phoff = usize::try_from(u64at(elf, 32)?).map_err(|_| "program header overflow")?;
    let phsize = u16::from_le_bytes(elf.get(54..56).ok_or("missing phentsize")?.try_into().unwrap()) as usize;
    let count = u16::from_le_bytes(elf.get(56..58).ok_or("missing phnum")?.try_into().unwrap()) as usize;
    if phsize != 56 || count > 64 { return Err("unexpected program header layout".into()); }
    let mut loads = Vec::new();
    for i in 0..count {
        let p = phoff.checked_add(i * phsize).ok_or("header overflow")?;
        if u32at(elf, p)? != 1 { continue; }
        let flags = u32at(elf, p + 4)?;
        let off = u64at(elf, p + 8)?;
        let va = u64at(elf, p + 16)?;
        let fs = u64at(elf, p + 32)?;
        let ms = u64at(elf, p + 40)?;
        if fs > ms || off.checked_add(fs).ok_or("file range overflow")? > elf.len() as u64 {
            return Err("invalid load range".into());
        }
        loads.push((flags, off, va, fs, ms));
    }
    let code = loads.iter().find(|x| x.0 == 5).ok_or("missing executable segment")?;
    let base = code.2.checked_sub(code.1).ok_or("invalid text base")?;
    if base != 0x400000 || code.1 != 4096 { return Err("unexpected internal assembler text layout".into()); }
    if entry < code.2 || entry >= code.2 + code.3 { return Err("entry outside executable bytes".into()); }
    let mut cmds = Vec::new();
    segment(&mut cmds, "__PAGEZERO", 0, base, 0, 0, 0);
    let text_end = align(code.1 + code.3)?;
    segment(&mut cmds, "__TEXT", base, text_end, 0, text_end, 5);
    let mut ranges = vec![(base, base + text_end)];
    let mut file_end = text_end;
    let mut copies = vec![(code.1, code.1, code.3)];
    for &(flags, off, va, fs, ms) in &loads {
        if flags == 5 || off == 0 { continue; }
        if flags != 4 && flags != 6 { return Err("unexpected segment permissions".into()); }
        let prefix = va % 4096;
        let start = va - prefix;
        let size = align(prefix.checked_add(ms).ok_or("memory overflow")?)?;
        let disk = if fs == 0 { 0 } else { align(prefix + fs)? };
        let fileoff = file_end;
        if ranges.iter().any(|&(a, b)| start < b && a < start + size) {
            return Err("overlapping Mach-O virtual segments".into());
        }
        ranges.push((start, start + size));
        file_end = fileoff.checked_add(disk).ok_or("file overflow")?;
        if fs > 0 { copies.push((off,fileoff + prefix,fs)); }
        segment(&mut cmds, if flags == 4 { "__CONST" } else { "__DATA" },
                start, size, fileoff, disk, if flags == 4 { 1 } else { 3 });
    }
    // LC_UNIXTHREAD: x86_THREAD_STATE64 (flavor 4), 42 32-bit words.
    w32(&mut cmds, 5); w32(&mut cmds, 184); w32(&mut cmds, 4); w32(&mut cmds, 42);
    for i in 0..21 { w64(&mut cmds, if i == 16 { entry } else { 0 }); }
    let ncmds = (ranges.len() + 2) as u32; // pagezero + mapped segments + thread
    if cmds.len() + 32 > 4096 || file_end > 512 * 1024 * 1024 { return Err("Mach-O image bound exceeded".into()); }
    let mut out = Vec::new();
    for n in [0xfeedfacf, 0x01000007, 3, 2, ncmds, cmds.len() as u32, 1, 0] { w32(&mut out, n); }
    out.extend_from_slice(&cmds);
    out.resize(file_end as usize, 0);
    // Preserve only mapped original bytes, not ELF section/symbol metadata.
    for (off, dest, size) in copies {
        let a=off as usize; let d=dest as usize; let n=size as usize;
        out[d..d+n].copy_from_slice(&elf[a..a+n]);
    }
    Ok(out)
}

// Lower only the OS operations used by the portable scalar/container
// runtime, CurDir (open/fcntl/close) and Date (gettimeofday). An added
// syscall is a compile-time error, never passed to Darwin with a Linux
// number. Preserve rdx (Darwin has a second return register) and r10
// (mmap flags); retain Linux's negative-error convention for consumers.
pub fn darwin_asm(src: &str) -> Result<String, String> {
    let lines: Vec<&str> = src.lines().collect();
    let mut out = String::new();
    let mut serial = 0;
    for (i, line) in lines.iter().enumerate() {
        if line.trim() != "syscall" { out.push_str(line); out.push('\n'); continue; }
        let mut number = None;
        for prev in lines[..i].iter().rev().take(12) {
            let text = prev.split('#').next().unwrap().trim();
            if let Some((lhs, rhs)) = text.rsplit_once(',') {
                if ["%eax", "%rax"].contains(&rhs.trim()) {
                    if let Some(n) = lhs.trim().strip_prefix("mov $") {
                        number = n.parse::<u32>().ok();
                    }
                    break;
                }
            }
        }
        let n = number.ok_or_else(|| format!("Mach-O: unclassified syscall at assembly line {}", i + 1))?;
        let mac = match n { 1 => 4, 2 => 5, 3 => 6, 9 => 197, 11 => 73, 60 => 1, 72 => 92, 96 => 116,
            _ => return Err(format!("Mach-O Intel: OS operation {} is not ported in this increment", n)), };
        serial += 1;
        out.push_str("    push %rdx\n");
        if n == 9 { out.push_str("    push %r10\n    mov $0x1002, %r10d\n"); }
        out.push_str(&format!("    mov ${}, %eax\n    syscall\n    jnc .Ldarwin_ok{}\n    neg %rax\n.Ldarwin_ok{}:\n", 0x2000000u32 + mac, serial, serial));
        if n == 9 { out.push_str("    pop %r10\n"); }
        out.push_str("    pop %rdx\n");
    }
    // Preserve the kernel stack pointer for arena getenv before alignment.
    // Anchor on newline so `.Ldate_today_month_start:` (contains `_start:`)
    // is not mistaken for the entry point.
    let out = if out.contains("_start:\n    mov %rsp, %rdi\n    call hbc_arena_env_init") {
        out.replace("_start:\n    mov %rsp, %rdi\n    call hbc_arena_env_init", "_start:\n    mov %rsp, %rdi\n    and $-16, %rsp\n    call hbc_arena_env_init")
    } else {out.replace("\n_start:\n", "\n_start:\n    and $-16, %rsp\n")};
    Ok(out.replace("# target: linux - no libc, I/O via own syscall helpers at the end", "# target: macho - experimental Intel Darwin syscall runtime"))
}

// ---------------------------------------------------------------------------
// Intel Mach-O through dyld (LC_MAIN, libSystem). The x86-64 code is the
// Linux runtime as text, run natively: constant Linux system calls become
// raw Darwin calls (carry -> negative errno, rdx preserved), the others go
// through the run-time Linux -> Darwin dispatcher shared with the ARM64
// backend (getdents64, newfstatat, openat, clock_gettime, mmap, futex).
// Threads: clone -> pthread_create, exit -> pthread_exit, and the %fs
// thread block lives in sixteen pthread TSD slots reserved at start-up
// (keys 512..527), so `%fs:N` becomes `%gs:(4096+N)` with no register.
// EXTERNAL: the C extension is a dylib; its functions are called through
// GOT slots bound by dyld and the bridge channel lives in the executable.

/// Imports (symbol, dylib ordinal: 1 libSystem, 2 extension) and exported
/// labels of a lowered Intel program.
pub struct Dyld { pub imports: Vec<(String, u8)>, pub exports: Vec<String> }

const DYLD_MAGIC: u64 = 0x3144_4c59_4443_4248; // "HBCDYLD1"
const DW_TLS_BASE: u64 = 4096; // pthread key 512 * 8

fn dw_syscall_number(prev: &[&str]) -> Option<u64> {
    for line in prev.iter().rev().take(16) {
        let t = line.split('#').next().unwrap().trim();
        if t.is_empty() || t.starts_with('.') && !t.ends_with(':') { continue; }
        if t.ends_with(':') { return None; }
        let m = t.split_whitespace().next().unwrap_or("");
        if m.starts_with('j') || m == "call" || m == "ret" || m == "syscall" { return None; }
        if t == "xor %eax, %eax" || t == "xor %rax, %rax" { return Some(0); }
        if let Some((lhs, rhs)) = t.rsplit_once(',') {
            if ["%eax", "%rax"].contains(&rhs.trim()) {
                let v = lhs.trim().strip_prefix("mov $").or_else(|| lhs.trim().strip_prefix("movl $")).or_else(|| lhs.trim().strip_prefix("movq $"))?;
                return if let Some(h) = v.strip_prefix("0x") { u64::from_str_radix(h, 16).ok() } else { v.parse::<u64>().ok() };
            }
        }
    }
    None
}

fn dw_raw(out: &mut String, serial: &mut u32, darwin: u64) {
    *serial += 1;
    out.push_str(&format!("    push %rdx\n    mov ${}, %eax\n    syscall\n    jnc .Ldw_ok{}\n    neg %rax\n.Ldw_ok{}:\n    pop %rdx\n", darwin, serial, serial));
}

fn dw_call(out: &mut String, f: &str) {
    // keep the x86 red zone of the interrupted code
    out.push_str(&format!("    lea -128(%rsp), %rsp\n    call {}\n    lea 128(%rsp), %rsp\n", f));
}

fn dw_fs(line: &str) -> String {
    let mut r = String::new();
    let mut rest = line;
    while let Some(p) = rest.find("%fs:") {
        r.push_str(&rest[..p]);
        let tail = &rest[p + 4..];
        let n = tail.bytes().take_while(|b| b.is_ascii_digit()).count();
        let off: u64 = tail[..n].parse().unwrap_or(0);
        r.push_str(&format!("%gs:{}", DW_TLS_BASE + off));
        rest = &tail[n..];
    }
    r.push_str(rest);
    r
}

const DW_HELPERS: &str = r#"
    .text
# Linux open(2) flags -> Darwin, raw open
hbc_dw_open:
    push %rsi
    push %rdx
    mov %rsi, %rcx
    and $3, %rcx
    test $64, %rsi
    jz .Ldwo1
    or $512, %rcx
.Ldwo1:
    test $128, %rsi
    jz .Ldwo2
    or $2048, %rcx
.Ldwo2:
    test $512, %rsi
    jz .Ldwo3
    or $1024, %rcx
.Ldwo3:
    test $1024, %rsi
    jz .Ldwo4
    or $8, %rcx
.Ldwo4:
    test $65536, %rsi
    jz .Ldwo5
    or $1048576, %rcx
.Ldwo5:
    test $131072, %rsi
    jz .Ldwo6
    or $256, %rcx
.Ldwo6:
    test $524288, %rsi
    jz .Ldwo7
    or $16777216, %rcx
.Ldwo7:
    mov %rcx, %rsi
    mov $33554437, %eax
    syscall
    jnc .Ldwo9
    neg %rax
.Ldwo9:
    pop %rdx
    pop %rsi
    ret

# gettimeofday: Darwin returns seconds in rax and microseconds in edx
hbc_dw_gettimeofday:
    push %rdx
    xor %edx, %edx
    mov $33554548, %eax
    syscall
    jnc .Ldwt1
    neg %rax
    jmp .Ldwt9
.Ldwt1:
    test %rax, %rax
    jz .Ldwt9
    test %rdi, %rdi
    jz .Ldwt8
    mov %rax, (%rdi)
    mov %edx, %edx
    mov %rdx, 8(%rdi)
.Ldwt8:
    xor %eax, %eax
.Ldwt9:
    pop %rdx
    ret

# LC_MAIN entry (rdi argc, rsi argv, rdx envp): build the Linux initial
# stack (argc, argv..., 0, envp..., 0, AT_NULL) and enter _start.
__hbc_dw_main:
    mov %rdi, %r12
    mov %rsi, %r13
    mov %rdx, %r14
    and $-16, %rsp
@DW_TSD_CALL@
    xor %ecx, %ecx
.Ldwm1:
    cmpq $0, (%r14,%rcx,8)
    je .Ldwm2
    inc %rcx
    jmp .Ldwm1
.Ldwm2:
    lea 5(%r12,%rcx), %rax
    shl $3, %rax
    sub %rax, %rsp
    and $-16, %rsp
    mov %r12, (%rsp)
    lea 8(%rsp), %rdi
    xor %eax, %eax
.Ldwm3:
    mov (%r13,%rax,8), %rdx
    mov %rdx, (%rdi)
    add $8, %rdi
    inc %rax
    cmp %r12, %rax
    jbe .Ldwm3
    xor %eax, %eax
.Ldwm4:
    mov (%r14,%rax,8), %rdx
    mov %rdx, (%rdi)
    add $8, %rdi
    inc %rax
    test %rdx, %rdx
    jnz .Ldwm4
    movq $0, (%rdi)
    movq $0, 8(%rdi)
    xor %eax, %eax
    xor %edx, %edx
    jmp _start
"#;

const DW_THREAD_HELPERS: &str = r#"
    .text
# Reserve pthread keys 512..527 (dynamic keys are handed out lowest
# first); the %fs thread block is %gs:4096.. in this thread's TSD.
hbc_dw_tsd_init:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    sub $16, %rsp
    xor %r12d, %r12d
.Ldwk1:
    mov %rsp, %rdi
    xor %esi, %esi
    call *__hbc_imp_pthread_key_create(%rip)
    test %eax, %eax
    jnz .Ldwk_fail
    mov (%rsp), %rbx
    cmp $512, %rbx
    jb .Ldwk1
    lea -512(%rbx), %rax
    cmp %r12, %rax
    jne .Ldwk_fail
    inc %r12
    cmp $16, %r12
    jne .Ldwk1
    add $16, %rsp
    pop %r12
    pop %rbx
    pop %rbp
    ret
.Ldwk_fail:
    mov $2, %edi
    lea .Ldwk_msg(%rip), %rsi
    mov $45, %edx
    mov $33554436, %eax
    syscall
    mov $111, %edi
    mov $33554433, %eax
    syscall

# arch_prctl(ARCH_SET_FS, rsi = block): the block's first 128 bytes
# become this thread's TSD slots 512..527.
hbc_dw_setfs:
@DW_COPY@
    xor %eax, %eax
    ret

# clone(2) of the thread runtime: the child is hbc_thread_boot(rbx).
hbc_dw_clone:
    push %rbp
    mov %rsp, %rbp
    push %rdi
    push %rsi
    push %rdx
    push %r8
    push %r9
    push %r10
    and $-16, %rsp
    sub $96, %rsp
    lea 16(%rsp), %rdi
    call *__hbc_imp_pthread_attr_init(%rip)
    lea 16(%rsp), %rdi
    mov $2097152, %esi
    call *__hbc_imp_pthread_attr_setstacksize(%rip)
    mov %rsp, %rdi
    lea 16(%rsp), %rsi
    lea hbc_dw_thread_entry(%rip), %rdx
    mov %rbx, %rcx
    call *__hbc_imp_pthread_create(%rip)
    test %eax, %eax
    jnz .Ldwc_fail
    mov (%rsp), %rdi
    call *__hbc_imp_pthread_detach(%rip)
    mov $1, %eax
    jmp .Ldwc_out
.Ldwc_fail:
    mov $-11, %rax
.Ldwc_out:
    lea -48(%rbp), %rsp
    pop %r10
    pop %r9
    pop %r8
    pop %rdx
    pop %rsi
    pop %rdi
    pop %rbp
    ret

hbc_dw_thread_entry:
    mov %rdi, %rbx
    jmp hbc_thread_boot

# Linux exit(2): only the calling thread; the process when it is main.
hbc_dw_exit:
    mov %rdi, %rbx
    and $-16, %rsp
    call *__hbc_imp_pthread_main_np(%rip)
    test %eax, %eax
    jz .Ldwe1
    mov %rbx, %rdi
    mov $33554433, %eax
    syscall
.Ldwe1:
    xor %edi, %edi
    call *__hbc_imp_pthread_exit(%rip)
    ud2
    .section .rodata
.Ldwk_msg:
    .ascii "macOS: pthread keys 512..527 are unavailable"
    .byte 10, 0
    .text
"#;

const DW_EXT_CHANNEL: &str = r#"
    .data
    .p2align 3
hbc_ext_argc: .quad 0
hbc_ext_argv: .quad 0
hbc_ext_ret_tag: .quad 1
hbc_ext_ret_pay: .quad 0
    .text
"#;

/// Lower the Linux x86-64 program text for Intel macOS through dyld.
// Linux nanosleep (35): Darwin has no BSD nanosleep system call, so it
// goes to libSystem's nanosleep, preserving every register the syscall
// instruction preserves (all but rax, rcx, r11; xmm included). libc's
// -1/errno becomes -errno (EINTR/EFAULT/EINVAL match Linux numbers).
const DW_NANOSLEEP: &str = r#"
    .text
hbc_dw_nanosleep:
    push %rbp
    mov %rsp, %rbp
    and $-16, %rsp
    sub $320, %rsp
    mov %rdi, (%rsp)
    mov %rsi, 8(%rsp)
    mov %rdx, 16(%rsp)
    mov %r8, 24(%rsp)
    mov %r9, 32(%rsp)
    mov %r10, 40(%rsp)
    movdqu %xmm0, 64(%rsp)
    movdqu %xmm1, 80(%rsp)
    movdqu %xmm2, 96(%rsp)
    movdqu %xmm3, 112(%rsp)
    movdqu %xmm4, 128(%rsp)
    movdqu %xmm5, 144(%rsp)
    movdqu %xmm6, 160(%rsp)
    movdqu %xmm7, 176(%rsp)
    movdqu %xmm8, 192(%rsp)
    movdqu %xmm9, 208(%rsp)
    movdqu %xmm10, 224(%rsp)
    movdqu %xmm11, 240(%rsp)
    movdqu %xmm12, 256(%rsp)
    movdqu %xmm13, 272(%rsp)
    movdqu %xmm14, 288(%rsp)
    movdqu %xmm15, 304(%rsp)
    call *__hbc_imp_nanosleep(%rip)
    test %eax, %eax
    jz .Ldwns1
    call *__hbc_imp___error(%rip)
    movslq (%rax), %rax
    neg %rax
    jmp .Ldwns2
.Ldwns1:
    xor %eax, %eax
.Ldwns2:
    movdqu 64(%rsp), %xmm0
    movdqu 80(%rsp), %xmm1
    movdqu 96(%rsp), %xmm2
    movdqu 112(%rsp), %xmm3
    movdqu 128(%rsp), %xmm4
    movdqu 144(%rsp), %xmm5
    movdqu 160(%rsp), %xmm6
    movdqu 176(%rsp), %xmm7
    movdqu 192(%rsp), %xmm8
    movdqu 208(%rsp), %xmm9
    movdqu 224(%rsp), %xmm10
    movdqu 240(%rsp), %xmm11
    movdqu 256(%rsp), %xmm12
    movdqu 272(%rsp), %xmm13
    movdqu 288(%rsp), %xmm14
    movdqu 304(%rsp), %xmm15
    mov (%rsp), %rdi
    mov 8(%rsp), %rsi
    mov 16(%rsp), %rdx
    mov 24(%rsp), %r8
    mov 32(%rsp), %r9
    mov 40(%rsp), %r10
    mov %rbp, %rsp
    pop %rbp
    ret
"#;

pub fn darwin_dyld_asm(src: &str, threaded: bool, ext: bool) -> Result<(String, Dyld), String> {
    let mut text = format!("{}\n{}", src, crate::hasm::arm64::LINUX_SYSCALL_DISPATCH);
    if ext {
        // hbc_blk_launch (C -> hbc codeblock) and the bridge channel live in
        // the executable; the extension dylib resolves them by name.
        text.push_str(crate::hasm::arm64::EXT_BRIDGE_TEXT);
        text.push_str(DW_EXT_CHANNEL);
    }
    let mut defined = std::collections::HashSet::new();
    for l in text.lines() {
        let t = l.trim();
        if let Some((n, _)) = t.split_once(':') {
            if !n.is_empty() && n.chars().all(|c| c.is_ascii_alphanumeric() || c == '_' || c == '.' || c == '$') { defined.insert(n.to_string()); }
        }
        if let Some(r) = t.strip_prefix(".set ").or_else(|| t.strip_prefix(".equ ")) {
            if let Some((n, _)) = r.split_once(',') { defined.insert(n.trim().to_string()); }
        }
        if let Some((n, _)) = t.split_once(" = ") { if !n.contains(char::is_whitespace) { defined.insert(n.to_string()); } }
    }
    let mut imports: Vec<(String, u8)> = Vec::new();
    let mut imp = |s: &str, ord: u8, imports: &mut Vec<(String, u8)>| {
        if !imports.iter().any(|(n, _)| n == s) { imports.push((s.to_string(), ord)); }
    };
    let lines: Vec<&str> = text.lines().collect();
    let mut out = String::with_capacity(text.len() + 4096);
    let mut serial = 0u32;
    let mut nanosleep = false;
    for (i, line) in lines.iter().enumerate() {
        let t = line.split('#').next().unwrap().trim();
        if ext {
            let ext_target = ["call ", "jmp "].iter().find_map(|m| t.strip_prefix(m).map(|r| (*m, r.trim())))
                .filter(|(_, r)| r.chars().next().map_or(false, |c| c.is_ascii_alphabetic() || c == '_')
                    && r.chars().all(|c| c.is_ascii_alphanumeric() || c == '_') && !defined.contains(*r));
            if let Some((m, target)) = ext_target {
                imp(target, 2, &mut imports);
                out.push_str(&format!("    {}*__hbc_imp_{}(%rip)\n", m, target));
                continue;
            }
        }
        if t != "syscall" {
            if threaded && line.contains("%fs:") { out.push_str(&dw_fs(line)); } else { out.push_str(line); }
            out.push('\n');
            continue;
        }
        let n = dw_syscall_number(&lines[..i]);
        match n {
            Some(v) if (0x200_0000..0x200_1000).contains(&v) => dw_raw(&mut out, &mut serial, v),
            Some(56) if threaded => dw_call(&mut out, "hbc_dw_clone"),
            Some(158) if threaded => dw_call(&mut out, "hbc_dw_setfs"),
            Some(60) if threaded => dw_call(&mut out, "hbc_dw_exit"),
            Some(2) => dw_call(&mut out, "hbc_dw_open"),
            Some(96) => dw_call(&mut out, "hbc_dw_gettimeofday"),
            Some(35) => { nanosleep = true; dw_call(&mut out, "hbc_dw_nanosleep") }
            Some(9) => {
                out.push_str("    push %r10\n    mov $0x1002, %r10d\n");
                dw_raw(&mut out, &mut serial, 0x200_0000 + 197);
                out.push_str("    pop %r10\n");
            }
            Some(l) if [0, 1, 3, 8, 11, 18, 60, 72, 186, 231].contains(&l) => {
                let mac = match l { 0 => 3, 1 => 4, 3 => 6, 8 => 199, 11 => 73, 18 => 154, 60 => 1, 72 => 92, 186 => 372, _ => 1 };
                dw_raw(&mut out, &mut serial, 0x200_0000 + mac);
            }
            _ => dw_call(&mut out, "__a64_linux_syscall"),
        }
    }
    let mut out = if out.contains("_start:\n    mov %rsp, %rdi\n    call hbc_arena_env_init") {
        out.replace("_start:\n    mov %rsp, %rdi\n    call hbc_arena_env_init", "_start:\n    mov %rsp, %rdi\n    and $-16, %rsp\n    call hbc_arena_env_init")
    } else { out.replace("\n_start:\n", "\n_start:\n    and $-16, %rsp\n") };
    out.push_str(&DW_HELPERS.replace("@DW_TSD_CALL@", if threaded { "    call hbc_dw_tsd_init" } else { "" }));
    if threaded {
        let mut copy = String::new();
        for k in 0..16 { copy.push_str(&format!("    mov {}(%rsi), %rax\n    mov %rax, %gs:{}\n", 8 * k, DW_TLS_BASE + 8 * k)); }
        let th = DW_THREAD_HELPERS.replace("@DW_COPY@", &copy);
        // a program that only uses mutexes/TLS has no thread start (pruned)
        let th = if defined.contains("hbc_thread_boot") { th } else { th.replace("    jmp hbc_thread_boot\n", "    ud2\n") };
        out.push_str(&th);
        for s in ["pthread_key_create", "pthread_attr_init", "pthread_attr_setstacksize", "pthread_create", "pthread_detach", "pthread_main_np", "pthread_exit"] {
            imp(s, 1, &mut imports);
        }
    }
    if nanosleep {
        out.push_str(DW_NANOSLEEP);
        for s in ["nanosleep", "__error"] { imp(s, 1, &mut imports); }
    }
    let mut exports = Vec::new();
    if ext {
        for s in ["hbc_strcpy", "hbc_freestr", "hbc_blk_launch", "hrdbf_app_close", "hbc_ext_argc", "hbc_ext_argv", "hbc_ext_ret_tag", "hbc_ext_ret_pay"] {
            if defined.contains(s) { exports.push(s.to_string()); }
        }
    }
    out.push_str(&format!("    .data\n    .p2align 3\n__hbc_dyld_tab:\n    .quad {}\n    .quad {}\n    .quad {}\n    .quad __hbc_dw_main\n", DYLD_MAGIC, imports.len(), exports.len()));
    for (s, _) in &imports { out.push_str(&format!("__hbc_imp_{}: .quad 0\n", s)); }
    for s in &exports { out.push_str(&format!("    .quad {}\n", s)); }
    out.push_str("    .text\n");
    let out = out.replace("# target: linux - no libc, I/O via own syscall helpers at the end", "# target: macho - Intel Darwin through dyld");
    Ok((out, Dyld { imports, exports }))
}

/// Mach-O x86-64 executable for dyld from the internal assembler's image:
/// fixed addresses (no PIE), LC_MAIN at __hbc_dw_main, libSystem plus the
/// optional extension dylib, GOT slots bound by name, exports by trie.
pub fn from_elf_dyld(elf: &[u8], plan: &Dyld, ext: Option<&str>) -> Result<Vec<u8>, String> {
    use crate::hasm::arm64::{export_trie, string_command, uleb, words, sha256};
    if elf.get(..6) != Some(b"\x7fELF\x02\x01") || u32at(elf, 16)? != 0x003e0002 {
        return Err("Mach-O requires the internal x86-64 little-endian ET_EXEC image".into());
    }
    let phoff = usize::try_from(u64at(elf, 32)?).map_err(|_| "program header overflow")?;
    let count = u16::from_le_bytes(elf.get(56..58).ok_or("missing phnum")?.try_into().unwrap()) as usize;
    let mut loads = Vec::new();
    for i in 0..count {
        let p = phoff + i * 56;
        if u32at(elf, p)? != 1 { continue; }
        let (flags, off, va, fs, ms) = (u32at(elf, p + 4)?, u64at(elf, p + 8)?, u64at(elf, p + 16)?, u64at(elf, p + 32)?, u64at(elf, p + 40)?);
        if fs > ms || off + fs > elf.len() as u64 { return Err("invalid load range".into()); }
        loads.push((flags, off, va, fs, ms));
    }
    let code = *loads.iter().find(|x| x.0 == 5).ok_or("missing executable segment")?;
    let base = 0x400000u64;
    if code.2 - code.1 != base || code.1 != 4096 { return Err("unexpected internal assembler text layout".into()); }
    // the dyld table: magic, import count, export count, GOT slots, export addresses
    let mut tab = None;
    for &(flags, off, va, fs, _) in &loads {
        if flags != 6 { continue; }
        let mut k = (8 - va % 8) % 8;
        while k + 32 <= fs {
            if u64at(elf, (off + k) as usize)? == DYLD_MAGIC {
                if tab.is_some() { return Err("duplicate dyld table".into()); }
                tab = Some((va + k, (off + k) as usize));
            }
            k += 8;
        }
    }
    let (tab_va, tab_off) = tab.ok_or("missing dyld table")?;
    let (ni, ne) = (u64at(elf, tab_off + 8)? as usize, u64at(elf, tab_off + 16)? as usize);
    if ni != plan.imports.len() || ne != plan.exports.len() { return Err("dyld table does not match the plan".into()); }
    let entry = u64at(elf, tab_off + 24)?;
    let got_va = tab_va + 32;
    let mut exports = Vec::new();
    for (k, name) in plan.exports.iter().enumerate() {
        exports.push((format!("_{}", name), u64at(elf, tab_off + 32 + 8 * (ni + k))? - base));
    }
    let mut cmds: Vec<Vec<u8>> = Vec::new();
    let seg = |name: &str, va: u64, size: u64, off: u64, filesz: u64, prot: u32| { let mut b = Vec::new(); segment(&mut b, name, va, size, off, filesz, prot); b };
    cmds.push(seg("__PAGEZERO", 0, base, 0, 0, 0));
    let text_end = align(code.1 + code.3)?;
    cmds.push(seg("__TEXT", base, text_end, 0, text_end, 5));
    let mut file_end = text_end;
    let mut vm_end = base + text_end;
    let mut copies = vec![(code.1, code.1, code.3)];
    let mut data_seg: Option<(usize, u64)> = None;
    for &(flags, off, va, fs, ms) in &loads {
        if flags == 5 || off == 0 { continue; }
        if flags != 4 && flags != 6 { return Err("unexpected segment permissions".into()); }
        let prefix = va % 4096;
        let start = va - prefix;
        if start < vm_end { return Err("overlapping Mach-O virtual segments".into()); }
        let size = align(prefix + ms)?;
        let disk = if fs == 0 { 0 } else { align(prefix + fs)? };
        if fs > 0 { copies.push((off, file_end + prefix, fs)); }
        if flags == 6 && tab_va >= start && tab_va < start + size { data_seg = Some((cmds.len(), start)); }
        cmds.push(seg(if flags == 4 { "__CONST" } else { "__DATA" }, start, size, file_end, disk, if flags == 4 { 1 } else { 3 }));
        file_end += disk;
        vm_end = start + size;
    }
    let (data_idx, data_start) = data_seg.ok_or("dyld table outside __DATA")?;
    let link_off = file_end;
    let mut bind = Vec::new();
    if !plan.imports.is_empty() {
        bind.push(0x51); // BIND_TYPE_POINTER
        for (g, (s, ord)) in plan.imports.iter().enumerate() {
            bind.push(0x10 | ord);
            bind.push(0x40); bind.extend_from_slice(format!("_{}", s).as_bytes()); bind.push(0);
            bind.push(0x70 | data_idx as u8); uleb(&mut bind, got_va + 8 * g as u64 - data_start);
            bind.push(0x90);
        }
    }
    bind.push(0);
    while bind.len() % 8 != 0 { bind.push(0); }
    let trie = export_trie(&exports);
    let bind_off = link_off;
    let export_off = bind_off + bind.len() as u64;
    let strtab_off = export_off + trie.len() as u64;
    let link_end = strtab_off + 8;
    cmds.push(seg("__LINKEDIT", vm_end, align(link_end - link_off)?, link_off, link_end - link_off, 1));
    cmds.push(words(&[0x8000_0022, 48, 0, 0, bind_off as u32, bind.len() as u32, 0, 0, 0, 0,
        if trie.is_empty() { 0 } else { export_off as u32 }, trie.len() as u32]));
    cmds.push(words(&[2, 24, strtab_off as u32, 0, strtab_off as u32, 8]));
    cmds.push(words(&[11, 80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
    cmds.push(string_command(14, "/usr/lib/dyld"));
    let mut uuid = words(&[27, 24]);
    let mut h = sha256(&elf[code.1 as usize..(code.1 + code.3) as usize]);
    h[6] = (h[6] & 0x0f) | 0x40; h[8] = (h[8] & 0x3f) | 0x80;
    uuid.extend_from_slice(&h[..16]);
    cmds.push(uuid);
    cmds.push(words(&[50, 24, 1, 0x000a_0f00, 0x000a_0f00, 0]));
    if entry < code.2 || entry >= code.2 + code.3 { return Err("entry outside executable bytes".into()); }
    let mut m = words(&[0x8000_0028, 24]);
    w64(&mut m, entry - base);
    w64(&mut m, 0);
    cmds.push(m);
    cmds.push(string_command(12, "/usr/lib/libSystem.B.dylib"));
    if let Some(path) = ext { cmds.push(string_command(12, path)); }
    let cmdsize: usize = cmds.iter().map(Vec::len).sum();
    let mut out = Vec::new();
    for n in [0xfeedfacf, 0x01000007, 3, 2, cmds.len() as u32, cmdsize as u32, 0x85, 0] { w32(&mut out, n); }
    for c in &cmds { out.extend_from_slice(c); }
    if out.len() > 4096 { return Err("Mach-O load commands exceed the header page".into()); }
    out.resize(link_off as usize, 0);
    for (off, dest, size) in copies {
        let (a, d, n) = (off as usize, dest as usize, size as usize);
        out[d..d + n].copy_from_slice(&elf[a..a + n]);
    }
    out.extend_from_slice(&bind);
    out.extend_from_slice(&trie);
    out.extend_from_slice(&[0u8; 8]);
    Ok(out)
}


#[cfg(test)]
mod tests {
    use super::*;
    fn image(extra: &str) -> Vec<u8> {
        crate::hasm::assemble(&format!(".text\n.globl _start\n_start:\n mov $60, %eax\n xor %edi, %edi\n syscall\n{}",extra)).unwrap()
    }
    #[test]
    fn segment_variants() {
        for extra in ["", ".section .rodata\n.byte 1,2,3\n", ".data\n.quad 42\n", ".bss\n.zero 9000\n", ".section .rodata\n.zero 4095\n.data\n.align 16\n.quad 42\n.bss\n.align 32\n.zero 9000\n"] {
            let out=from_elf(&image(extra)).unwrap();
            assert_eq!(u32at(&out,0).unwrap(),0xfeedfacf);
            assert_eq!(u32at(&out,4).unwrap(),0x01000007);
            assert_eq!(u32at(&out,12).unwrap(),2);
            assert!(out.len()>=4096);
            let count=u32at(&out,16).unwrap();let bytes=u32at(&out,20).unwrap();
            let mut p=32;
            for _ in 0..count {
                let cmd=u32at(&out,p).unwrap();let size=u32at(&out,p+4).unwrap() as usize;
                assert!(size>=8 && size%8==0);
                if cmd==0x19 {
                    let off=u64at(&out,p+40).unwrap();let len=u64at(&out,p+48).unwrap();
                    assert!(off+len<=out.len() as u64);assert_eq!(off%4096,0);
                    assert_ne!(u32at(&out,p+60).unwrap(),7);
                } else {assert_eq!(cmd,5);assert_eq!(size,184);assert_eq!(u32at(&out,p+8).unwrap(),4);assert_eq!(u32at(&out,p+12).unwrap(),42);}
                p+=size;
            }
            assert_eq!(p,32+bytes as usize);
        }
    }
    #[test]
    fn invalid_images_reject() {
        for size in 0..64 {assert!(from_elf(&vec![0;size]).is_err());}
        let mut elf=image("");elf[18]=0xb7;assert!(from_elf(&elf).is_err());
        let mut elf=image("");elf[24..32].copy_from_slice(&0u64.to_le_bytes());assert!(from_elf(&elf).is_err());
    }
    #[test]
    fn lower_only_known_operations() {
        for (linux,mac) in [(1,4),(2,5),(3,6),(9,197),(11,73),(60,1),(72,92),(96,116)] {
            let out=darwin_asm(&format!("mov ${}, %eax\n    syscall\n",linux)).unwrap();
            assert!(out.contains(&format!("mov ${}, %eax",0x2000000+mac)));
            assert!(out.contains("push %rdx")&&out.contains("pop %rdx"));
        }
        assert!(darwin_asm("mov $201, %eax\nsyscall\n").is_err());
        assert!(darwin_asm("mov %rbx, %rax\nsyscall\n").is_err());
        assert!(darwin_asm("syscall\n").is_err());
    }
}

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

// Lower only the four OS operations used by the portable scalar/container
// runtime. An added syscall is a compile-time error, never passed to Darwin
// with a Linux number. Preserve rdx (Darwin has a second return register) and
// r10 (mmap flags); retain Linux's negative-error convention for consumers.
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
        let mac = match n { 1 => 4, 9 => 197, 11 => 73, 60 => 1,
            _ => return Err(format!("Mach-O Intel: OS operation {} is not ported in this increment", n)), };
        serial += 1;
        out.push_str("    push %rdx\n");
        if n == 9 { out.push_str("    push %r10\n    mov $0x1002, %r10d\n"); }
        out.push_str(&format!("    mov ${}, %eax\n    syscall\n    jnc .Ldarwin_ok{}\n    neg %rax\n.Ldarwin_ok{}:\n", 0x2000000u32 + mac, serial, serial));
        if n == 9 { out.push_str("    pop %r10\n"); }
        out.push_str("    pop %rdx\n");
    }
    // Preserve the kernel stack pointer for arena getenv before alignment.
    let out = if out.contains("_start:\n    mov %rsp, %rdi\n    call hbc_arena_env_init") {
        out.replace("_start:\n    mov %rsp, %rdi\n    call hbc_arena_env_init", "_start:\n    mov %rsp, %rdi\n    and $-16, %rsp\n    call hbc_arena_env_init")
    } else {out.replace("_start:\n", "_start:\n    and $-16, %rsp\n")};
    Ok(out.replace("# target: linux - no libc, I/O via own syscall helpers at the end", "# target: macho - experimental Intel Darwin syscall runtime"))
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
        for (linux,mac) in [(1,4),(9,197),(11,73),(60,1)] {
            let out=darwin_asm(&format!("mov ${}, %eax\n    syscall\n",linux)).unwrap();
            assert!(out.contains(&format!("mov ${}, %eax",0x2000000+mac)));
            assert!(out.contains("push %rdx")&&out.contains("pop %rdx"));
        }
        assert!(darwin_asm("mov $201, %eax\nsyscall\n").is_err());
        assert!(darwin_asm("mov %rbx, %rax\nsyscall\n").is_err());
        assert!(darwin_asm("syscall\n").is_err());
    }
}

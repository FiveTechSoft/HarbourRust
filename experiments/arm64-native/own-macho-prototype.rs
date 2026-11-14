// Isolated Rust ARM64 Mach-O/signature prototype, not integrated into hbc.
// No Apple ld/codesign, SDK, LLVM or Cargo dependencies in this generator.
// Still NOT hardware-executed; output structure/hash checks are not loader proof.
#[path = "sha256-prototype.rs"]
mod digest;
fn w32(b: &mut Vec<u8>, n: u32) {
    b.extend_from_slice(&n.to_le_bytes());
}
fn w64(b: &mut Vec<u8>, n: u64) {
    b.extend_from_slice(&n.to_le_bytes());
}
fn be(b: &mut Vec<u8>, n: u32) {
    b.extend_from_slice(&n.to_be_bytes());
}
fn big64(b: &mut Vec<u8>, n: u64) {
    b.extend_from_slice(&n.to_be_bytes());
}
fn aligned(n: u64, a: u64) -> u64 {
    n.checked_add(a - 1).expect("size overflow") & !(a - 1)
}
fn name(b: &mut Vec<u8>, s: &str) {
    assert!(s.len() <= 16);
    b.extend_from_slice(s.as_bytes());
    b.resize(b.len() + 16 - s.len(), 0);
}
fn segment(
    s: &str,
    va: u64,
    ms: u64,
    off: u64,
    fs: u64,
    prot: u32,
    sections: &[(&str, u64, u64, u32, u32)],
) -> Vec<u8> {
    let mut b = Vec::new();
    for n in [25, 72 + 80 * sections.len() as u32] {
        w32(&mut b, n);
    }
    name(&mut b, s);
    for n in [va, ms, off, fs] {
        w64(&mut b, n);
    }
    for n in [prot, prot, sections.len() as u32, 0] {
        w32(&mut b, n);
    }
    for &(sec, addr, size, offset, flags) in sections {
        name(&mut b, sec);
        name(&mut b, s);
        w64(&mut b, addr);
        w64(&mut b, size);
        for n in [offset, 2, 0, 0, flags, 0, 0, 0] {
            w32(&mut b, n);
        }
    }
    b
}
fn string_command(cmd: u32, path: &str) -> Vec<u8> {
    let extra = if cmd == 14 { 0 } else { 12 };
    let size = aligned((12 + extra + path.len() + 1) as u64, 8) as usize;
    let mut b = Vec::new();
    for n in [cmd, size as u32, 12 + extra as u32] {
        w32(&mut b, n);
    }
    if cmd != 14 {
        for n in [0, 0x10000, 0x10000] {
            w32(&mut b, n);
        }
    }
    b.extend_from_slice(path.as_bytes());
    b.resize(size, 0);
    b
}
fn words(v: &[u32]) -> Vec<u8> {
    v.iter().flat_map(|n| n.to_le_bytes()).collect()
}
fn image() -> Vec<u8> {
    const BASE: u64 = 0x100000000;
    const ENTRY: u64 = 0x4000;
    let message = b"ARM64 own writer probe\n";
    let mut instructions = vec![
        0xa9bf7bfd,
        0x910003fd,
        0xd2800020,
        0,
        0xd2800002 | ((message.len() as u32) << 5),
        0xd2800090,
        0xd4001001,
        0xd2800000,
        0xa8c17bfd,
        0xd65f03c0,
    ];
    let constoff = ENTRY + instructions.len() as u64 * 4;
    let relative = constoff - (ENTRY + 3 * 4);
    instructions[3] =
        0x10000001 | (((relative & 3) as u32) << 29) | (((relative >> 2) as u32) << 5);
    let mut code = words(&instructions);
    code.extend_from_slice(message);
    let textsize = aligned(ENTRY + code.len() as u64, 0x4000);
    let linkoff = textsize;
    let sigoff = aligned(linkoff + 16, 16);
    let identifier = b"hbc-arm64-own-prototype\0";
    let cdheader = 88;
    let hashoff = aligned(cdheader + identifier.len() as u64, 8);
    let pages = (sigoff + 4095) / 4096;
    let cdsize = hashoff + pages * 32;
    let sigsize = 20 + cdsize;
    let fileend = sigoff + sigsize;
    let mut commands = vec![
        segment("__PAGEZERO", 0, BASE, 0, 0, 0, &[]),
        segment(
            "__TEXT",
            BASE,
            textsize,
            0,
            textsize,
            5,
            &[
                (
                    "__text",
                    BASE + ENTRY,
                    instructions.len() as u64 * 4,
                    ENTRY as u32,
                    0x80000400,
                ),
                (
                    "__const",
                    BASE + constoff,
                    message.len() as u64,
                    constoff as u32,
                    0,
                ),
            ],
        ),
        segment(
            "__LINKEDIT",
            BASE + linkoff,
            aligned(fileend - linkoff, 0x4000),
            linkoff,
            fileend - linkoff,
            1,
            &[],
        ),
        words(&[0x80000022, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
        words(&[2, 24, linkoff as u32, 0, linkoff as u32, 1]),
        words(&[11, 80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
        string_command(14, "/usr/lib/dyld"),
    ];
    let mut uuid = words(&[27, 24]);
    uuid.extend_from_slice(&digest::sha256(&code)[..16]);
    commands.push(uuid);
    commands.push(words(&[50, 24, 1, 0xb0000, 0xb0000, 0]));
    let mut entry = words(&[0x80000028, 24]);
    w64(&mut entry, ENTRY);
    w64(&mut entry, 0);
    commands.push(entry);
    commands.push(string_command(12, "/usr/lib/libSystem.B.dylib"));
    commands.push(words(&[29, 16, sigoff as u32, sigsize as u32]));
    let cmdsize: usize = commands.iter().map(Vec::len).sum();
    let mut b = words(&[
        0xfeedfacf,
        0x0100000c,
        0,
        2,
        commands.len() as u32,
        cmdsize as u32,
        0x200085,
        0,
    ]);
    for c in commands {
        b.extend(c);
    }
    assert!(b.len() <= ENTRY as usize);
    b.resize(ENTRY as usize, 0);
    b.extend(code);
    b.resize(sigoff as usize, 0);
    let mut cd = Vec::new();
    for n in [
        0xfade0c02,
        cdsize as u32,
        0x20400,
        0x20002,
        hashoff as u32,
        cdheader as u32,
        0,
        pages as u32,
        sigoff as u32,
    ] {
        be(&mut cd, n);
    }
    cd.extend_from_slice(&[32, 2, 0, 12]);
    for _ in 0..4 {
        be(&mut cd, 0);
    }
    big64(&mut cd, 0);
    for n in [0, textsize, 1] {
        big64(&mut cd, n);
    }
    assert_eq!(cd.len(), cdheader as usize);
    cd.extend_from_slice(identifier);
    cd.resize(hashoff as usize, 0);
    for page in b.chunks(4096) {
        cd.extend_from_slice(&digest::sha256(page));
    }
    assert_eq!(cd.len(), cdsize as usize);
    for n in [0xfade0cc0, sigsize as u32, 1, 0, 20] {
        be(&mut b, n);
    }
    b.extend(cd);
    assert_eq!(b.len(), fileend as usize);
    b
}
fn main() {
    let path = std::env::args().nth(1).expect("output path");
    std::fs::write(path, image()).unwrap();
}

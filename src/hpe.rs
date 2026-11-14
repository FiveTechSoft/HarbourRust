// hpe: escritor PE32+ (PE64) para hbc AUTÓNOMO Fase 2.
//
// Replica byte a byte la salida de `x86_64-w64-mingw32-ld -s x.o -o x.exe
// -e _start --subsystem console -lkernel32` (binutils 2.38) salvo los 10
// bytes normalizados por la gate W1: TimeDateStamp (4B @0x88),
// Major/MinorLinkerVersion (2B @0x9A) y CheckSum (4B @0xD8).
// Todo el layout está medido sobre el oráculo real (ver STATUS Fase 2):
//   - ImageBase 0x140000000, SectionAlignment 0x1000, FileAlignment 0x200
//   - secciones .text .data .rdata .bss .idata (solo las presentes)
//   - .idata: dir + null + ILT + IAT + hint/name strings (pad par)
//     + alinear a 4 + n x u32(idata_rva) + "KERNEL32.dll\0" + pad 4
//   - hints de libkernel32.a (mingw-w64 8.0.0): tabla HINTS
//   - CheckSum: algoritmo estándar (suma de palabras con acarreo, campo
//     a cero, + longitud del fichero); verificado contra el oráculo.

pub struct PeImage {
    pub text: Vec<u8>,               // .text completo: código + thunks + cola
    pub text_rva: u32,
    pub data: Option<(Vec<u8>, u32)>,
    pub rdata: Option<(Vec<u8>, u32)>,
    pub bss: Option<(u64, u32)>,     // tamaño, rva (sin contenido en fichero)
    pub idata_rva: u32,
    pub iat_rva: u32,
    pub idata_size: u32,
    pub imports: Vec<String>,        // orden alfabético (orden IAT)
    pub entry_rva: u32,
}

// Hints de libkernel32.a (medidos del oráculo; estables por DLL).
fn hint_of(name: &str) -> u16 {
    match name {
        "VirtualAlloc" => 1486,
        "VirtualFree" => 1489,
        "GetSystemInfo" => 763,
        "ExitProcess" => 366,
        "GetEnvironmentVariableA" => 588,
        "GetLocalTime" => 632,
        "GetProcessHeap" => 716,
        "GetStdHandle" => 746,
        "HeapAlloc" => 863,
        "HeapFree" => 869,
        "WriteFile" => 1567,
        _ => unreachable!("import fuera de lista blanca"),
    }
}

// Cabecera DOS + stub de ld (64 bytes de cabecera + stub "This program..."),
// con e_lfanew = 0x80.
const DOS_STUB: [u8; 128] = [
    0x4d, 0x5a, 0x90, 0x00, 0x03, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00,
    0xb8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00,
    0x0e, 0x1f, 0xba, 0x0e, 0x00, 0xb4, 0x09, 0xcd, 0x21, 0xb8, 0x01, 0x4c, 0xcd, 0x21, 0x54, 0x68,
    0x69, 0x73, 0x20, 0x70, 0x72, 0x6f, 0x67, 0x72, 0x61, 0x6d, 0x20, 0x63, 0x61, 0x6e, 0x6e, 0x6f,
    0x74, 0x20, 0x62, 0x65, 0x20, 0x72, 0x75, 0x6e, 0x20, 0x69, 0x6e, 0x20, 0x44, 0x4f, 0x53, 0x20,
    0x6d, 0x6f, 0x64, 0x65, 0x2e, 0x0d, 0x0d, 0x0a, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
];

const FILE_ALIGN: u64 = 0x200;
const SECT_ALIGN: u64 = 0x1000;

fn align_up(x: u64, a: u64) -> u64 { (x + a - 1) & !(a - 1) }

fn build_idata(img: &PeImage) -> Vec<u8> {
    let n = img.imports.len();
    let ilt_rva = img.idata_rva + 0x28;
    let iat_rva = ilt_rva + 8 * (n as u32 + 1);
    let strs_rva = iat_rva + 8 * (n as u32 + 1);
    // offsets de las cadenas hint/name
    let mut str_rvas: Vec<u32> = Vec::with_capacity(n);
    let mut cur = strs_rva;
    for name in &img.imports {
        str_rvas.push(cur);
        let l = 2 + name.len() as u32 + 1;
        cur += (l + 1) & !1;
    }
    let gap_rva = (cur + 3) & !3;
    let name_rva = gap_rva + 4 * n as u32;

    let mut d = Vec::new();
    let w32 = |d: &mut Vec<u8>, v: u32| d.extend_from_slice(&v.to_le_bytes());
    let w64 = |d: &mut Vec<u8>, v: u64| d.extend_from_slice(&v.to_le_bytes());
    // import directory entry + null entry
    w32(&mut d, ilt_rva); w32(&mut d, 0); w32(&mut d, 0); w32(&mut d, name_rva); w32(&mut d, iat_rva);
    for _ in 0..5 { w32(&mut d, 0); }
    // ILT
    for &r in &str_rvas { w64(&mut d, r as u64); }
    w64(&mut d, 0);
    // IAT
    for &r in &str_rvas { w64(&mut d, r as u64); }
    w64(&mut d, 0);
    // cadenas hint/name
    for (name, _) in img.imports.iter().zip(&str_rvas) {
        d.extend_from_slice(&hint_of(name).to_le_bytes());
        d.extend_from_slice(name.as_bytes());
        d.push(0);
        if d.len() % 2 != 0 { d.push(0); }
    }
    while d.len() % 4 != 0 { d.push(0); }
    for _ in 0..n { w32(&mut d, img.idata_rva); }
    d.extend_from_slice(b"KERNEL32.dll\0");
    while d.len() % 4 != 0 { d.push(0); }
    d
}

pub fn write_pe(img: &PeImage) -> Vec<u8> {
    let idata = build_idata(img);
    debug_assert_eq!(idata.len() as u32, img.idata_size);

    // secciones presentes, en orden fijo
    struct S<'a> { name: &'a [u8; 8], vsize: u64, rva: u32, bytes: Option<&'a [u8]>, chars: u32 }
    let mut secs: Vec<S> = Vec::new();
    secs.push(S { name: b".text\0\0\0", vsize: img.text.len() as u64, rva: img.text_rva,
                  bytes: Some(&img.text), chars: 0x60000020 });
    if let Some((b, rva)) = &img.data {
        secs.push(S { name: b".data\0\0\0", vsize: b.len() as u64, rva: *rva,
                      bytes: Some(b), chars: 0xC0000040 });
    }
    if let Some((b, rva)) = &img.rdata {
        secs.push(S { name: b".rdata\0\0", vsize: b.len() as u64, rva: *rva,
                      bytes: Some(b), chars: 0x40000040 });
    }
    if let Some((sz, rva)) = &img.bss {
        secs.push(S { name: b".bss\0\0\0\0", vsize: *sz, rva: *rva, bytes: None, chars: 0xC0000080 });
    }
    secs.push(S { name: b".idata\0\0", vsize: idata.len() as u64, rva: img.idata_rva,
                  bytes: Some(&idata), chars: 0xC0000040 });
    let nsec = secs.len() as u64;

    let size_code = align_up(img.text.len() as u64, FILE_ALIGN);
    let mut size_init = align_up(idata.len() as u64, FILE_ALIGN);
    if let Some((b, _)) = &img.data { size_init += align_up(b.len() as u64, FILE_ALIGN); }
    if let Some((b, _)) = &img.rdata { size_init += align_up(b.len() as u64, FILE_ALIGN); }
    let size_uninit = img.bss.map(|(sz, _)| align_up(sz, FILE_ALIGN)).unwrap_or(0);
    let headers_size = align_up(0x80 + 4 + 20 + 240 + 40 * nsec, FILE_ALIGN);
    let image_end = img.idata_rva as u64 + idata.len() as u64;
    let size_image = align_up(image_end, SECT_ALIGN);

    let ts: u32 = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH).map(|d| d.as_secs() as u32).unwrap_or(0);

    let mut out: Vec<u8> = Vec::new();
    let w8 = |out: &mut Vec<u8>, v: u8| out.push(v);
    let w16 = |out: &mut Vec<u8>, v: u16| out.extend_from_slice(&v.to_le_bytes());
    let w32 = |out: &mut Vec<u8>, v: u32| out.extend_from_slice(&v.to_le_bytes());
    let w64 = |out: &mut Vec<u8>, v: u64| out.extend_from_slice(&v.to_le_bytes());

    // DOS + stub
    out.extend_from_slice(&DOS_STUB);
    // firma PE
    out.extend_from_slice(b"PE\0\0");
    // COFF header
    w16(&mut out, 0x8664);                    // Machine: AMD64
    w16(&mut out, nsec as u16);
    w32(&mut out, ts);                        // TimeDateStamp (normalizado por W1)
    w32(&mut out, 0);                         // PointerToSymbolTable
    w32(&mut out, 0);                         // NumberOfSymbols
    w16(&mut out, 240);                       // SizeOfOptionalHeader
    w16(&mut out, 0x22E);                     // Characteristics (exec, ln/sym strip, LAA, dbg strip)
    // Optional header (PE32+)
    w16(&mut out, 0x20B);
    w8(&mut out, 2);                          // MajorLinkerVersion (normalizado por W1)
    w8(&mut out, 38);                         // MinorLinkerVersion (normalizado por W1)
    w32(&mut out, size_code as u32);
    w32(&mut out, size_init as u32);
    w32(&mut out, size_uninit as u32);
    w32(&mut out, img.entry_rva);
    w32(&mut out, 0x1000);                    // BaseOfCode
    w64(&mut out, 0x140000000);               // ImageBase
    w32(&mut out, SECT_ALIGN as u32);
    w32(&mut out, FILE_ALIGN as u32);
    w16(&mut out, 4); w16(&mut out, 0);       // OS version
    w16(&mut out, 0); w16(&mut out, 0);       // Image version
    w16(&mut out, 5); w16(&mut out, 2);       // Subsystem version
    w32(&mut out, 0);                         // Win32Version
    w32(&mut out, size_image as u32);
    w32(&mut out, headers_size as u32);
    w32(&mut out, 0);                         // CheckSum: se parchea al final
    w16(&mut out, 3);                         // Subsystem: Windows CUI
    w16(&mut out, 0x160);                     // DllCharacteristics
    w64(&mut out, 0x200000); w64(&mut out, 0x1000);   // stack reserve/commit
    w64(&mut out, 0x100000); w64(&mut out, 0x1000);   // heap reserve/commit
    w32(&mut out, 0);                         // LoaderFlags
    w32(&mut out, 16);                        // NumberOfRvaAndSizes
    // Data directories
    for i in 0..16 {
        match i {
            1 => { w32(&mut out, img.idata_rva); w32(&mut out, idata.len() as u32); }
            12 => { w32(&mut out, img.iat_rva); w32(&mut out, 8 * (img.imports.len() as u32 + 1)); }
            _ => { w32(&mut out, 0); w32(&mut out, 0); }
        }
    }
    // tabla de secciones
    let mut raw_ptr = headers_size;
    let mut raw_ptrs: Vec<u32> = Vec::with_capacity(secs.len());
    for s in &secs {
        let raw_size = if s.bytes.is_some() { align_up(s.vsize, FILE_ALIGN) } else { 0 };
        let rp = if s.bytes.is_some() { raw_ptr } else { 0 };
        raw_ptrs.push(rp as u32);
        out.extend_from_slice(s.name);
        w32(&mut out, s.vsize as u32);
        w32(&mut out, s.rva);
        w32(&mut out, raw_size as u32);
        w32(&mut out, rp as u32);
        w32(&mut out, 0); w32(&mut out, 0);
        w16(&mut out, 0); w16(&mut out, 0);
        w32(&mut out, s.chars);
        if s.bytes.is_some() { raw_ptr += align_up(s.vsize, FILE_ALIGN); }
    }
    out.resize(headers_size as usize, 0);
    // contenido de secciones (cada slot de fichero ocupa su raw_size alineado)
    for (s, &rp) in secs.iter().zip(&raw_ptrs) {
        if let Some(b) = s.bytes {
            out.resize(rp as usize, 0);
            out.extend_from_slice(b);
            out.resize(rp as usize + align_up(s.vsize, FILE_ALIGN) as usize, 0);
        }
    }
    // checksum estándar (campo a cero, suma de palabras con acarreo, + len)
    let ck_off = 0x80 + 4 + 20 + 64;
    let mut sum: u64 = 0;
    let mut i = 0usize;
    while i < out.len() {
        let lo = out[i] as u64;
        let hi = if i + 1 < out.len() { out[i + 1] as u64 } else { 0 };
        let w = if i == ck_off || i == ck_off + 2 { 0 } else { lo | (hi << 8) };
        sum += w;
        sum = (sum & 0xffff) + (sum >> 16);
        i += 2;
    }
    sum = (sum & 0xffff) + (sum >> 16);
    sum += out.len() as u64;
    let ck = sum as u32;
    out[ck_off..ck_off + 4].copy_from_slice(&ck.to_le_bytes());
    out
}

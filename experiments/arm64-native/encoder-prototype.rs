// Isolated ARM64 encoding experiment. NOT linked into hbc and not a backend.
// All operands are validated. Instructions are compared with independent LLVM
// assembly in the research harness, not claimed hardware-executed.
fn reg(r: u8) -> Result<u32, String> {
    if r < 32 && r != 18 {
        Ok(r as u32)
    } else {
        Err("invalid/reserved ARM register".into())
    }
}
fn signed(v: i64, bits: u32) -> Result<u32, String> {
    if v >= -(1i64 << (bits - 1)) && v < (1i64 << (bits - 1)) {
        Ok((v as u32) & ((1u32 << bits) - 1))
    } else {
        Err("signed immediate out of range".into())
    }
}
fn aligned_words(bytes: i64, bits: u32) -> Result<u32, String> {
    if bytes % 4 != 0 {
        return Err("unaligned branch".into());
    }
    signed(bytes / 4, bits)
}
fn movz(rd: u8, value: u16, shift: u8) -> Result<u32, String> {
    if shift % 16 != 0 || shift > 48 {
        return Err("MOVZ shift".into());
    }
    Ok(0xd2800000 | ((shift as u32 / 16) << 21) | ((value as u32) << 5) | reg(rd)?)
}
fn addsub(rd: u8, rn: u8, value: u16, sub: bool, flags: bool) -> Result<u32, String> {
    if value > 4095 {
        return Err("ADD/SUB immediate".into());
    }
    Ok(0x91000000
        | ((sub as u32) << 30)
        | ((flags as u32) << 29)
        | ((value as u32) << 10)
        | (reg(rn)? << 5)
        | reg(rd)?)
}
fn arithmetic(rd: u8, rn: u8, rm: u8, sub: bool) -> Result<u32, String> {
    Ok(0x8b000000 | ((sub as u32) << 30) | (reg(rm)? << 16) | (reg(rn)? << 5) | reg(rd)?)
}
fn loadstore(rt: u8, rn: u8, offset: u16, load: bool) -> Result<u32, String> {
    if offset % 8 != 0 || offset > 32760 {
        return Err("LDR/STR scaled immediate".into());
    }
    Ok(0xf9000000
        | ((load as u32) << 22)
        | ((offset as u32 / 8) << 10)
        | (reg(rn)? << 5)
        | reg(rt)?)
}
fn branch(offset: i64, link: bool) -> Result<u32, String> {
    Ok(0x14000000 | ((link as u32) << 31) | aligned_words(offset, 26)?)
}
fn branch_cond(offset: i64, condition: u8) -> Result<u32, String> {
    if condition > 13 {
        return Err("condition reserved".into());
    }
    Ok(0x54000000 | (aligned_words(offset, 19)? << 5) | condition as u32)
}
fn adr(rd: u8, offset: i64, page: bool) -> Result<u32, String> {
    let n = if page {
        if offset % 4096 != 0 {
            return Err("ADRP alignment".into());
        }
        signed(offset / 4096, 21)?
    } else {
        signed(offset, 21)?
    };
    Ok(0x10000000 | ((page as u32) << 31) | ((n & 3) << 29) | ((n >> 2) << 5) | reg(rd)?)
}
fn pair(rt: u8, rt2: u8, rn: u8, offset: i64, load: bool, post: bool) -> Result<u32, String> {
    if offset % 8 != 0 {
        return Err("pair alignment".into());
    }
    Ok((if post { 0xa8800000 } else { 0xa9800000 })
        | ((load as u32) << 22)
        | (signed(offset / 8, 7)? << 15)
        | (reg(rt2)? << 10)
        | (reg(rn)? << 5)
        | reg(rt)?)
}
fn main() {
    let words = vec![
        movz(0, 0, 0).unwrap(),
        movz(1, 42, 0).unwrap(),
        movz(9, 65535, 48).unwrap(),
        addsub(31, 31, 32, true, false).unwrap(),
        addsub(31, 31, 32, false, false).unwrap(),
        arithmetic(0, 1, 2, false).unwrap(),
        arithmetic(3, 4, 5, true).unwrap(),
        loadstore(0, 31, 16, true).unwrap(),
        loadstore(1, 31, 24, false).unwrap(),
        branch(16, false).unwrap(),
        branch(-16, true).unwrap(),
        branch_cond(8, 0).unwrap(),
        branch_cond(-8, 11).unwrap(),
        adr(0, 0, false).unwrap(),
        adr(1, 4096, true).unwrap(),
        pair(29, 30, 31, -16, false, false).unwrap(),
        pair(29, 30, 31, 16, true, true).unwrap(),
        0xd65f03c0u32,
    ];
    let path = std::env::args().nth(1).expect("output path");
    let bytes: Vec<u8> = words.iter().flat_map(|x| x.to_le_bytes()).collect();
    std::fs::write(path, bytes).unwrap();
    assert!(reg(18).is_err());
    assert!(reg(32).is_err());
    assert!(branch(3, false).is_err());
    assert!(branch(1i64 << 28, false).is_err());
    assert!(loadstore(0, 1, 3, true).is_err());
    assert!(movz(0, 0, 8).is_err());
}

// Isolated ARM64 emitter infrastructure. No hbc target admission.
// x18 is never allowed. Register 31 means ZR or SP according to instruction.
use std::collections::BTreeMap;
#[derive(Clone, Copy)]
enum FixKind {
    B(bool),
    Cond(u8),
    Adr(u8),
}
#[derive(Default)]
pub struct Code {
    words: Vec<u32>,
    labels: BTreeMap<String, usize>,
    fixups: Vec<(usize, String, FixKind)>,
    data: Vec<u8>,
    data_labels: BTreeMap<String, usize>,
}
fn reg(r: u8) -> Result<u32, String> {
    if r < 32 && r != 18 {
        Ok(r as u32)
    } else {
        Err("invalid/reserved ARM64 register".into())
    }
}
fn signed(v: i64, bits: u32) -> Result<u32, String> {
    if v >= -(1i64 << (bits - 1)) && v < (1i64 << (bits - 1)) {
        Ok((v as u32) & ((1u32 << bits) - 1))
    } else {
        Err("ARM64 relative address out of range".into())
    }
}
impl Code {
    pub fn pos(&self) -> usize {
        self.words.len() * 4
    }
    pub fn label(&mut self, s: &str) -> Result<(), String> {
        if self.labels.contains_key(s) || self.data_labels.contains_key(s) {
            return Err(format!("duplicate label {s}"));
        }
        self.labels.insert(s.into(), self.pos());
        Ok(())
    }
    pub fn data(&mut self, s: &str, b: &[u8]) -> Result<(), String> {
        if self.labels.contains_key(s) || self.data_labels.contains_key(s) {
            return Err(format!("duplicate label {s}"));
        }
        self.data_labels.insert(s.into(), self.data.len());
        self.data.extend_from_slice(b);
        Ok(())
    }
    fn raw(&mut self, w: u32) {
        self.words.push(w)
    }
    pub fn svc(&mut self) {
        self.raw(0xd4001001);
    }
    pub fn mov(&mut self, rd: u8, value: u64) -> Result<(), String> {
        let r = reg(rd)?;
        self.raw(0xd2800000 | (((value & 65535) as u32) << 5) | r);
        for s in 1..4 {
            let h = ((value >> (16 * s)) & 65535) as u32;
            if h != 0 {
                self.raw(0xf2800000 | (s << 21) | (h << 5) | r)
            }
        }
        Ok(())
    }
    pub fn copy(&mut self, rd: u8, rn: u8) -> Result<(), String> {
        self.raw(0xaa0003e0 | (reg(rn)? << 16) | reg(rd)?);
        Ok(())
    }
    pub fn imm(&mut self, rd: u8, rn: u8, v: u16, sub: bool, flags: bool) -> Result<(), String> {
        if v > 4095 {
            return Err("immediate >4095".into());
        }
        self.raw(
            0x91000000
                | ((sub as u32) << 30)
                | ((flags as u32) << 29)
                | ((v as u32) << 10)
                | (reg(rn)? << 5)
                | reg(rd)?,
        );
        Ok(())
    }
    pub fn addsub(&mut self, rd: u8, rn: u8, rm: u8, sub: bool, flags: bool) -> Result<(), String> {
        self.raw(
            0x8b000000
                | ((sub as u32) << 30)
                | ((flags as u32) << 29)
                | (reg(rm)? << 16)
                | (reg(rn)? << 5)
                | reg(rd)?,
        );
        Ok(())
    }
    pub fn ldst(&mut self, rt: u8, rn: u8, off: u16, load: bool) -> Result<(), String> {
        if off % 8 != 0 || off > 32760 {
            return Err("LDR/STR offset".into());
        }
        self.raw(
            0xf9000000
                | ((load as u32) << 22)
                | ((off as u32 / 8) << 10)
                | (reg(rn)? << 5)
                | reg(rt)?,
        );
        Ok(())
    }
    pub fn byte(&mut self, rt: u8, rn: u8, off: u16, load: bool) -> Result<(), String> {
        if off > 4095 {
            return Err("LDRB/STRB offset".into());
        }
        self.raw(
            0x39000000 | ((load as u32) << 22) | ((off as u32) << 10) | (reg(rn)? << 5) | reg(rt)?,
        );
        Ok(())
    }
    pub fn pair(
        &mut self,
        rt: u8,
        rt2: u8,
        rn: u8,
        off: i64,
        load: bool,
        post: bool,
    ) -> Result<(), String> {
        if off % 8 != 0 {
            return Err("pair alignment".into());
        }
        if (load && rt == rt2) || (rn != 31 && (rn == rt || rn == rt2)) {
            return Err("pair register/writeback overlap".into());
        }
        self.raw(
            (if post { 0xa8800000 } else { 0xa9800000 })
                | ((load as u32) << 22)
                | (signed(off / 8, 7)? << 15)
                | (reg(rt2)? << 10)
                | (reg(rn)? << 5)
                | reg(rt)?,
        );
        Ok(())
    }
    pub fn udiv(&mut self, rd: u8, rn: u8, rm: u8) -> Result<(), String> {
        self.raw(0x9ac00800 | (reg(rm)? << 16) | (reg(rn)? << 5) | reg(rd)?);
        Ok(())
    }
    pub fn msub(&mut self, rd: u8, rn: u8, rm: u8, ra: u8) -> Result<(), String> {
        self.raw(0x9b008000 | (reg(rm)? << 16) | (reg(ra)? << 10) | (reg(rn)? << 5) | reg(rd)?);
        Ok(())
    }
    pub fn cset(&mut self, rd: u8, cond: u8) -> Result<(), String> {
        if cond > 13 {
            return Err("condition".into());
        }
        self.raw(0x9a9f07e0 | (((cond ^ 1) as u32) << 12) | reg(rd)?);
        Ok(())
    }
    pub fn b(&mut self, s: &str, link: bool) {
        self.fixups
            .push((self.words.len(), s.into(), FixKind::B(link)));
        self.raw(0)
    }
    pub fn bc(&mut self, s: &str, c: u8) -> Result<(), String> {
        if c > 13 {
            return Err("condition".into());
        }
        self.fixups
            .push((self.words.len(), s.into(), FixKind::Cond(c)));
        self.raw(0);
        Ok(())
    }
    pub fn adr(&mut self, rd: u8, s: &str) -> Result<(), String> {
        reg(rd)?;
        self.fixups
            .push((self.words.len(), s.into(), FixKind::Adr(rd)));
        self.raw(0);
        Ok(())
    }
    pub fn prologue(&mut self, bytes: u16) -> Result<(), String> {
        if bytes % 16 != 0 || bytes > 4095 {
            return Err("frame must be aligned and <=4080 bytes".into());
        }
        self.pair(29, 30, 31, -16, false, false)?;
        self.imm(29, 31, 0, false, false)?;
        if bytes > 0 {
            self.imm(31, 31, bytes, true, false)?
        }
        Ok(())
    }
    pub fn epilogue(&mut self) -> Result<(), String> {
        self.imm(31, 29, 0, false, false)?;
        self.pair(29, 30, 31, 16, true, true)?;
        self.raw(0xd65f03c0);
        Ok(())
    }
    pub fn finish(mut self) -> Result<(Vec<u8>, Vec<u8>), String> {
        for (p, s, k) in self.fixups {
            let target = if let Some(v) = self.labels.get(&s) {
                *v
            } else if let Some(v) = self.data_labels.get(&s) {
                self.words.len() * 4 + *v
            } else {
                return Err(format!("unresolved label {s}"));
            };
            if self.data_labels.contains_key(&s) && !matches!(k, FixKind::Adr(_)) {
                return Err("branch target is not code".into());
            }
            let off = target as i64 - (p * 4) as i64;
            self.words[p] = match k {
                FixKind::B(link) => {
                    if off % 4 != 0 {
                        return Err("branch target alignment".into());
                    }
                    0x14000000 | ((link as u32) << 31) | signed(off / 4, 26)?
                }
                FixKind::Cond(c) => {
                    if off % 4 != 0 {
                        return Err("branch target alignment".into());
                    }
                    0x54000000 | (signed(off / 4, 19)? << 5) | c as u32
                }
                FixKind::Adr(rd) => {
                    let n = signed(off, 21)?;
                    0x10000000 | ((n & 3) << 29) | ((n >> 2) << 5) | rd as u32
                }
            };
        }
        Ok((
            self.words.into_iter().flat_map(u32::to_le_bytes).collect(),
            self.data,
        ))
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn forward_backwards_and_data() {
        let mut c = Code::default();
        c.label("a").unwrap();
        c.b("b", false);
        c.adr(0, "text").unwrap();
        c.label("b").unwrap();
        c.b("a", true);
        c.data("text", b"hi").unwrap();
        let (b, d) = c.finish().unwrap();
        assert_eq!(
            b,
            [0x14000002u32, 0x10000040, 0x97fffffe]
                .into_iter()
                .flat_map(u32::to_le_bytes)
                .collect::<Vec<_>>()
        );
        assert_eq!(d, b"hi");
    }
    #[test]
    fn rejects() {
        let mut c = Code::default();
        assert!(c.mov(18, 1).is_err());
        assert!(c.mov(32, 1).is_err());
        assert!(c.imm(0, 0, 4096, false, false).is_err());
        assert!(c.ldst(0, 1, 3, true).is_err());
        assert!(c.prologue(8).is_err());
        assert!(c.pair(0, 0, 31, 16, true, true).is_err());
        assert!(c.pair(0, 1, 0, -16, false, false).is_err());
        assert!(c.bc("x", 14).is_err());
        c.label("x").unwrap();
        assert!(c.data("x", b"").is_err());
        assert!(c.label("x").is_err());
        c.b("missing", false);
        assert!(c.finish().is_err());
    }
}

#[cfg(test)]
mod range_tests {
    use super::*;
    #[test]
    fn rejects_data_branches_and_relative_range() {
        let mut c = Code::default();
        c.b("text", false);
        c.data("text", b"abcd").unwrap();
        assert!(c.finish().is_err());
        let mut c = Code::default();
        c.adr(0, "text").unwrap();
        c.words.resize(262144, 0xd503201f);
        c.data("text", b"abcd").unwrap();
        assert!(c.finish().is_err());
        let mut c = Code::default();
        c.bc("far", 0).unwrap();
        c.words.resize(262144, 0xd503201f);
        c.label("far").unwrap();
        assert!(c.finish().is_err());
    }
}

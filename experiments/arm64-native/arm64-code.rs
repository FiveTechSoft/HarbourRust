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
    pub fn ret(&mut self) {
        self.raw(0xd65f03c0);
    }
    pub fn svc(&mut self) {
        self.raw(0xd4001001);
    }
    pub fn fp_env(&mut self, r: u8, status: bool, write: bool) -> Result<(), String> {
        self.raw((if write { 0xd51b4400 } else { 0xd53b4400 }) | ((status as u32) << 5) | reg(r)?);
        Ok(())
    }
    pub fn isb(&mut self) {
        self.raw(0xd5033fdf);
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
    pub fn mul(&mut self, rd: u8, rn: u8, rm: u8, high: bool) -> Result<(), String> {
        self.raw(
            (if high { 0x9b407c00 } else { 0x9b007c00 })
                | (reg(rm)? << 16)
                | (reg(rn)? << 5)
                | reg(rd)?,
        );
        Ok(())
    }
    pub fn asr(&mut self, rd: u8, rn: u8, shift: u8) -> Result<(), String> {
        if shift > 63 {
            return Err("ASR shift >63".into());
        }
        self.raw(0x9340fc00 | ((shift as u32) << 16) | (reg(rn)? << 5) | reg(rd)?);
        Ok(())
    }
    pub fn scvtf(&mut self, dd: u8, rn: u8) -> Result<(), String> {
        if dd > 31 {
            return Err("FP register >31".into());
        }
        self.raw(0x9e620000 | (reg(rn)? << 5) | dd as u32);
        Ok(())
    }
    pub fn fp64(&mut self, dd: u8, dn: u8, dm: u8, op: char) -> Result<(), String> {
        if dd > 31 || dn > 31 || dm > 31 {
            return Err("FP register >31".into());
        }
        let base = match op {
            '+' => 0x1e602800,
            '-' => 0x1e603800,
            '*' => 0x1e600800,
            '/' => 0x1e601800,
            _ => return Err("FP64 operation unavailable".into()),
        };
        self.raw(base | ((dm as u32) << 16) | ((dn as u32) << 5) | dd as u32);
        Ok(())
    }
    pub fn fabs(&mut self, dd: u8, dn: u8) -> Result<(), String> {
        if dd > 31 || dn > 31 {
            return Err("FP register >31".into());
        }
        self.raw(0x1e60c000 | ((dn as u32) << 5) | dd as u32);
        Ok(())
    }
    pub fn fcvtzs(&mut self, rd: u8, dn: u8) -> Result<(), String> {
        if dn > 31 {
            return Err("FP register >31".into());
        }
        self.raw(0x9e780000 | ((dn as u32) << 5) | reg(rd)?);
        Ok(())
    }
    pub fn fcvtzu(&mut self, rd: u8, dn: u8) -> Result<(), String> {
        if dn > 31 {
            return Err("FP register >31".into());
        }
        self.raw(0x9e790000 | ((dn as u32) << 5) | reg(rd)?);
        Ok(())
    }
    pub fn bits(&mut self, rd: u8, rn: u8, lsb: u8, width: u8) -> Result<(), String> {
        if width == 0 || lsb > 63 || width > 64 - lsb {
            return Err("bitfield range".into());
        }
        self.raw(
            0xd3400000
                | ((lsb as u32) << 16)
                | (((lsb as u32) + (width as u32) - 1) << 10)
                | (reg(rn)? << 5)
                | reg(rd)?,
        );
        Ok(())
    }
    pub fn fcmp(&mut self, dn: u8, dm: u8) -> Result<(), String> {
        if dn > 31 || dm > 31 {
            return Err("FP register >31".into());
        }
        self.raw(0x1e602000 | ((dm as u32) << 16) | ((dn as u32) << 5));
        Ok(())
    }
    pub fn fcmp_zero(&mut self, dn: u8) -> Result<(), String> {
        if dn > 31 {
            return Err("FP register >31".into());
        }
        self.raw(0x1e602008 | ((dn as u32) << 5));
        Ok(())
    }
    pub fn fp_bits(&mut self, rd: u8, dn: u8, to_integer: bool) -> Result<(), String> {
        if dn > 31 {
            return Err("FP register >31".into());
        }
        let r = reg(rd)?;
        self.raw(if to_integer {
            0x9e660000 | ((dn as u32) << 5) | r
        } else {
            0x9e670000 | (r << 5) | dn as u32
        });
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

#[cfg(test)]
mod numeric_tests {
    use super::*;
    #[test]
    fn rejects_numeric_operands() {
        let mut c = Code::default();
        assert!(c.mul(18, 0, 1, false).is_err());
        assert!(c.mul(0, 18, 1, true).is_err());
        assert!(c.asr(0, 0, 64).is_err());
        assert!(c.scvtf(32, 0).is_err());
        assert!(c.scvtf(0, 18).is_err());
        assert!(c.fp64(32, 0, 1, '+').is_err());
        assert!(c.fp64(0, 32, 1, '-').is_err());
        assert!(c.fp64(0, 0, 32, '*').is_err());
        assert!(c.fp64(0, 0, 1, '%').is_err());
        assert!(c.fp_bits(18, 0, true).is_err());
        assert!(c.fp_bits(0, 32, false).is_err());
        assert!(c.fcmp(32, 0).is_err());
        assert!(c.fcmp(0, 32).is_err());
        assert!(c.fcmp_zero(32).is_err());
        assert!(c.fabs(32, 0).is_err());
        assert!(c.fabs(0, 32).is_err());
        assert!(c.fcvtzu(18, 0).is_err());
        assert!(c.fcvtzs(0, 32).is_err());
        assert!(c.bits(18, 0, 0, 1).is_err());
        assert!(c.bits(0, 32, 0, 1).is_err());
        assert!(c.bits(0, 0, 64, 1).is_err());
        assert!(c.bits(0, 0, 0, 0).is_err());
        assert!(c.bits(0, 0, 1, 64).is_err());
    }
    #[test]
    fn fp_register_18_is_not_the_reserved_integer_x18() {
        let mut c = Code::default();
        c.scvtf(18, 0).unwrap();
        c.fp64(18, 18, 18, '+').unwrap();
        c.fp_bits(0, 18, true).unwrap();
        c.fcmp(18, 18).unwrap();
        assert_eq!(c.finish().unwrap().0.len(), 16);
    }
}

#[cfg(test)]
mod fp_env_tests {
    use super::*;
    #[test]
    fn environment_words_and_reserved_registers() {
        let mut c = Code::default();
        for status in [false, true] {
            assert!(c.fp_env(18, status, false).is_err());
            assert!(c.fp_env(18, status, true).is_err());
            assert!(c.fp_env(32, status, false).is_err());
        }
        c.fp_env(9, false, false).unwrap();
        c.fp_env(9, false, true).unwrap();
        c.fp_env(10, true, false).unwrap();
        c.fp_env(10, true, true).unwrap();
        c.isb();
        let (b, d) = c.finish().unwrap();
        assert!(d.is_empty());
        assert_eq!(
            b,
            [
                0xd53b4409u32,
                0xd51b4409,
                0xd53b442a,
                0xd51b442a,
                0xd5033fdf
            ]
            .into_iter()
            .flat_map(u32::to_le_bytes)
            .collect::<Vec<_>>()
        );
    }
}

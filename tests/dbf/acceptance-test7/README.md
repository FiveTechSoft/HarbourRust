# acceptance-test7: D5 `%` and `^` over DBF decimal fields and Dyn cells

`test7.prg` exercises `%` (modulus) and `^` (power) with Dyn operands
under an active DBF: decimal fields, integer fields, Dyn float cells
(D3 arithmetic results), negative operands and both records of the
fixture copy. Both operators ALWAYS widen to double with dec = SET
DECIMALS (2), measured against real Harbour 3.2 (hb_vmModulus is C
fmod with the sign of the DIVIDEND; hb_vmPower is C pow, including the
glibc rounding of 51000^2 -> 2601000000.00 and negative-base integral
exponents: (-2)^3 = -8.00).

Run it on a COPY of `../acceptance-test3/M_CLIE.DBF` (the anonymized
fixture; the real file never leaves the owner's machine):

    cp ../acceptance-test3/M_CLIE.DBF m_clie.dbf
    hbc test7.prg test7        # or --target=windows for the PE64
    ./test7

Expected stdout: `test7.linux.expected.txt` (20 values, token-identical
to the Harbour 3.2 run). The operators never write: the DBF stays
byte-identical to the fixture copy. The `--harbour-rdd` shim build
produces the same stdout (same hrv_arith).

Notes:
- `%` with a zero divisor yields the integer-image 0 (hk343/hk344 +
  test7 oracle; Harbour's recoverable EG_ZERODIV dialog stays the
  registered failure-mode difference).
- `^` edge arms: base < 0 with integral exponent is exact (sign flip on
  odd exponents); fractional exponent of a negative base is NaN; 0^0=1,
  0^negative = +Inf. NaN/Inf print as asterisks like the static path
  (t809). Doubles >= 2^53 are always integral; parity is undecidable
  there and treated even (same as the published static helper).
- Runtime implementation: fmod via x87 FPREM and pow via the hrm_powf
  core (2^(y*log2 x): FYL2X/F2XM1/FSCALE) in freestanding C inline asm
  (no libm), shared by both adapters through hrv_arith.
- Related D5 fix (no DBF): cg_f64_operand now extracts the Dyn PAYLOAD
  before cvtsi2sd - it used to read the casilla TAG as the value
  (`local x` / `x := 100` / `? x ^ 2` printed 81.00 instead of
  10000.00). Regression: tests/t1679_mod_pow_dyn_assign.prg.

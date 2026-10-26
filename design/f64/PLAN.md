# F64 phase-1 implementation plan (63x) - oracles hk278-hk284 published
HEAD at plan: c356899d010e6ef23cddd2bdff317371c9ba928c (720+ABI green, sweep 4/175)

## Frontier (named rejection, compile-time): float literal rejected unless
## |x| < 1e15 AND written decimals <= 17. Reason: star-overflow rule unmeasured
## (hk284: ~1e16 -> 18 stars; 1.23e16 prints). No NaN/inf claims.

## Lexer: in digit scanning, if digits followed by '.' and digit -> Float.
##   '.': if followed by digit -> Float (starts with 0.). Hex: '0' 'x' hexdigits -> Int.
## Tok::Float(f64, u8 decs)  (decs = digits after dot as written)
## Expr::FloatLit(f64, u8) ; Ty::F64 (Copy, no ownership)
## Local layout: TWO slots: [f64 value][u64 dec-count] (document in frame code).

## Print helper hbc_print_f64 (NEW, both blobs; %xmm0=value, %rdi=dec_count):
##  1. if x==0 (incl -0.0: cmpxchg/ucomisd + sign bit drop; oracle hk282 -0.0->"0.0"): int="0"
##  2. ax=|x|; find e = decimal exponent via unrolled pow10 compares (table 1e0..1e14)
##  3. N = (i64)(ax * 10^(15-e) + 0.5)  [16 sig digits, fits i64 given frontier]
##     if N == 10^16 { N /= 10; e += 1 }   (carry)
##  4. digits of N (16, strip leading zeros conceptually via e)
##     integer digits = e+1 (>=1 given frontier); fraction = remaining digits,
##     right-pad/truncate-round to dec_count:
##     - avail = 15 - e fraction digits from N; if dec_count <= avail: round half-up
##       at cut with carry propagation (can cascade into integer part)
##     - else pad zeros
##  5. field width = 11 + dec_count; right-align spaces; grows if longer
##  6. sign: '-' prefix if negative (except -0.0 handled in 1)
##  Calls existing write(1) primitive like hbc_print_i64 does. NO newline.
##  Caller contract: like hbc_print_sep/nl - volatile regs only, leaf except write.

## Codegen `?`/`??`: F64 item -> movsd local->xmm0, mov dec->rdi, call hbc_print_f64
##   (item pair protocol: check how Print arm passes items - it pushes {tag?,...}
##    pairs; F64 needs its own arm in the item loop, NOT the Dyn path)

## Named rejections (compile-time) until justified: F64 in +,-,*,/,%, comparisons,
##   conditions, array cells/literals, parameters, returns, := reassignment mismatch,
##   Dyn tags. Each "float <context> is not in this increment".

## Tests: t725-t72x from hk278/hk281/hk282/hk283 byte-exact + neg tests for each
##   rejection + canary: caller/callee XMM preservation (surround call with xmm6-15
##   known values? note: SysV xmm ALL caller-saved; Win xmm6-15 callee-saved ->
##   helper must not touch xmm6-15 on Windows path), stack alignment at call.
##   nums.prg completion gate: byte-exact vs oracle incl hex + full battery + sweep.

## Phase-2 (NOT yet): arithmetic +,-,*,/ with metadata rules (+,- max; * sum; /
##   max(sum,2)), int/float promotion (hk279: 1+0.5=1.5, 10/3=3.33 int/int stays 2dec
##   wait 10/3 BOTH ints -> "3.33": int/int division is FLOAT in Harbour! measure
##   integer division semantics before phase 2: 10/3 float but 10%3? and 10//3?)

## UPDATE 13:11 - HELPER CORE PROVEN STANDALONE
/home/sandbox/win/f64/hbc_print_f64.s (190 lines, debug-free) = validated
byte-exact vs ALL hk278-hk284 oracle values (13/13). Uses xmm0-xmm2 only,
r12-r15 push/popped, calls hbc_print_str (same internal contract both blobs).
Numeric labels 1-40 used inside: CHECK collisions vs existing blob labels
before pasting (blob helpers use 1-9/82/90-98; must RENAME to a unique range
like 60-79 when integrating; numeric label refs bind to NEAREST definition).
Driver + full test matrix preserved in /home/sandbox/win/f64/drv.s.
Bugs caught by standalone testing: (1) locals at -8/-16/-24 collided with
push-saved r12/r13/r14 -> locals now at -40/-48/-56, digits -80..-65,
output -144..-81, sub $160; (2) digit-buffer end check was inclusive
(-65) -> exclusive (-64); (3) e<0 fraction offset started at digit 1 -> 0.

## Remaining for 63x: lexer float/hex; Tok::Float(String,u8);
## Expr::Float(String,u8); Ty::F64(u8 decs) Copy; named rejections in every
## other context; Print arm F64 (push dec; push bits -> movsd/mov to
## xmm0/rdi, call); append helper to BOTH blobs (rename labels!);
## canaries (Win xmm6-15 untouched - helper uses xmm0-2 only; stack align;
## callee-saved); t725+ from hk278/281/282/283 + frontier negs; nums.prg
## byte-exact; battery+sweep; publish small.

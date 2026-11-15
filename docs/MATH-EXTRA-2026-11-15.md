# Sqrt, Exp, Log and Mod

Base: ca12e3d. Four numeric builtins on the existing F64 pair convention
(value in xmm0, packed length/decimals in rdi).

## Semantics (pinned against real Harbour 3.2.0, r2607071000)

| call | result | rendered |
|---|---|---|
| Sqrt(2) | 1.414213562... | 1.41 |
| Sqrt(-1) | 0 | 0.00 |
| Exp(1) | 2.718281828... | 2.72 |
| Log(10) | 2.302585093... | 2.30 |
| Log(0), Log(-1) | non-finite | 23 stars |
| Mod(10.5, 3) | 1.5 | 1.50 |
| Mod(10.5, 0) | 10.5 (dividend unchanged) | 10.5 |

All finite results carry SET DECIMALS = 2. Sqrt of a negative value and of
zero answers 0 with dec 2. Log of zero or a negative value produces the
Harbour star field of 23 characters (length 20 plus one separator and two
decimals). Mod with a zero divisor returns the dividend with its own
metadata, unlike the native `%` operator (which answers 0); this was
measured, not assumed.

## Implementation

The helpers live in the always-present F64 runtime blob. Sqrt uses the
x87 fyl2x/f2xm1/fscale square-root identity (the assembler has no sqrtsd
or fsqrt form); Exp uses 2^(x*log2(e)) through the same core; Log uses
y*log2(x) with the rodata ln(2) constant; Mod uses fprem with the
dividend/divisor order matched to Harbour and the zero-divisor early
return. Arguments are evaluated once, borrow their values, and flow
through cg_f64_operand, so integers convert like every other numeric
position.

## Verified

Real Windows PE instrumented: the oracle matrix above matches byte for
byte, including the stars field and the zero-divisor case. The new
fixture tests/math-extra/mathfns.prg is in tests/manifest.txt and passes
the runner comparison. No full battery is claimed by this unit.

## Limits

No Sign/Sin/Cos/Tan (the shipped Harbour static libraries do not export
those symbols, so no oracle pin was possible; they stay open), no Dyn
arguments, no domain-error dialogs, no locale-specific formatting. Only
the SET(2) decimal convention is implemented.

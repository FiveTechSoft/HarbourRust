# Bounded standard Set date-format masks

Own MIT incremental on3496ad4cd6abe4f09befbb695a17b68d19cae1c7.
No workflows,push or publication. Behavior measured against fresh Harbour.

Set(4) returns an owned snapshot of the current mask. A literal mask
matching one of the7existing layouts with2or4year digits changes state
and returns the prior owned snapshot. Mask case is preserved. The year
width sets the century flag. SET DATE changes the mask to lowercase;
a change of SET CENTURY width rewrites uppercase. Repeating the same
century flag leaves mask spelling intact. DToC and CToD share layout.
No global heap allocation: the bounded mask lives in an11byte buffer.
Getter allocates an independent string using the existing owner ABI.

NIL is deliberately rejected: fresh Harbour Set(4,NIL) empties the mask,
not an epoch-like no-op. Empty,nonstandard,runtime/numeric masks and extra
arguments also stay rejected. Public selector macro DATEFORMAT is not
introduced yet; literal4only. Arbitrary field width/repetition semantics
need separate measurement,so dates2.prg is NOT closed.

Gate42:4fixtures5modes exact,4strict balances0,12profile rejections,
6limits. Covers all14standard masks,empty dates,mixed-case mask,century
changes,SET DATE,302owned prior-mask stores and CToD order. The old epoch
selector4negative is explicitly promoted to an exact positive fixture,
not blindly changed expectation. Epoch gate now41with that addition.

ASort1..21,timestamp1..9,B1/B2,A1/A2,cycle59,nested51,century22,epoch41,
inlineDate17,Rust104 PASS. Linux1176exact+1inherited ctod,neg622/13same,
PE1912PASS22known0FAIL,census48/1041. Seven rejection diagnostics change;
no new original passes. Original dates.prg still needs a runtime mask
and unsupported formats,so no original or speed claim is made.

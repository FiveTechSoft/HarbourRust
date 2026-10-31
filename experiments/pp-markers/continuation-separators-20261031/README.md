# Exactly one continuation marker

Own MIT reader correction, pinned Harbour behavioral oracle. The previous
reader popped once before trimming and then popped a second semicolon. Thus
`;;` at physical end lost both semicolons, but `;; ` with trailing whitespace
lost only one. Harbour consumes exactly the final continuation semicolon;
earlier semicolons remain result statement separators. Trim whitespace first,
then pop exactly one marker. No macro, command priority or helper changes.

Five baseline counterexamples,72 own matrix cases including spaces,tabs,line
and block comments,quoted semicolon content. Token comparison normalizes
statement separators to newlines,never quoted semicolons. Six runtime sources
match full Harbour/default/LLVM Linux exit/stdout/stderr exactly. Local full
battery1314 PASS=1309manifest+5auxiliary;LLVM646 PASS.29,941 historical sources
have zero pp deltas (they do not include the new missing boundary cases).

268x4 original audit changes20 rows. Every change is only an output-line number
in the same lexer diagnostic:preserving separators adds the missing output
lines. No phase or error-kind changes,no accepted-original count changes.
Counts21/15Linux20/14Windows.14 unchanged reviewed originals remain exact with
fresh Harbour/default/LLVM Linux. In classch,the CLASS_NAME macro no longer
absorbs a following #undef,but METHOD helpers and other output remain wrong.
This is neither whole-header correctness nor class/original execution support.
No main,runtime/ABI/ownership,debugger or speed/byte measurements change.
Independent remote validation remains required before closeout.

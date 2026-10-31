# Call-form translation before command matching

Own MIT implementation,pinned Harbour behavioral oracle. Existing balanced
call-form translations now expand before each command matching/rescan step,
after generated-directive dispatch. Their results re-enter the same ordered
statement queue. Factory bodies remain literal until registration. Existing
call recursion limit16,command depth16,queue10000,and1MiBoutput checks apply;
early-call loop also consumes shared rescan budget. Global priority unchanged.
Non-call translations and identifier concatenation remain separate work.

Tenfocusedprobes:8call forms match,2noncallJOINgaps remain.72-case matrix:
68matches,4preexistinggaps,0newwrong.8controls:7token/recursionmatches including
macro/command cycles,temporalDEFINE/UNDEF,factory body protection,nestedcalls;
1existing escape-string literal normalization difference,not a pass. Quoted
semicolons remain literal;statement separators normalize to newlines only.
30013historicalsources show1delta:WRAP now completes both generated commands.

Six own runtime programs exact full Harbour/default/LLVM Linux. Local full
1325PASSdefault=1320manifest+5aux,666LLVM.14unchangedreviewedoriginals exact.
268x4audit changes11rows,only output-line number of same lexer diagnostic;
accepted21/15Linux20/14Windows unchanged. No original unlock,wholeclassheader,
classruntime,ABI/ownership,main,debugger or speed/byte claim. Remote pending.

Independentremote688b580fullgates1325/666,14originalsexact,268x4with11line-only
changesverified. No original acceptance growth.

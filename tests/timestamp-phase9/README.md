# Timestamp phase 9: flat reset and scalar FOR EACH call boundary

Own MIT on 8b4fe905bcd58c250681eab941dc5b96eb62d525.
Julio Ponce's MIT e16 and Harbour 3.2.1 outputs are specifications only.
No implementation or diff copied. No workflows, push or publication.

Ordinary Linux timestamp programs with classes can reset an established
flat tagged array with literal {}. The slot keeps its flat element family.
Existing codegen builds the new value first, then releases the old cells,
including owned tag4 strings. This does not enable assignment from an
unknown-family array variable or repin the slot to a different family.

FOR EACH over that flat family can pass the exact borrowed loop variable
to a checked ordinary user function's by-value Dyn parameter. Existing call
codegen clones text and float payloads; timestamp and Date are scalar.
The new proof accepts assignment, print and IF bodies only, replacing exact
approved arguments in a private expression copy before checking that no
loop-variable mention remains. No borrowed local storage, @ argument,
non-Dyn parameter, computed loop-variable argument, block capture or root
collection mention is admitted by this proof. The existing collection
mutation check still applies. Existing readonly cases remain unchanged.
No shared-array, container DATA or general iterator-reference semantics.

Measured original e16: fresh Harbour compile, exact stdout/rc0/empty stderr
in native, external assembler, --no-vas-arrays and --no-escape-analysis;
strict final balance exact stdout/rc0/empty stderr and delta0. No e16 source
copy is committed. Supplied programs are used only as specifications.

Own gate57: six own programs x four exact modes (24 executions), six
strict final balances,18 non-Linux profile rejections,nine named limits.
Covers reset of owned text 211 times, timestamp/text/Date/NIL iteration,
113 repeated iterations, returning copied cells, a later-argument throw
after a prior text argument is copied, hash/DATA-to-list, and IF/print.
A float append was rejected during exploration, not counted as a pass.
Direct storage, @, mutation, computed arguments, captures, sibling-root
mutation, non-Dyn parameter, reset-variable and no-timestamp remain limits.
Profile rejections are not PE/Mac runtime tests.

Run from the repository root with a new output directory:

    python tests/timestamp-phase9/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/ts9-check

Regression: phase1 42exact+2streams/14balances; phases2..8
61/51/50/49/41/50/50; B1 152; B2 115; A1/A2; Linux1174; Rust99.
PE emission only:1909PASS,22known,0FAIL. Negatives622 identical to phase8,
including13known mismatches. Raw text logs, compiler SHA, bundle/patch and
manifest accompany the reduced package. No binaries, objects or disposable
assembly. The tracked test programs and implementation are own MIT.

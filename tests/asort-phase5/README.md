# ASort phase5: integer/decimal numeric arrays

Own MIT on59c63f7313d5993d5d4ac6b27fb0b1407a1eb812 (phase4 delivered).
Julio Ponce's MIT a03 and Harbour output are specifications only,no copied
implementation or diff. No workflows,push or publication.

Numeric local literal ASort entry accepts integer and decimal leaves.
A2 literal descriptors admit decimal leaves,including nested decimal
literals once A2 is selected. A private descriptor tag105 holds a pointer
to constant bits/format metadata;build converts it to a fresh owned kind5
item. Runtime cells never keep tag105. Each rebuild owns its float items;
existing cell release and collector free them. Module STATIC initializer
admission stays unchanged;local A2 literal rebuild accepts these leaves.

Shared ASort validation treats integer/float as one numeric family and
uses existing numeric Dyn comparison when either operand is decimal.
Text sorting stays separate;arbitrary mixed kinds remain rejected before
cells move. No callback or comparison-sequence claim. Ordinary shared
float assignment retains its existing clone/ownership behavior.

Gate40:four own+a03,five sources x4Linux modes=20exact,five strict balances,
15non-Linux rejections. Includes numeric formatting,negative/folded values,
rebuilds,317overwrites,received aliases and157exceptions. Former phase1
limit-float is now executed against Harbour rather than silently dropped;
phase1 gate74 replaces gate67. Missing DELTA alone never means success:
strict balance requires exact stdout,rc0,empty stderr.

    python tests/asort-phase5/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort5-check

Regressions on phase4-based compiler:ASort1=74,2=51,3=32,4=37,timestamp1..9,
B1/B2,A1/A2,cycle59,nested51,Rust99. Linux1176exact+inherited ctod failure;
negatives622 including13known unchanged;PE emission1912PASS22known0FAIL.
Census48/1041 unchanged. The same gates were additionally run on a temporary
main305eaf39-integrated branch with phase3/4 reapplied;those results use a
different compiler SHA and are separated in evidence. This delivery remains
incremental on phase4 as requested,no cumulative3+4 patch.
No Windows/Mac runtime claim. Mixed kinds,callbacks,rows,e18..20 remain open.
Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence,
no binaries,objects or disposable assembly.

# ASort phase16: read-only sum in callback comparison

Own MIT onb287efbec651aece4fd5c0deae4d1d98c3bbf9d0 (corrected phase15).
Julio Ponce's MIT e20 arithmetic callback shape and fresh Harbour behavior
are specifications only,no copied implementation or cambio.diff.
No workflows,push or publication. e20 as a whole is NOT closed.

The safe callback expression proof admits plus of previously admitted
read-only operands. Ordinary type checking/lowering decides arithmetic,
string concat or runtime type error. No callback writes/general calls.
No runtime helper changes. The existing owned-snapshot arithmetic route
cleans temporary operands before propagating the type error.

Gate18:2own,10executions across5Linux modes(including --no-prune),2strict
final balances,6profile rejections. Numeric fixture runs101sorts. Type-error
fixture recovers113times,preserves elements,and sorts successfully after.
For that fixture ONLY,the Harbour harness appends INIT that installs
ErrorBlock({|err|Break(err)}). Without it standard Harbour opens an error
dialog rather than recovering. The tested fixture and stdout are unchanged;
this harness difference is explicit,not a claim of equal default handlers.
The emitted oracle harness and raw logs are included. DELTA0 requires exact
stdout,rc0,empty stderr and an actual measured marker.

ASort1..15 pass. Timestamp1..9,B1/B2,A1/A2,cycle59,nested51,Rust99 pass.
Linux1176exact plus identical inherited ctod_order_epoch failure;negatives
622 retain13known mismatches unchanged. PE emission1912PASS22known0FAIL,
no PE runtime claim. Censo48/1041 unchanged. c02,e20 remain open. Standard
Harbour rejects e20's TRY/CATCH spelling and does not provide its custom
hb_memcheck. Original e20 also retains a prior nested-counter rejection
under corrected phase15 because its prefix contains a fresh array build.
No raw-original differential or memory-assertion claim for e20.

    python tests/asort-phase16/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort16-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

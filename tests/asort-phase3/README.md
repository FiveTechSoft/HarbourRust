# ASort phase3: received shared array

Own MIT on02d43e9af1a65e011d87f2f1ea2bd149dac4a3ac (phase2 delivered).
Julio Ponce's MIT a10 and Harbour output are specifications only,no copied
implementation or diff. No workflows,push or publication.

A constant local literal passed directly to a function whose corresponding
parameter receives direct ASort with up to3arguments selects existing A2.
Existing shared parameter propagation keeps caller identity;sort changes
are visible to caller and aliases. No callback or general array inference.
The trigger is syntactic/conservative. Existing A2 restrictions remain.

Gate32:three own+a10,four sources x4Linux modes=16 exact executions,four
strict final balances,12 non-Linux rejections. Includes integer/text received
arrays,alias writes,157repeated calls,157exceptions in start evaluation.
Strict balance means exact stdout,rc0,empty stderr,not missing DELTA alone.

    python tests/asort-phase3/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort3-check

Regressions:ASort1=67,ASort2=51,timestamp1..9,B1=152,B2=115,A1/A2,cycle59,
nested51,Rust99. Linux1176exact+inherited ctod_order_epoch failure unchanged;
negatives622 including13known unchanged;PE emission1912PASS22known0FAIL.
Census48/1041 unchanged. No Windows/Mac runtime claim. Mixed,float,callback,
row sorting and broad e18..20 remain open. Reduced bundle/patch,LEEME,
attribution,manifest,compilerSHA,raw logs,no binary/object/disposable asm.

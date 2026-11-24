# Mandatory intact input/control examples

Own MIT test-only increment on5eb41a6b674eebec82bc35b30a056cd689f09e14.
No compiler, workflow, push, publication or policy change. Upstream
original programs remain specifications, never substitute implementations.
Julio Ponce's MIT ASort examples remain credited independent specifications;
no cambio.diff or supplied implementation is used.

Three mandatory unedited upstream examples:base2.prg,for2.prg,longstr.prg.
base2 gets one newline byte;for2 gets two;longstr gets empty stdin.
The exact stdin bytes are recorded as stdin.bin,not a compiled binary.
All build subprocesses get empty input;no inherited terminal can hang a
review unattended. 30second timeout is failure,never successful coverage.
longstr uses the actual upstream simpleio.ch through the supplied include
search path. That source stays outside the repository;its hash is saved.
No source edits,removed WAIT/Inkey or synthetic Main are used.

15 exact original executions =three originals in five Linux modes.
Normal runs require rc0,exact Harbour stdout and empty stderr. Three
strict final zero balances use an unconditional final DELTA=0 marker
and deliberate rc99,exact stdout and no other stderr. Missing marker
cannot masquerade as success. Sources and their hashes are retained in
review evidence. A missing original/include causes rc2,never a skipped
optional test.

This is reproducible evidence for already admitted programs,not newly
implemented syntax or three new closures. It resolves the earlier audit
limitations:base2 waited for input,and longstr lacked an include path.
Those earlier incomplete observations are not retroactively called PASS.
No speed or Windows/Mac runtime claim. Compiler unchanged SHA256
 eb36afb9bc6529e7ddec61bcfc839c3c9267485150891965c86014ce8a3d9c70.
Broad compiler regression was not rerun for this test-only gate.
Known object-lifetime debt in the separate calls gate is unchanged.

    python tests/original-input-control/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/input-control

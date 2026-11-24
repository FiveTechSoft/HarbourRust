# Correct Linux CToD golden provenance

Own MIT evidence-only increment on659e59a018fd8ec8d33ffee0eb6361f974a1d838.
No compiler change. No workflows, push or publication.

The inherited Linux manifest mismatch was an outdated expected-output
file. A fresh Harbour3.2.1dev r2610242111 GTSTD run of the existing
ctod_order_epoch.prg emits the same12 additional line breaks as the
current compiler. Long lines wrap at the same columns. Every date/epoch
value matches too. The Linux golden is replaced with that exact fresh
stdout. The Windows golden is deliberately untouched: this run does not
establish Windows output. No newline normalization or ignored bytes.

Gate6: five modes byte-exact against fresh Harbour; strict balance0.
No cross-target admission or execution assertion. The discovery gate
incorrectly expected Windows rejection and was corrected in a follow-up
commit before delivery; Windows already supports this source.
Entire Linux positive manifest now
1177/1177 byte-exact. Previous1176plus1 mismatch becomes1177 because the
golden is corrected, not because the compiler acquired new semantics.
Compiler SHA stays a1d24f196f0c0a0afc3435ec63b53e96e8b59a5ae8073ca0138b8f51f0601bff.
Census remains51/1041 compile admissions. No speed or Windows execution
claim. Julio Ponce MIT specification attribution from earlier suites is
unchanged; no supplied implementation or cambio.diff was used.

    python tests/ctod-golden-linux/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/ctod-golden

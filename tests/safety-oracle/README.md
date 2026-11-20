# Oracle-positive safety maintenance

Test-only. No compiler or language change. The old Date-local inline and literal
integer hash-key rejections became accepted features, so each original source is
now kept verbatim as a positive comparison in its safety gate. Each also has a
companion that observes the resulting value, and an unsupported neighboring
shape that must still be rejected in both assembly modes. Harbour builds and
runs that neighbor, so the rejection is labeled as a compiler limit.

The 12 and 15 top-level rows stay unchanged. All pre-existing other sources and
checks remain. The upgraded row requires both positives and the neighboring
negative. Every subcheck and raw rc/stdout/stderr is recorded. No skipped tests,
relaxed assertion or hidden total. The numeric-key original prints nothing;
its observable companion distinguishes integer 10 and string "10".

Both safety scripts now require `--hbmk2 /path/to/hbmk2`. The existing scripts
have no in-repository CI caller to update. A missing or failing oracle fails
the gate; it is never treated as a skip.

Run the two gates, then the independent guard test:

    python3 tests/inline-dyn/safety.py --compiler ./hbc --hbmk2 /path/to/hbmk2 --output /new/inline
    python3 tests/hash-strings/safety.py --compiler ./hbc --hbmk2 /path/to/hbmk2 --output /new/hash
    python3 tests/safety-oracle/check_guards.py --compiler ./hbc --hbmk2 /path/to/hbmk2 --output /new/guards

The guard test uses executable proxies, not compiler-source edits. For each
gate, positive build rejection, positive wrong output with rc0, and acceptance
of the unsupported neighbor must cause rc1 with exactly the upgraded row false.
All six runs retain their normal 12/15 rows. Fault outcomes are not Harbour
parity claims or product failures.

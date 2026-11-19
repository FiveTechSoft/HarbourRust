# Native Self and super sends

Original MIT probes. Harbour is an external oracle, not a dependency of the compiler.

Run `python3 tests/self-super/check.py --compiler /absolute/hbc --hbmk2 /absolute/hbmk2 --harbour-core /absolute/harbour-core --output /new/directory`.

The optional external tree adds the unchanged `tests/inhprob.prg`, checked against the pinned inventory SHA256. It is never copied into this test directory or evidence. Each positive is compared against a fresh gtstd oracle on ELF internal assembler, ELF external assembler, and PE via Wine. PE uses the oracle's LF-to-CRLF output. All builds and runs must return zero, stderr must be empty, and stdout must match. Negative builds must reject by name without creating a binary. Timeouts fail closed. This is not native Windows testing.

The probes cover native `::Method()`, `CREATE CLASS ... FROM`, expression INLINE methods, lexical parent method lookup on a three-level hierarchy, parent calls on the same instance, virtual calls from a parent body, DATA writes, nested calls, argument evaluation order, and missing-parent/member/outside-method diagnostics.

Existing limits remain: method argument types need body evidence, shown with numeric `+0`; this is not a new general inference rule. No support is claimed for multiple inheritance, late parent declarations, VAR/list declarations, super DATA access, statement INLINE bodies, or #require libraries. No Harbour source or translated implementation is included.

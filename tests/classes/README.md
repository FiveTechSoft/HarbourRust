# Class suite (`tests/classes/`)

Public evidence for the classes-and-objects increment landed in v0.7.0
(main `63d81a9`). Same-source differential gate against real Harbour,
in the style of `tests/dbf`, `tests/ntx` and `tests/cdx`.

Run it (Linux x86-64, needs GNU binutils and a real Harbour `hbmk2`):

    python3 tests/classes/check_oracle.py \
        --compiler ./hbc \
        --hbmk2 /path/to/real/harbour/bin/hbmk2

Expected result: `classes gate: 42/42 pass (26 differential, 3 declared
limits, 13 named negatives)`, exit status 0. Per-probe evidence (both
build logs, both run outputs) is written to the evidence directory the
gate prints.

## What each set proves

- **26 differential probes** (`programs/`): compiled by real Harbour
  (reference `694428e1`) and by HarbourRust from the same `.prg`; both
  executables run; stdout and stderr must match byte for byte. They
  cover construction and `INIT` (lazy, once, child-first), DATA defaults
  and read/write, method calls and returns, method-wins-over-DATA,
  single inheritance of DATA and methods, virtual override dispatch,
  lax-arity NIL padding, sharing by assignment and by parameter, object
  identity `==`, `? o` printing, zero-DATA classes and a 2,000-cycle
  freelist stress.
- **3 declared-limit probes**: valid Harbour programs that Harbour runs
  and HarbourRust rejects at compile time with a named error:
  - `p03_readwrite`, `p07_self_chain`: compound assignment `+=` is
    outside the supported expression subset.
  - `p21_multi_inherit`: multiple inheritance is a named compile-time
    rejection; this increment supports single inheritance only.
- **13 named negatives** (`neg1`..`neg14_ambig_member`, except `neg4`,
  which is a runnable probe): invalid or out-of-subset programs that
  HarbourRust must reject with a named compile-time error, never a
  panic. They cover unknown members, wrong receiver pinning, ambiguous
  members across two hierarchies, object/array DATA, and other
  out-of-scope shapes.

See [docs/CLASSES.md](../../docs/CLASSES.md) for the supported scope,
the object model, and the full declared-limit list.

## Mach-O Intel battery (`check_macho.sh`)

Run on a real Mac with Python 3 installed:

    sh tests/classes/check_macho.sh /absolute/path/to/current/hbc

Build hbc from the current checkout first. The tracked Mac binary may
predate the shared string-copy fix. An ARM64 hbc runs natively on Apple
Silicon, but its emitted x86-64 programs require Rosetta 2. An Intel Mac
needs an Intel build of hbc. This is not native ARM64 code generation.

The runner compiles the 26 runnable class probes with `--target=macho`
and checks exit status, empty stderr and exact stdout against `expected/`.
These files are Linux baseline captures from the post-fix compiler at
`f31d99dccabd020c654d15a6bda22041454153d1`, not a fresh Harbour oracle run.
They test Linux-equivalent LF and QOut trailing-space semantics. The
other 16 cases must produce their recorded named compile rejection,
not an unrelated target error. `p03_readwrite` and `p07_self_chain` currently use a generic syntax rejection. Compilation and execution have timeouts;
logs, return codes, compiler/source hashes and machine details remain
in the printed evidence directory.

Real-Mac execution and a fresh differential run against Harbour are
PENDING. On Linux, the 26 runnable probes emitted Mach-O x86-64 and
the other 16 produced named rejections. This is emission evidence,
not proof of loading or execution on a Mac.

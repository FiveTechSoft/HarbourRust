# Isolated own ARM64 backend experiment

Base: `e5bf1bb640fb4befcd661e65bb75ba501f3c5ab9` (14 November 2026).

This directory is an engineering increment, not native ARM64 support in hbc.
The production compiler, its host default and its ARM64 rejection are unchanged.
No files under `src/` change. No Mac loader, Apple Silicon hardware, actual
Darwin syscall or Apple signing-policy verdict has been tested here.

## What is implemented

- Own Rust instruction encoder and label fixups. Operand APIs reject x18,
  bad registers, invalid immediates, misalignment, pair/writeback overlaps,
  branches to data, duplicate/unresolved labels and relative-address overflow.
- Own Rust SHA256 and an input-validated Mach-O writer accepting code bytes,
  read-only bytes, an entry offset and a signing identifier. It writes ARM64
  PIE, 16 KiB-aligned segments, dyld/libSystem load commands and an ad hoc
  CodeDirectory signature. It has no relocation/import/writable-data API.
  Input bytes are not disassembled or proven safe by the writer.
- An isolated lowering path from the existing checked AST, with its own
  small scalar console runtime. It does not translate x86 instructions.
  The runtime handles short writes, EINTR, no progress and write failures.
- A separate harness generator copies the frontend and generated DBF source
  to the test directory. Only that copy replaces the early ARM rejection
  and adds the experiment after the existing semantic checks. Source SHA256
  is pinned; a different frontend requires deliberate review/rebase.
- Independent development checks use Python hashlib, a second Python writer,
  a standard-library layout/signature verifier, optional macholib, optional
  LLVM encoding references, and Unicorn with an explicit syscall model.
  None is part of hbc or of output generation.

## Deliberate scalar boundary

The harness covers integer/logical literals, locals/copies/assignment,
integer comparisons, logical short-circuiting, IF/WHILE/EXIT/LOOP, scalar
calls with up to eight arguments, discarded nil-only calls, and formatted
output. All output items are evaluated before the QOut newline, as in hbc.
Nonempty literal strings without a trailing space or an embedded CR/LF can
be printed. Local strings are outside this first boundary.

Every function and AST branch is visited, including unreachable code. Missing
families reject without writing a new output file. They include runtime
arithmetic (overflow-to-double and integer provenance are not ported), floating
point, heap/Dyn values, arrays, hashes, objects, by-reference calls, most
builtins, STATIC, TRY/CATCH, FOR, INIT, EXTERNAL, threads, pending-console
spaces/empty strings/multiline strings, assembly output and instrument/LLVM/
external-assembler modes. A frontend-inferred Dyn recursion result also rejects.
Constant arithmetic already folded to an integer by the existing frontend
can pass; this does not mean ARM runtime arithmetic exists.

The harness uses conservative fixed 4080-byte local frames, with a named
frame limit. It is not a production frame allocator. Read-only data references
currently use ADR and reject if its signed relative range is exceeded. The
writer has an explicit 64 MiB payload limit and printable-ASCII identifier
limit of 255 bytes. These are experiment limits, not new production limits.

## Run the checks

Use stable Rust and Python 3. Copy this directory outside the checkout first:

```sh
work="$(mktemp -d)"
cp -R experiments/arm64-native/. "$work/"
python3 -m venv "$work/venv"
"$work/venv/bin/pip" install -r "$work/requirements-dev.txt"
"$work/venv/bin/python" "$work/run-checks.py" --repo "$PWD"
```

`RUSTC` can select the stable compiler. Optional `LLVM_SHARED_LIBRARY` points
to a development LLVM shared library exposing its C API; when set, the runner
also compares 20 instruction encodings byte for byte. LLVM is an oracle only.
`--without-emulator` runs the own writer/signature/unit checks without the
optional Python packages or either full frontend build. The scalar experiment
binary is named `hbc-arm64-research`, never the production `hbc`.

The runner leaves its generated sources, executables and JSON records in the
copied directory. It does not modify the checkout. The production compiler is
also built there as `hbc-baseline` to verify its ARM rejection and to provide
the current Linux stdout oracle. Run the differential emulator battery on a
Linux x86-64 host: the reference outputs are executed there, not on a Mac.

## What the evidence means

The attached review evidence records the exact counts and hashes. Passing
checks mean the measured encodings, emulated computations and mathematical
signature/layout checks agree with their named references. A Linux stdout
comparison is not an independent Harbour VM compatibility claim. A syscall
model is not the Darwin kernel. An emulator is not Apple Silicon. Recognized
Mach-O headers and valid page hashes do not prove dyld accepts or runs an image,
or that Apple's security tools accept it.

Before enabling any native ARM entry point, continue the missing runtime and
language work, review the supported boundary, and test real Mac loading and
execution. No new ARM source program is admitted by production hbc in this
increment. STATIC remains the next separate project priority after ARM work.

## Primary design references

These supply ABI/layout facts, not copied implementation code:

- https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms
- https://developer.apple.com/documentation/macos-release-notes/macos-big-sur-11_0_1-universal-apps-release-notes
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/EXTERNAL_HEADERS/mach-o/loader.h
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/osfmk/kern/cs_blobs.h
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/bsd/dev/arm/systemcalls.c
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/bsd/kern/mach_loader.c

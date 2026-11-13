# Native hbc adapter for external hbmk2

First bounded milestone: Linux x86-64, one Harbour source per executable, plus
optional freestanding C extensions or object files. This is an independently
written MIT frontend, not a port, translation or replacement of hbmk2. The
official Harbour hbmk2 stays an external user-installed tool with its own license.

## Requirements

- Python 3, a current source-built HarbourRust `hbc`, GNU `as` and GNU binutils.
- An installed official hbmk2 and the GCC driver/toolchain it uses to link.
- GCC for C extensions and the scalar Extend bridge.

Unlike the direct native-only `hbc`/`as`/`ld` path, this hbmk2 route uses a C
compiler driver even when the Harbour program has no C extension. The older
v0.1.1 binaries do not include the source compiler's Extend bridge support.

## Build

From the repository root, with external `hbmk2` on PATH:

```sh
rustc --edition=2021 -O src/hbc.rs -o hbc
python3 tools/hbc_hbmk2.py tests/samples/hello.hb -o hello-native
./hello-native

python3 tools/hbc_hbmk2.py extend/demo/extdemo.hb extend/demo/myext.c \
  --work-dir demo-build -o demo-native
./demo-native
```

`--hbc`, `--hbmk2`, `--assembler` and `--cc` select executable paths.
`-I path` adds an include directory. The Harbour source directory is also searched
for sibling includes. `--instrument` enables hbc's instrumented output.

C inputs automatically include the milestone-1 bridge. For a precompiled C
extension object, add `--bridge` explicitly:

```sh
gcc -c -O2 -ffreestanding -fno-stack-protector -Iextend \
  extend/demo/myext.c -o myext.o
python3 tools/hbc_hbmk2.py extend/demo/extdemo.hb myext.o --bridge -o demo-native
```

The output parent directory must exist. `--work-dir` must name a new directory;
its assembly, objects, generated `native.hbp`, command arguments and per-stage
stdout/stderr are retained for inspection, including after failure. Without this
option the temporary build directory is removed. A failed build does not replace
an existing output executable. A successful build replaces it atomically.

## What the adapter does

1. Invoke hbc explicitly on the one `.hb`/`.prg` source, targeting Linux.
2. Assemble its output with GNU `as`; compile optional C with freestanding flags
   and the project's own `extend/hbhbr.h`. Build `hbhbr.c` if needed.
3. Give official hbmk2 a generated `.hbp` containing only native object filenames
   and `-nohblib`, `-nostdlib`, `-no-pie`, `_start` link settings.
4. Check that the link produced an executable 64-bit ELF file before installing
   the output. The adapter does not execute user programs during a normal build.

A Harbour `.hb` is never passed to hbmk2 as its first argument: that mode executes
a Harbour script and can fake a successful native build. Commands use argument
lists, not shell interpolation. User paths do not enter the generated project:
its object filenames are generated internally. Keep `--work-dir` to inspect the
real hbc, assembler and hbmk2 evidence.

## Explicit limits

- One Harbour module. Multiple hbc objects currently duplicate `_start` and native
  helpers; accepting several PRGs needs a separate module/runtime model.
- Linux x86-64 hosts and output only. This is not a Windows adapter.
- Only `.hb`, `.prg`, `.c` and `.o` inputs. Existing `.hbp`/`.hbc` projects, hbmk2
  options/plugins, resources, incremental builds and arbitrary libraries are not
  imported. The frontend has its own CLI, not full hbmk2 command-line compatibility.
- C must fit the [milestone-1 bridge](EXTEND-BRIDGE.md). Arbitrary Harbour C
  libraries, libc-dependent extensions, arrays, byref and callbacks are not
  made compatible by this tool. C is not made memory-safe by the adapter.
- A build frontend does not add unsupported Harbour syntax. The goal remains all
  1,041 upstream originals; this milestone does not claim that goal is met.

## Acceptance evidence

The focused real-toolchain check can be run with:

```sh
python3 tools/check_hbmk2_adapter.py --hbmk2 /path/to/official/hbmk2 \
  --hbc ./hbc --output-dir adapter-check
```

Verified on 13 November 2026 against official Harbour
`694428e1c12f726675b19324d62167fa77d68185` and HarbourRust source
`b36537521f6c54fbc0da72162eda16952cd5531b`:

- Greeting, array/hash and date fixtures: exact stdout/stderr/exit against the
  independently linked direct-native path; ELF with no dynamic section and a
  real native-object hbmk2 link trace.
- Scalar C demo through both C-source and precompiled-object routes: exact output
  against the previously verified official-Harbour oracle fixture.
- Paths containing spaces/apostrophes and a sibling include.
- Poison hbc, missing assembly, failed assembler, fake hbmk2 without an output,
  unsupported multi-module/input, missing tool, input overwrite and existing
  work-directory controls: fail closed and preserve prior output.
- All 31 previously compiler-admitted upstream originals build through the
  adapter. These are 31 of 1,041 inventoried PRGs (31 of 268 under `tests/`), not
  1,041 passing examples or 31 new behavior matches. That build-only sweep did
  not rerun interactive/error-dialogue originals.

See the [official hbmk2 manual](https://github.com/harbour/core/blob/master/utils/hbmk2/doc/hbmk2.en.md)
for the external tool's own interface. Its generated manual is older than the
pinned executable's help; the tested command traces are the acceptance evidence
for this bounded flow.

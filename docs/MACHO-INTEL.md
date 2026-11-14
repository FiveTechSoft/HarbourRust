# Experimental Intel Mach-O, 14 November 2026

Review increment after the separate Linux/Windows host-default patch, based on
`947e7d1831e9870d610074db5b938db5c89bfee7`. No publication is part of this work.

## What is implemented

`--target=macho` selects an experimental x86-64 Mach-O executable. A compiler
built for macOS Intel selects it by default. Explicit Linux/Windows targets
retain their x86-64 writers. The compiler itself is ordinary stable Rust;
there are no new Cargo dependencies. Build instructions and a native test
runner are provided for the owner's first Mac Intel hardware run.

The existing own x86-64 assembler resolves the code and data addresses into
an internal ELF image. The new own Mach-O writer reads its load ranges and
writes a different container, preserving virtual addresses but assigning new
page-aligned file positions. It does not invoke Apple's linker, copy Harbour
runtime code, or rename an ELF file. This keeps the existing ELF/PE layout and
instruction encoders unchanged.

The image has `MH_MAGIC_64`, x86_64/all, `MH_EXECUTE`, `MH_NOUNDEFS`, a zero-page
mapping, RX `__TEXT`, optional read-only `__CONST`, and optional RW `__DATA`.
There is no writable executable segment. BSS is zero-fill after file-backed
data. `LC_UNIXTHREAD` carries `x86_THREAD_STATE64` (flavor 4, count 42) and the
validated instruction entry. The Intel static path needs no dyld/libc import.
The first page contains the Mach-O header, not the internal ELF header.

Darwin lowering changes only recognized write/exit/mmap/munmap boundaries.
Numbers become Darwin Unix-class operations, anonymous mapping flags become
`MAP_PRIVATE|MAP_ANON` (0x1002), carry-set errors become negative values for
existing runtime consumers, and rdx is preserved because Darwin may use it
as a second return register. Mmap also preserves r10. A syscall that cannot
be classified, or is not one of those four operations, rejects at compile
time; Linux numbers are never silently emitted to the Mac kernel.

The Linux-specific VAS and arena optimizations are disabled on this target.
Their Linux auxv/startup-stack/environment assumptions are not reused. Ordinary
allocation/free remains active, including the actual allocation registry when
instrumented. No VAS/arena memory or performance benefit is claimed on Mac.
DBF, threads, EXTERNAL and classes reject; CurDir and Date() today are not
ported. Pure existing date conversion is a different path, not a claim that
Darwin local date/time support exists. LLVM and external-as reject for Mach-O.
The .s output is internal GNU-style assembly, not claimed Apple-as input.

## Checks performed, and what they do not establish

Final measured Linux compiler SHA256:
`41dd83953eac072db8f946d565254d88ed27d35b79217ad03465f9348e82d8e5`.

- Three Rust unit tests pass: segment-layout variants, malformed-image
  rejection, and allowed/unknown syscall lowering. Layout variants include
  no data, read-only data, writable data, BSS and alignment boundaries.
- Complete instrumented compile-only audit of the unchanged 1720-entry
  manifest: 1120 emitted images pass structural checks and the independent
  macholib 1.16.4 parser; 567 existing negative diagnostics match. The remaining
  33 rejections are not passes: one class gate, 12 Date() cases and 20 CurDir
  or CurDir-diagnostic-precedence cases. Nine of those 33 are old negative
  rows whose expected diagnostic is not reached. No negative row is silently
  admitted. This is not 1687 runtime passes or broader compatibility.
- `file` independently recognizes the generated sample as Mach-O 64-bit x86_64.
  The structural checker verifies command sizes, CPU/type, segment bounds,
  page alignment, protections, no overlapping VM ranges and entry placement.
- A separate Linux-only ptrace experiment runs the Darwin-lowered instructions
  in an ELF container and translates the four syscalls back to Linux, forcing
  rdx to zero on return. The 38-source smoke in normal/instrumented modes gives
  76/76 expected results, including actual candidate registry zeros. This checks
  the lowering and runtime paths only. It does not load Mach-O or execute the
  Darwin kernel and must never be reported as a Mac hardware result.
- The new native runner passes the five manifest kinds on Linux and 38/38 of
  the selected smoke with the final compiler's Linux override. It uses Rust
  process deadlines, so Mac needs no GNU timeout or assembler. Existing
  streams/pos2 are exact bytes; legacy pos/posx trim final LF as before.
  Every raw compile/run stream is retained in a fresh run directory.

No Mac hardware execution, native Mac compiler build, or native Harbour/Darwin
oracle run was possible here. The full Linux/Wine runtime manifest was not
repeated for this increment. ELF/PE generation functions are unchanged, and the
Mac-only optimization gates are false on those targets, but that is not an
all-platform runtime result. Real loading, system-call behavior, OS security
policy and the Mac toolchain remain the owner's next hardware check.

## ARM64 is still an open phase

Native ARM64 is not implemented in this increment, not merely implemented and
untested. `--target=macho-arm64` and the macOS ARM64 default reject clearly.
Changing the Mach-O CPU header cannot translate x86-64 instructions. Apple's
production loader also rejects the simple static path on non-x86_64 targets;
ARM64 needs an actual instruction backend and a suitable loader/signing path.
No Intel-via-Rosetta result is called native ARM64. The build docs distinguish
compiler-build preparation from the missing native code backend.

## Build and first hardware check

Use the numbered steps in BUILDING.md. On Mac Intel:

```sh
sh scripts/build_macos.sh
./hbc tests/samples/hello.prg hello
file hello
./hello
./run_native_manifest --manifest tests/macos-smoke.txt --output gen/mac-intel-smoke
```

Only after recording that machine's streams/status can the corresponding cases
be called Mac passes. The full manifest can be used diagnostically afterward;
unsupported cases count as failures, not skips. Compiler and program deadlines
are 30 and 15 seconds. The smoke preserves 38 existing source/expectation rows.
No old expected bytes or original PRGs are rewritten.

## Primary format/OS sources

These define public format facts, not evidence of our hardware execution.
No Apple implementation was copied into the writer.

- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/EXTERNAL_HEADERS/mach-o/loader.h
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/osfmk/mach/i386/thread_status.h
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/osfmk/mach/i386/_structs.h
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/bsd/kern/mach_loader.c
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/bsd/kern/syscalls.master
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/bsd/sys/mman.h

README's original-program marker is also reconciled with the baseline's opening
record: 32/1041, all 32 under tests/268, 30 exact Linux instrumented runs plus
two blocked dialogues. This does not mean 32 compatible programs or Mac passes.

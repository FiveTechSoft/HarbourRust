# Building hbc

`hbc` is a Rust program with no dependencies beyond the standard library.
The entry point is `src/hbc.rs`; `rustc` resolves its modules (`pp.rs`,
`hasm.rs`, `hpe.rs`, `vas.rs`, `llvm_scalar.rs`) and the runtime blobs
included with `include_str!` (`hrobj_blob.s`, `hrobj_blob_mt.s`,
`generated/hrdbf_linux.s` and the VAS `.s` variants under `src/`).
Everything below was tested with the versions noted; newer versions will
usually work, but these are the verified ones.

## Use the tracked Windows compiler without a toolchain

`bin/hbc.exe` is the tracked Windows x86-64 compiler snapshot, added in
`8299ee4` from source `e17223f`, not the historical v0.1.1 download.
Using it for supported native-only programs requires no Rust, MinGW, C
compiler, external assembler or linker. From the repository root on Windows:

```bat
bin\hbc.exe tests\samples\hello.prg hello.exe
hello.exe
```

The own writers produce ELF (Linux x86-64), PE32+ (Windows x86-64) and
experimental Mach-O (macOS Intel x86-64). Native ARM64 remains rejected.
The exact tracked Windows compiler has Wine 11.0 smoke evidence, not native
Windows verification; Intel Mach-O has no hardware smoke yet. Section 4 pins
the source/hash and scope. This is a main snapshot, not a published v0.9.0
binary. Compiler-build dependencies below are not requirements for using it.
Only the legacy `--external-as`/explicit assembly pipeline needs assembler
and linker tools; its Windows path uses MinGW-w64 binutils/import libraries.
C extensions and the hbmk2 adapter separately need their C toolchain.

## 1. Build the compiler on Linux

Verified with rustc 1.99.1 (stable).

```
rustc --edition=2021 -O src/hbc.rs -o hbc
```

No crates, no network access, no build system. The resulting `hbc` is a
statically linked Linux x86-64 binary.

## 2. Compile a Harbour program to a Linux binary

```
./hbc tests/samples/hello.prg hello --target=linux
./hello
```

`hbc` writes the ELF executable directly (internal mini-assembler and ELF
writer, layout equivalent to `ld -s`). `--external-as` keeps the older
`as` + `ld -s` fallback; those are the standard GNU binutils of the host.

The target defaults to the compiler host: Linux compilers emit ELF and Windows
compilers emit PE32+. `--target=linux|windows` overrides the default for
cross-compilation. A `.exe` suffix does not select Windows; only `.s` changes
the output kind to assembly. Rebuild older compiler binaries for this default.
See [host-target checks and limits](docs/HOST-TARGET-DEFAULT.md).

## 3. Compile a Harbour program to a Windows .exe (from Linux or Windows)

`hbc` writes the PE32+ image directly; no assembler, linker or import library
is needed:

```
./hbc tests/samples/hello.prg hello.exe --target=windows
```

The internal writer emits a console image with entry `_start`, fixed ImageBase
`0x140000000` and imports limited to a measured kernel32 whitelist
(`ExitProcess`, `GetEnvironmentVariableA`, `GetLocalTime`, `GetProcessHeap`,
`GetStdHandle`, `HeapAlloc`, `HeapFree`, `WriteFile`). No CRT, SEH, TLS or
base relocations are supported.

VAS-eligible programs add `GetSystemInfo`, `VirtualAlloc` and `VirtualFree` to this whitelist (11 entries); ineligible programs retain the original eight-entry whitelist.

On Windows 11 x86-64, an isolated run of `tests/run_battery_win.sh` with
`HBC_INTERNAL_PE=1` over the current 1726-entry manifest produced 1703
passes, 23 Linux-only skips and no failures, with no CR-normalized cases.
The final summary line was cut by a concurrent script edit; per-case lines
are complete and reconcile to 1726. It is a manifest-scoped result, not a
full compatibility claim.

`--external-as` keeps the older MinGW-w64 path below, which is also what
`tests/run_battery.sh` and `tests/run_battery_win.sh` use. For that fallback
you need MinGW-w64 binutils (`x86_64-w64-mingw32-as` and
`x86_64-w64-mingw32-ld`) and the MinGW-w64 import libraries
(`libkernel32.a`, from the `mingw-w64-x86-64-dev` package). On Debian/Ubuntu
without sudo you can extract the packages into a local directory:

```
apt-get download binutils-mingw-w64-x86-64 mingw-w64-x86-64-dev
dpkg -x binutils-mingw-w64-x86-64_*.deb tools/mingw
dpkg -x mingw-w64-x86-64-dev_*.deb tools/mingw
```

Then:

```
M=tools/mingw/usr/bin
MLIB=tools/mingw/usr/x86_64-w64-mingw32/lib
export LD_LIBRARY_PATH=$PWD/tools/mingw/usr/lib
./hbc tests/samples/hello.prg hello_win.s --target=windows
$M/x86_64-w64-mingw32-as -o hello_win.o hello_win.s
$M/x86_64-w64-mingw32-ld -o hello.exe hello_win.o -e _start --subsystem console -L$MLIB -lkernel32
```

The emitted code only calls `kernel32.dll` (`GetStdHandle`, `WriteFile`,
`ExitProcess`), so no CRT import library is needed for the generated programs.

## 4. Build the compiler itself as a Windows .exe (hbc.exe)

A current precompiled Windows x86-64 compiler is tracked at `bin/hbc.exe`.
From the repository root on Windows, no Rust, MinGW, C compiler, external
assembler or linker is needed for the supported native-only path:

```bat
bin\hbc.exe tests\samples\hello.prg hello.exe
hello.exe
```

This binary was cross-built from compiler source at
`e17223ffacb35e8c15f0368626ceee0e0ff23699` (the `src/` tree is identical
at `ecdd2d457e5b2f4e8d360b0bdcdaa58440898a7f`). SHA256:
`5e1b1e010e609b39a2e05d4d4c3ff47aa079463840ea27633f8f1e6d51a0af0c`.
Refresh `bin/hbc.exe` and this source pin/hash when the compiler changes;
it is a versioned snapshot, not automatically rebuilt when source changes.
It was added in `8299ee4`; it is not the v0.1.1 compiler and is not yet a
published v0.9.0 binary.

Fresh verification used Wine 11.0: this exact compiler, without a target flag,
compiled `hello.prg` and the four positive `tests/try-catch/` programs to PE32+;
all five generated programs ran with expected output, empty stderr and exit 0.
The two TRY negatives rejected with E0025. No native Windows execution or
full-manifest run was performed for this binary. The earlier Windows 11
1638-case result above is a different recorded run, not this verification.

To rebuild it yourself:

The tracked binary was cross-compiled from Linux with rustc 1.100.0,
the `x86_64-pc-windows-gnu` Rust target, `rust-lld`, MinGW-w64 8.0.0
(`mingw-w64-x86-64-dev` 8.0.0-1, Ubuntu 22.04), and GCC 10-posix
`libgcc.a` / `libgcc_eh.a`. This explicit, matching CRT route works with
those versions; MinGW-w64 v14 is not a minimum requirement:

```
rustup target add x86_64-pc-windows-gnu
CRT=/path/to/mingw-w64-8/usr/x86_64-w64-mingw32/lib   # provides crt2.o and the import libs
GCC=/path/to/gcc/x86_64-w64-mingw32/libgcc/dir         # provides libgcc.a and libgcc_eh.a
rustc --edition=2021 -O --target x86_64-pc-windows-gnu \
  -C linker=rust-lld -C linker-flavor=ld.lld -C link-self-contained=no \
  -C link-arg=$CRT/crt2.o -C link-arg=-L$CRT -C link-arg=-L$GCC \
  src/hbc.rs -o hbc.exe
```

`libgcc.a` / `libgcc_eh.a` come from a MinGW-w64 GCC package (Debian/Ubuntu
`gcc-mingw-w64-x86-64-posix`, extractable with `dpkg -x` the same way).

Use the CRT package's `crt2.o` together with its matching libraries, as
shown above. In a fresh rustc 1.100.0 control using this same MinGW-w64 8
library set, `-C link-self-contained=yes` selected Rust's bundled `crt2.o`
and failed to link (`__mingw_app_type`, `__mingw_initltssuo_force` and
related unresolved symbols). That does not mean older matching CRTs fail;
it shows that these startup objects and libraries cannot be mixed.

An older build note reported a startup crash under Wine 10 with a bundled
CRT. That historical environment was not reproduced here and is not a
general Wine 10 or self-contained-CRT claim. The explicit CRT build above
was freshly verified under Wine 11.0, not native Windows.

## 5. Run the Windows binaries under Wine (for testing)

Verified with Wine 10.20 (Kron4ek `wine-10.20-amd64-wow64` build):

```
wine ./hello.exe     # prints "Hola desde Harbour!"
wine ./hbc.exe prog.prg prog.s --target=windows
```

Wine 11.20 was also tried but does not start in constrained containers
(32 GB address-space reservation); use 10.20.

## 6. Current snapshot and historical repository binaries

Use `bin/hbc.exe` for the tracked Windows snapshot described in section 4.
The `dist/` files below are historical and do not describe its version or
native-writer requirements:

Historical GitHub releases are separate again: as checked on 14 November
2026, [v0.1.1](https://github.com/FiveTechSoft/HarbourRust/releases/tag/v0.1.1)
has 7 uploaded assets and
[v0.2.0](https://github.com/FiveTechSoft/HarbourRust/releases/tag/v0.2.0) has 8
(including `SHA256SUMS.txt`). Releases v0.3.0 through v0.8.0 have no uploaded
assets. The older v0.1.1/v0.2.0 compiler downloads use an assembler/linker
pipeline; follow their own release notes, not the current native-writer
requirements. Their Windows verification was under Wine 11.0, not real
Windows. Asset counts exclude GitHub-generated source archives.


| File          | Platform            | Description                               |
| ------------- | ------------------- | ----------------------------------------- |
| `1-hbc`     | Linux x86-64        | Historical compiler                       |
| `2-hbc.exe` | Windows x86-64      | Historical compiler, not current bin/hbc.exe |
| `3-hello.exe` | Windows x86-64      | `tests/samples/hello.prg` compiled as in section 3 |

The numeric prefixes are an artifact of the upload tool used to publish
the files; the contents are exactly the verified builds described here.

SHA-256 of each file is listed in `dist/SHA256SUMS`. These binaries were
built from `src/hbc.rs` at commit
`a8c8aed7efb87587e239eecd77dfa9ab7dc75173` and `src/pp.rs` at commit
`3e78dfddb797f8d65d6dfadc453add63efe877d5` (that exact source state is
also visible at the dist upload commit
`1b24443ebcd9834a2b9b43531832e2fb093c1080`, which only added the
binaries), and verified by running them
(Linux natively, Windows under Wine 10.20, not real Windows): `2-hbc.exe`
and `1-hbc` emit byte-identical assembly for the same input, and `3-hello.exe`
prints its expected output. `dist/build.sh` (Linux) and `dist/build.bat` (Windows) chain the three
steps for one program (`hbc` -> `as` -> `ld`) and stop at the first failing
step. build.sh was verified end-to-end on Linux; build.bat chains the
exact commands of section 3 and needs MinGW-w64 binutils on PATH on real
Windows (not exercised under Wine, where our as/ld are Linux binaries).

If `src/hbc.rs` at HEAD is newer than that
commit, these historical `dist/` binaries correspond to the older source; rebuild from
the current source (sections 1-4) for binaries matching HEAD.

## 7. Run the test battery

With the compiler built (section 1), MinGW-w64 extracted (section 3) and
Wine 10.20 unpacked (section 5). The Linux/Wine runner emits `.s` and calls
the external `as`/`ld` path:

```
M=tools/mingw/usr/bin \
MLIB=tools/mingw/usr/x86_64-w64-mingw32/lib \
WINE=/path/to/wine-10.20-amd64-wow64/bin/wine \
WINEPREFIX=$PWD/wineprefix WINEDEBUG=-all \
LD_LIBRARY_PATH=/path/to/wine-10.20-amd64-wow64/lib \
bash tests/run_battery.sh
```

The Windows execution runner uses MinGW binutils by default;
`HBC_INTERNAL_PE=1` switches it to hbc's internal PE writer, and `GEN_DIR`/
`MANIFEST_FILE` isolate a run from other jobs. In internal-PE mode it does not
need MinGW, so no `M` or `MLIB` setup is required:

```
HBC_INTERNAL_PE=1 GEN_DIR=work/gen-battery \
MANIFEST_FILE=tests/manifest.txt \
bash tests/run_battery_win.sh
```

`tests/run_battery_win_compile.ps1` is a front-end-only gate for a plain
Windows install: it runs every manifest entry through `hbc.exe
--target=windows` and checks compile acceptance and named negative messages,
without assembling, linking, executing or requiring MinGW, Rust, bash or
Wine. Runtime behavior is not covered there; use the runner above for
execution.

`tests/manifest.txt` lists every case: `pos` cases must print the exact
expected bytes on Linux and under Wine, `posx` adds the exit code, `neg`
cases must fail compilation with the named message on both targets.
Intermediate assembly, objects and binaries are written under `gen/`;
that directory is kept in the repository (with the `gen/arith.prg`
fixture the manifest references) so a fresh clone runs the battery
as-is. A full pass prints `ALL GREEN` as its last line.


## macOS Intel and ARM64 status

This is a first Intel Mach-O candidate, not a measured real-Mac release.
The compiler can be built with stable Rust using the macOS command-line
developer tools required by Rust's native linker. Install those first if
`rustc` reports a missing linker or SDK (`xcode-select --install`).

### Intel: build and make the first hardware check

1. Clone this repository and enter its root. Install a stable Rust toolchain.
2. Build the compiler and portable native runner:

   ```sh
   sh scripts/build_macos.sh
   ```

   The compiler command is `rustc --edition=2021 -O src/hbc.rs -o hbc`.
   No Cargo dependencies or GNU assembler are required for the internal writer.
3. Build and run the existing hello source, with no target flag:

   ```sh
   ./hbc tests/samples/hello.prg hello
   file hello
   ./hello
   ```

   `file` should identify Mach-O 64-bit x86_64, not ELF. Record stdout,
   stderr and status from this actual machine before calling it a Mac pass.
4. Run the focused first-test manifest, with real allocation instrumentation:

   ```sh
   ./run_native_manifest --manifest tests/macos-smoke.txt --output gen/mac-intel-smoke
   ```

   Every output directory must be new. Raw compile/run channels and results.tsv
   are retained. The runner is written in Rust so it needs no GNU timeout,
   sha256sum, Wine or Python. It uses `shasum -a 256` when available and records
   explicitly when a compiler hash could not be obtained.
5. For a wider diagnostic run, not a green-Mac claim:

   ```sh
   ./run_native_manifest --manifest tests/manifest.txt --output gen/mac-intel-full
   ```

   Unsupported OS paths reject and count as failures, not skips or compatibility.
   Each program has a 15-second limit; compiler invocations have 30 seconds.
   Existing pos/posx expectations preserve their historical final-LF handling;
   streams/pos2 compare exact bytes. pos2 uses the existing Linux/Unix file,
   not an independent native Harbour/Darwin oracle.

`--target=macho` explicitly selects experimental Intel Mach-O on any compiler
host. `--target=linux` and `--target=windows` still force x86-64 ELF/PE.
The `.s` form is the internal GNU-style assembly representation; it is not
claimed to assemble with Apple's external assembler. `--external-as` and
LLVM reject for this Mach-O increment. See [limits and evidence](docs/MACHO-INTEL.md).

### ARM64: compiler build preparation, backend not delivered yet

1. The same stable-Rust source build is intended for a native Apple Silicon
   compiler binary, but no Apple Silicon hardware build is verified here.
2. The default recognizes macOS ARM64 and reports the missing ARM64 backend
   instead of silently writing an Intel binary with an ARM header.
3. `--target=macho-arm64` likewise rejects until the native instruction backend
   and required loader/signing path are implemented and separately reviewed.
   Intel-via-Rosetta would not be native ARM64 support and is not claimed.

The first requested delivery is Intel for the owner's Mac test. ARM64 remains
an open following phase, not merely an untested claim of an implemented port.

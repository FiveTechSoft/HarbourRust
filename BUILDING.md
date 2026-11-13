# Building hbc

`hbc` is a single-file Rust program with no dependencies beyond the Rust
standard library. Everything below was tested with the versions noted; newer
versions will usually work, but these are the verified ones.

## 1. Build the compiler on Linux

Verified with rustc 1.99.1 (stable).

```
rustc -O src/hbc.rs -o hbc
```

No crates, no network access, no build system. The resulting `hbc` is a
statically linked Linux x86-64 binary.

## 2. Compile a Harbour program to a Linux binary

```
./hbc ejemplos/hola.hb hola.s --target=linux
as -o hola.o hola.s
ld -o hola hola.o
./hola
```

`as` and `ld` are the standard GNU binutils of the host.

## 3. Compile a Harbour program to a Windows .exe (from Linux)

You need MinGW-w64 binutils (`x86_64-w64-mingw32-as` and
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
./hbc ejemplos/hola.hb hola_win.s --target=windows
$M/x86_64-w64-mingw32-as -o hola_win.o hola_win.s
$M/x86_64-w64-mingw32-ld -o hola.exe hola_win.o -e _start --subsystem console -L$MLIB -lkernel32
```

The emitted code only calls `kernel32.dll` (`GetStdHandle`, `WriteFile`,
`ExitProcess`), so no CRT import library is needed for the generated programs.

## 4. Build the compiler itself as a Windows .exe (hbc.exe)

Cross-compiled from Linux with the `x86_64-pc-windows-gnu` Rust target,
`rust-lld`, and the MinGW-w64 v14 CRT (the version that ships with Debian
trixie; older CRTs miss `__mingw_initltssuo_force` and related symbols that
the Rust standard library needs):

```
rustup target add x86_64-pc-windows-gnu
CRT=/path/to/mingw-w64-14/usr/x86_64-w64-mingw32/lib   # provides crt2.o and the import libs
GCC=/path/to/gcc/x86_64-w64-mingw32/libgcc/dir         # provides libgcc.a and libgcc_eh.a
rustc -O --target x86_64-pc-windows-gnu \
  -C linker=rust-lld -C linker-flavor=ld.lld -C link-self-contained=no \
  -C link-arg=$CRT/crt2.o -C link-arg=-L$CRT -C link-arg=-L$GCC \
  src/hbc.rs -o hbc.exe
```

`libgcc.a` / `libgcc_eh.a` come from a MinGW-w64 GCC package (Debian/Ubuntu
`gcc-mingw-w64-x86-64-posix`, extractable with `dpkg -x` the same way).

Note: using Rust's self-contained `crt2.o` (the default) produced binaries
that crash at startup under Wine 10; linking the CRT's own matching `crt2.o`
as shown above is what was verified.

## 5. Run the Windows binaries under Wine (for testing)

Verified with Wine 10.20 (Kron4ek `wine-10.20-amd64-wow64` build):

```
wine ./hola.exe     # prints "Hola desde Harbour!"
wine ./hbc.exe prog.hb prog.s --target=windows
```

Wine 11.20 was also tried but does not start in constrained containers
(32 GB address-space reservation); use 10.20.

## 6. Prebuilt binaries in this repo

Under `dist/`:

| File          | Platform            | Description                               |
| ------------- | ------------------- | ----------------------------------------- |
| `1-hbc`     | Linux x86-64        | The compiler                              |
| `2-hbc.exe` | Windows x86-64      | The compiler, cross-built as in section 4 |
| `3-hola.exe` | Windows x86-64      | `ejemplos/hola.hb` compiled as in section 3 |

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
and `1-hbc` emit byte-identical assembly for the same input, and `3-hola.exe`
prints its expected output. `dist/build.sh` (Linux) and `dist/build.bat` (Windows) chain the three
steps for one program (`hbc` -> `as` -> `ld`) and stop at the first failing
step. build.sh was verified end-to-end on Linux; build.bat chains the
exact commands of section 3 and needs MinGW-w64 binutils on PATH on real
Windows (not exercised under Wine, where our as/ld are Linux binaries).

If `src/hbc.rs` at HEAD is newer than that
commit, the prebuilt binaries correspond to the older source; rebuild from
the current source (sections 1-4) for binaries matching HEAD.

## 7. Run the test battery

With the compiler built (section 1), MinGW-w64 extracted (section 3) and
Wine 10.20 unpacked (section 5):

```
M=tools/mingw/usr/bin \
MLIB=tools/mingw/usr/x86_64-w64-mingw32/lib \
WINE=/path/to/wine-10.20-amd64-wow64/bin/wine \
WINEPREFIX=$PWD/wineprefix WINEDEBUG=-all \
LD_LIBRARY_PATH=/path/to/wine-10.20-amd64-wow64/lib \
bash tests/run_battery.sh
```

`tests/manifest.txt` lists every case: `pos` cases must print the exact
expected bytes on Linux and under Wine, `posx` adds the exit code, `neg`
cases must fail compilation with the named message on both targets.
Intermediate assembly, objects and binaries are written under `gen/`;
that directory is kept in the repository (with the `gen/arith.hb`
fixture the manifest references) so a fresh clone runs the battery
as-is. A full pass prints `ALL GREEN` as its last line.

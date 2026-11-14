#!/bin/sh
# Retired historical compiler helper. Deliberately performs no build.
cat >&2 <<'NOTICE'
This is the retired build script for the historical HarbourRust compiler.
That compiler wrote assembly and needed external GNU as/ld tools.
This script is no longer needed and will not run any compiler or assembler.

On Linux, build the current compiler from source at the repository root:
  rustc --edition=2021 -O src/hbc.rs -o hbc
  ./hbc tests/samples/hello.prg hello --target=linux
  ./hello
For supported native-only programs, hbc writes ELF directly without as/ld.
Rust is needed to build the compiler, not to use an already-built hbc.

On Windows, use the current repository compiler at bin\hbc.exe:
  bin\hbc.exe tests\samples\hello.prg hello.exe
No MinGW, assembler or linker is needed for supported native-only programs.

The binaries in dist are historical, not the current compiler.
See README.md and BUILDING.md in the repository root for scope and limits.
NOTICE
exit 1

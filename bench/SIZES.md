# Executable sizes (2026-10-25)

Same three benchmark programs (see METHODOLOGY.md), same machine, x86-64 on
both platforms. All numbers are bytes on disk, no strip unless noted.

## Linux x86-64 (ELF)

| program | Harbour pcode | Harbour -gc3 | HarbourRust |
| --- | ---: | ---: | ---: |
| b1_int | 1,431,520 | 1,431,496 | 8,992 |
| b2_str | 1,435,616 | 1,431,496 | 9,080 |
| b3_call | 1,431,608 | 1,431,560 | 9,032 |

Harbour binaries: dynamically linked PIE, interpreter ld-linux-x86-64.so.2,
depend on libc.so.6 and libm.so.6; the Harbour RTL is linked in (that is
most of the 1.4 MB). HarbourRust binaries: statically linked, no
interpreter, no shared-library dependencies (own freestanding runtime with
direct syscalls - it HAS its own runtime, just linked in and small).

stripped (copies): Harbour ~1,278,448; HarbourRust 8,480-8,568.
Ratio (b1): 1,431,520 / 8,992 = ~159x smaller, Linux ELF vs Linux ELF.

## Windows x86-64 (PE32+)

HarbourRust only - no Harbour for Windows is installed in this environment,
so there is no Windows comparison row and no Windows ratio:

| program | HarbourRust PE |
| --- | ---: |
| b1_int | 6,038 |
| b2_str | 6,038 |
| b3_call | 5,544 |

Built with the published iteration-11 hbc (dist/11-hbc, SHA256 verified);
each links only kernel32; all three run under Wine 10.20 with the same
values as the Linux benchmark. mingw-strip on b1_int: 2,560 bytes, still
runs (verified under Wine).

Versions: Harbour built from harbour/core @ 694428e1 (gcc 11.4.0, hbmk2
default -O3); HarbourRust compiler @ commit 99f32d8f for the ELF rows,
dist/11-hbc (iteration 11) for the PE rows. Linux numbers are byte sizes of
the exact benchmark artifacts in this directory (b*_hbpc, b*_hbgc3,
b*_ours).

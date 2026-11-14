# Default target follows the compiler host

Review candidate against `947e7d1831e9870d610074db5b938db5c89bfee7`.
No publication is part of this package.

## Objective and fix

A Windows `hbc.exe` invoked without `--target` previously emitted Linux ELF,
even if the output was called `hello.exe`. Windows then rejected that file.
The compiler now starts with Windows as its target when built for Windows,
and Linux otherwise. The two explicit flags still override that initial
value, in the same parsing order as before.

This is the host of the compiler binary, not the machine that built it:
a cross-built Windows compiler running under Wine selects Windows. A Linux
compiler still selects Linux. The output suffix does not choose the target;
`.s` alone selects assembly rather than an executable.

Only the initial target expression changes behavior. The existing target
controls preprocessing, backend selection and ELF/PE writing. Usage text and
build instructions now state this default and show flag-free host examples.

## Short check and conclusion

`tools/check_host_target.py` uses fresh Linux and Windows compiler builds from
this source. It checks both normally and with `--instrument`:

- no target flag, explicit Linux and explicit Windows;
- output without a suffix, with `.exe`, and with `.s`;
- executable magic, execution stdout/stderr/status and target preprocessing;
- assembly target markers, both usage branches, and default versus explicit
  host artifacts.

All 52 checks pass: 24 executable runs, 12 assembly checks, four usage checks
and 12 default/explicit-host comparisons. Expected program stdout is LF plus
`linux` or `windows`, selected by `__PLATFORM__WINDOWS`; exit is zero and
stderr is empty. All generated Linux files execute natively and Windows files
execute under Wine 11.0. The checker adds the Unix executable bit before
running ELF files, because a Windows compiler cannot set that bit on Unix.

Artifact comparisons keep raw SHA256 values and compare exact ELF/assembly
bytes. For PE only, the existing writer's four timestamp bytes and four
checksum bytes are zeroed in the comparison copy. No program output is
normalized. This is not a claim of byte-reproducible PE files.

Sensitivity check: rebuilding the unmodified Windows compiler from the base
and using it with the same checker gives 38/52. The 14 failures are its six
flag-free Windows cases, six corresponding host-equivalence checks and two
old usage messages. Its 12 explicit-target cases pass. The unchanged Linux
candidate supplies the Linux half of this sensitivity run; this is not a
second baseline build for Linux.

The whole language manifest was not rerun for this small default-selection
change. The focused matrix checks the changed CLI behavior; it is not a full
language-regression or compatibility result. No unrelated expected streams
or target restrictions were changed.

## Reproduce

Build Linux and Windows compiler binaries as BUILDING.md describes, then:

```sh
python3 tools/check_host_target.py \
  --linux-compiler /path/to/hbc-linux \
  --windows-compiler /path/to/hbc-windows.exe \
  --wine /path/to/wine --wine-prefix /path/to/prefix \
  --output /tmp/host-target-results.json
```

The checker runs on Linux and expects Wine's `Z:` mapping for absolute paths.
No external assembler/linker is used to compile the test PRG.

## Limits

Measured on Linux x86-64 and a cross-built Windows x86-64 compiler under Wine
11.0, not on a real Windows host. No macOS/other-host target, new CPU backend,
LLVM expansion, external-assembler setup or Windows library feature is added.
Other non-Windows builds retain the previous Linux fallback; this is not
support for those hosts. Existing explicit-target restrictions still apply.
Older distributed compiler binaries keep their old behavior until rebuilt.
This changes default selection, not source-language support or performance.

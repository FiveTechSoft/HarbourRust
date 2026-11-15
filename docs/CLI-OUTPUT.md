# Default CLI output name

`hbc <input.prg> [output] [flags]` accepts an omitted output filename.

- `hbc Sub.Dir/TeSt.prg` writes `TeSt` in the current directory on Linux.
- `hbc Sub.Dir/TeSt.prg --target=windows` writes `TeSt.exe` there.
- A Windows compiler host defaults to the Windows target. Source basename
  case is retained. The selected target, not the host, decides the `.exe` suffix.
- The final source extension is removed: `Long.Name.PrG` becomes `Long.Name`.
  Native Windows path handling accepts backslashes as well as forward slashes.
- An omitted output always uses the executable path in the native backend,
  even if the resulting Linux basename ends in `.s`.
- An explicitly supplied output is unchanged. An explicit `.s` output still
  selects assembly. Existing destination replacement and filesystem casing
  behavior are unchanged.
- An automatically derived path that canonicalizes to the source is rejected
  before compilation. Supply a different explicit output for an extensionless
  source in the current directory.

This is naming behavior, not broader source-language or OS compatibility.
The experimental LLVM output route keeps its existing IR/runtime-file behavior.
Mach-O naming is emission-tested only. Windows evidence is PE execution under
Wine 11, not native Windows certification.

Developer gates: `tests/cli/default_output.py --help` and
`tests/cli/default_output_identity.py --help`. Both require a fresh evidence
directory. The identity gate compares native-backend explicit output bytes
against a compiler built from the patch's BASE, then checks derived output
against explicit output.

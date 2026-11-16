# FILE compatibility gate

See [the contract and commands](../../docs/FILE-COMPAT.md).

- `manifest.json`: positive programs and named negative cases.
- `*.linux.stdout`, `*.windows.stdout`: raw Harbour GTSTD oracle bytes.
- `*.stderr`: empty expected error streams.
- `file_memory`: hbc-only allocation-registry test, not a Harbour oracle.
- `check.py`: fresh fixture directory; original oracle and both hbc assemblers;
  checks stdout, stderr and exit independently. Writes command output plus a
  hashed `result.json` into a new output directory.
- `check_match.py`: additional libc differential test of the own C matcher.

The manifest is separate from tests/manifest.txt because FILE depends on the
fixture filesystem and cwd. Running these programs from the repository root
without setup does not test their contract.

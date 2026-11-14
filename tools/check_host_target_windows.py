#!/usr/bin/env python3
"""Native-Windows host-target gate (no Wine, no external toolchain).

Run on a real Windows host with a compiler built from current source.

Verifies that a Windows hbc.exe defaults to PE32+, that explicit targets
still override, and that the generated console EXE runs with the expected
bytes.
"""
import argparse, subprocess, sys
from pathlib import Path

EXPECTED = b"\nresultado de z:\n        32\nhola desde una funcion"

def is_pe(data: bytes) -> bool:
    if data[:2] != b"MZ" or len(data) < 0x40:
        return False
    off = int.from_bytes(data[0x3c:0x40], "little")
    return len(data) >= off + 4 and data[off:off+4] == b"PE\0\0"

def is_elf(data: bytes) -> bool:
    return data[:4] == b"\x7fELF"

def run(cmd, cwd):
    try:
        return subprocess.run(cmd, cwd=cwd, capture_output=True, timeout=30)
    except OSError as exc:
        from types import SimpleNamespace
        return SimpleNamespace(returncode=-1, stdout=b"", stderr=str(exc).encode())

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--compiler", required=True)
    ap.add_argument("--repo", default=".")
    ap.add_argument("--out", default="work/host_native_out")
    a = ap.parse_args()
    repo = Path(a.repo).resolve()
    out = repo / a.out
    out.mkdir(parents=True, exist_ok=True)
    src = "tests/samples/hello.prg"
    cases = []
    def check(name, cond, detail=""):
        cases.append((name, bool(cond), detail))
    # 1) flagless default must be PE on Windows and must run
    p = run([a.compiler, src, str(out / "flagless.exe")], repo)
    data = (out / "flagless.exe").read_bytes() if (out / "flagless.exe").is_file() else b""
    check("flagless-build", p.returncode == 0, p.stderr.decode("utf-8", "replace")[:120])
    check("flagless-pe", is_pe(data), data[:4].hex())
    if (out / "flagless.exe").is_file():
        r = run([str(out / "flagless.exe")], repo)
        check("flagless-run", r.returncode == 0 and r.stdout == EXPECTED,
              f"rc={r.returncode} out={r.stdout[:40]!r}")
    # 2) explicit windows override still works
    p = run([a.compiler, src, str(out / "explicit.exe"), "--target=windows"], repo)
    data = (out / "explicit.exe").read_bytes() if (out / "explicit.exe").is_file() else b""
    check("explicit-windows-build", p.returncode == 0, p.stderr.decode("utf-8", "replace")[:120])
    check("explicit-windows-pe", is_pe(data), data[:4].hex())
    # 3) explicit linux override from a Windows compiler writes ELF
    p = run([a.compiler, src, str(out / "explicit.elf"), "--target=linux"], repo)
    data = (out / "explicit.elf").read_bytes() if (out / "explicit.elf").is_file() else b""
    check("explicit-linux-build", p.returncode == 0, p.stderr.decode("utf-8", "replace")[:120])
    check("explicit-linux-elf", is_elf(data), data[:4].hex())
    failed = [c for c in cases if not c[1]]
    for name, ok, detail in cases:
        print(("PASS " if ok else "FAIL ") + name + ("" if ok else f" :: {detail}"))
    print(f"{len(cases)-len(failed)}/{len(cases)} checks pass")
    sys.exit(1 if failed else 0)

if __name__ == "__main__":
    main()

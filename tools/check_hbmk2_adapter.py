#!/usr/bin/env python3
"""Real-toolchain acceptance checks for the bounded MIT hbmk2 frontend."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--hbmk2", required=True)
    p.add_argument("--hbc", default=str(ROOT / "hbc"))
    p.add_argument("--output-dir", required=True, help="new evidence directory")
    a = p.parse_args()
    out = Path(a.output_dir).absolute()
    out.mkdir(exist_ok=False)
    rows = []
    adapter = ROOT / "tools/hbc_hbmk2.py"
    common = [sys.executable, str(adapter), "--hbc", str(Path(a.hbc).resolve()),
              "--hbmk2", str(Path(a.hbmk2).resolve())]

    def command(cmd, stem):
        r = subprocess.run([str(x) for x in cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
        (out / (stem + ".stdout")).write_bytes(r.stdout)
        (out / (stem + ".stderr")).write_bytes(r.stderr)
        return r

    def check(name, value):
        rows.append({"case": name, "pass": bool(value)})
        print(("PASS " if value else "FAIL ") + name)

    def build(name, sources, extra=()):
        exe = out / (name + ".bin")
        work = out / (name + " work")
        r = command(common + [str(s) for s in sources] + list(extra) +
                    ["--work-dir", str(work), "-o", str(exe)], name + ".build")
        return exe, work, r

    fixtures = {'arrays_hashes': 'function Main()\n'
                      '  local a := {}\n'
                      '  local h := { "alpha" => 11, "beta" => 29 }\n'
                      '  AAdd( a, 3 )\n'
                      '  AAdd( a, 7 )\n'
                      '  AAdd( a, 13 )\n'
                      '  ? Len( a ), a[ 1 ] + a[ 2 ] + a[ 3 ]\n'
                      '  ? h[ "alpha" ], h[ "beta" ]\n'
                      'return nil\n',
     'dates': 'function Main()\n'
              '  local d := CToD( "02/29/2024" )\n'
              '  local e := CToD( "" )\n'
              '  ? d\n'
              '  ? e\n'
              '  ? ValType( d )\n'
              'return nil\n',
     'hello': 'function Main()\n  ? "Hello from HarbourRust"\nreturn nil\n'}
    for name, text in fixtures.items():
        src = out / (name + ".hb")
        src.write_text(text)
        # Same compiler, independent direct native-only as/ld path.
        s, obj, direct = (out / (name + ext) for ext in [".s", ".o", ".direct"])
        for i, cmd in enumerate([[a.hbc, src, s, "--target=linux", "--instrument"],
                                 ["as", s, "-o", obj], ["ld", obj, "-o", direct]]):
            r = command(cmd, name + f".direct-build-{i}")
            if r.returncode:
                raise RuntimeError("direct baseline failed")
        expected = command([direct], name + ".direct-run")
        exe, work, r = build(name, [src], ["--instrument"])
        check(name + " build", r.returncode == 0 and exe.is_file())
        if exe.is_file():
            actual = command([exe], name + ".run")
            check(name + " exact direct output", (actual.returncode, actual.stdout, actual.stderr) ==
                  (expected.returncode, expected.stdout, expected.stderr))
            elf = command(["readelf", "-d", exe], name + ".elf")
            check(name + " freestanding ELF", b"no dynamic section" in elf.stdout)
            trace = (work / "hbmk2.stdout").read_text()
            check(name + " native object link trace", "program.o" in trace and "-nostdlib" in trace and "-lhbvm" not in trace)

    src = ROOT / "extend/demo/extdemo.hb"
    c = ROOT / "extend/demo/myext.c"
    expected = b"\n        23\n         7\nHELLO BRIDGE\nstr,num,log\n"
    # Harbour QOut does not add a trailing newline to the last empty value.
    # The demo ends with hbr_describe() printed on a new line.
    exe, work, r = build("bridge-c", [src, c])
    check("bridge C build", r.returncode == 0)
    actual = command([exe], "bridge-c.run")
    check("bridge C exact oracle fixture", actual.returncode == 0 and actual.stdout == expected and not actual.stderr)
    obj = out / "standalone-extension.o"
    r = command(["gcc", "-c", "-O2", "-ffreestanding", "-fno-stack-protector", "-I", ROOT / "extend", c, "-o", obj], "bridge-object.compile")
    check("bridge external object compile", r.returncode == 0)
    exe, work, r = build("bridge-object", [src, obj], ["--bridge"])
    check("bridge object build", r.returncode == 0)
    actual = command([exe], "bridge-object.run")
    check("bridge object exact oracle fixture", actual.returncode == 0 and actual.stdout == expected and not actual.stderr)

    special = out / "source space 'quoted'"
    special.mkdir()
    (special / "inc.ch").write_text('#define WORD "Include OK"\n')
    copied = special / "module with spaces.prg"
    copied.write_text('#include "inc.ch"\nfunction Main()\n? WORD\nreturn nil\n')
    exe, work, r = build("paths spaces 'quoted'", [copied])
    check("paths and sibling include build", r.returncode == 0)
    actual = command([exe], "paths.run")
    check("paths include exact output", actual.returncode == 0 and actual.stdout == b"\nInclude OK" and not actual.stderr)

    for name, sources, extra in [
        ("poison-hbc", [src], ["--hbc", "/bin/false"]),
        ("fake-hbc-no-asm", [src], ["--hbc", "/bin/true"]),
        ("poison-as", [src], ["--assembler", "/bin/false"]),
        ("fake-hbmk2-no-binary", [ROOT / "tests/samples/hello.hb"], ["--hbmk2", "/bin/true"]),
        ("multi-module", [src, copied], []),
        ("unsupported-project", [ROOT / "tests/manifest.txt"], []),
        ("missing-tool", [src], ["--hbc", "/no/such/compiler"]),
    ]:
        target = out / (name + ".bin")
        target.write_bytes(b"OLD OUTPUT MUST SURVIVE")
        r = command(common + [str(s) for s in sources] + extra + ["-o", target], name)
        check(name + " fails closed", r.returncode != 0 and target.read_bytes() == b"OLD OUTPUT MUST SURVIVE")
    r = command(common + [str(copied), "-o", str(copied)], "overwrite-input")
    check("input overwrite rejected", r.returncode != 0 and copied.read_text().startswith("#include"))
    r = command(common + [str(copied), "--work-dir", str(special), "-o", str(out / "not-built")], "existing-work")
    check("existing work rejected and retained", r.returncode != 0 and copied.is_file())
    (out / "results.json").write_text(json.dumps(rows, indent=2) + "\n")
    print(f"{sum(x['pass'] for x in rows)}/{len(rows)} PASS")
    return 0 if all(x["pass"] for x in rows) else 1


if __name__ == "__main__":
    sys.exit(main())

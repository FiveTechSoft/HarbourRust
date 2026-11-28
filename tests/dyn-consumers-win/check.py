#!/usr/bin/env python3
"""Dyn string consumers on native Windows: Val, CToD, Upper, Lower and
AllTrim of an untyped LOCAL, and the bare Date local CToD narrows.

Each program is an existing Linux pin (tests/val-dyn, tests/ctod-dyn,
tests/dyn-string-unary/cases.json). expected.json holds the stdout Harbour
3.2 printed for it on Windows (CRLF folded to LF); hbc must print the same
bytes. Usage: check.py --compiler HBC
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
TESTS = HERE.parent


def source(key, cases):
    if '#' in key:
        return cases[key.split('#', 1)[1]]
    return (TESTS / key).read_text(encoding='latin-1')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True)
    a = ap.parse_args()
    cc = str(Path(a.compiler).resolve())
    cases = json.loads((TESTS / 'dyn-string-unary' / 'cases.json').read_text())
    want = json.loads((HERE / 'expected.json').read_text())
    fails = 0
    with tempfile.TemporaryDirectory() as d:
        for i, (key, out) in enumerate(sorted(want.items())):
            src = Path(d) / ('p%d.prg' % i)
            src.write_text(source(key, cases), encoding='latin-1', newline='\n')
            exe = Path(d) / ('p%d.exe' % i)
            b = subprocess.run([cc, str(src), str(exe), '--target=windows'], capture_output=True)
            if b.returncode:
                fails += 1
                print('FAIL build', key, b.stderr.decode(errors='replace').strip())
                continue
            r = subprocess.run([str(exe)], capture_output=True, stdin=subprocess.DEVNULL, timeout=30)
            got = r.stdout.replace(b'\r\n', b'\n')
            if (r.returncode, got, r.stderr) != (0, out.encode('latin-1'), b''):
                fails += 1
                print('FAIL', key, r.returncode, got, r.stderr[:200])
            else:
                print('PASS', key)
    print('dyn-consumers-win: %d programs, %d failures' % (len(want), fails))
    sys.exit(1 if fails else 0)


if __name__ == '__main__':
    main()

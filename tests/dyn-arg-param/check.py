#!/usr/bin/env python3
"""Dyn arguments to parameters other call sites pin as scalars.

A tagged-union (Dyn) argument may carry any scalar kind at run time: a
float from `y % 19` with y untyped, a NIL, a string. Before this gate the
parameter kept the integer pin of its other call sites and the boundary's
integer-only conversion stopped the program with a misleading
"NIL used as a number". Each programs/NAME.out holds the stdout Harbour 3.2
printed for programs/NAME.prg (measured on Windows, CRLF folded to LF);
hbc must print the same bytes on the host target.
Usage: check.py --compiler HBC
"""
import argparse
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True)
    a = ap.parse_args()
    cc = str(Path(a.compiler).resolve())
    progs = sorted((HERE / 'programs').glob('*.prg'))
    fails = 0
    with tempfile.TemporaryDirectory() as d:
        for src in progs:
            want = src.with_suffix('.out').read_bytes()
            exe = Path(d) / (src.stem + ('.exe' if sys.platform == 'win32' else ''))
            b = subprocess.run([cc, str(src), str(exe)], capture_output=True)
            if b.returncode:
                fails += 1
                print('FAIL build', src.name, b.stderr.decode(errors='replace').strip())
                continue
            r = subprocess.run([str(exe)], capture_output=True, stdin=subprocess.DEVNULL, timeout=30)
            got = r.stdout.replace(b'\r\n', b'\n')
            if (r.returncode, got, r.stderr) != (0, want, b''):
                fails += 1
                print('FAIL', src.name, r.returncode, got, r.stderr[:200])
            else:
                print('PASS', src.name)
    print('dyn-arg-param: %d programs, %d failures' % (len(progs), fails))
    sys.exit(1 if fails or not progs else 0)


if __name__ == '__main__':
    main()

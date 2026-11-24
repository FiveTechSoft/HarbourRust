#!/usr/bin/env python3
"""Run main_args.prg with command-line arguments and compare its output.

Windows: each case is a raw command line, so hbc's own splitting of
GetCommandLineA is checked against the Harbour 3.2 results recorded in
cases.json. Linux: each case is an argument vector (the kernel delivers
argv verbatim). Every case prints six bracketed parameters, NIL past the
last argument.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent


def expected(want):
    vals = (list(want) + [None] * 6)[:6]
    return ''.join('\n[' + ('NIL' if v is None else v) + ']' for v in vals).encode('latin-1')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True)
    a = ap.parse_args()
    windows = os.name == 'nt'
    cases = json.loads((HERE / 'cases.json').read_text(encoding='utf-8'))['windows' if windows else 'linux']
    fails = 0
    with tempfile.TemporaryDirectory() as d:
        exe = Path(d) / ('main_args.exe' if windows else 'main_args')
        r = subprocess.run([str(Path(a.compiler).resolve()), str(HERE / 'main_args.prg'), str(exe)],
                           capture_output=True)
        if r.returncode != 0:
            sys.exit('compile failed: ' + r.stderr.decode(errors='replace'))
        for c in cases:
            if windows:
                p = subprocess.run('"%s" %s' % (exe, c['cmd']), capture_output=True, stdin=subprocess.DEVNULL, timeout=30)
                label = repr(c['cmd'])
            else:
                p = subprocess.run([str(exe)] + c['argv'], capture_output=True, stdin=subprocess.DEVNULL, timeout=30)
                label = repr(c['argv'])
            got = p.stdout.replace(b'\r\n', b'\n')
            ok = p.returncode == 0 and got == expected(c['want']) and p.stderr == b''
            print(('PASS ' if ok else 'FAIL ') + label)
            if not ok:
                fails += 1
                print('  want', expected(c['want']))
                print('  got ', got, 'rc', p.returncode, p.stderr[:200])
    print('main-args: %d cases, %d failures' % (len(cases), fails))
    sys.exit(1 if fails else 0)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Native-Windows differential gate for DBF fields read by name.

Covers `NAME`, `alias->NAME`, `FIELD->NAME` and the Harbour run-time errors
BASE/1003 (no such field / variable) and BASE/1002 (no such alias). The
fixture table is written by real Harbour (hbc never writes DBFs); each
program in programs/ is then built by Harbour and by hbc and both are run
in the same directory.

Comparison contract (docs/MACRO-ERROR-CONTRACT.md, terminal-headless):
exit code and stderr must match byte for byte; stdout must match after
removing Harbour's interactive alert line (`Error ... (Quit, Retry) `),
which hbc's headless profile omits by design. Programs never end a `?`
line with a padded character field (hbc's console drops a line's trailing
spaces; docs/BASELINE-2026-11-13.md).
"""
from pathlib import Path
import argparse, re, shutil, subprocess, tempfile


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True, help='hbc.exe')
    ap.add_argument('--harbour', required=True, help='Harbour 3.2 mingw64 install dir (bin/harbour.exe, include, lib/win/mingw64)')
    ap.add_argument('--mingw-bin', required=True, help='MinGW-w64 bin dir (gcc.exe)')
    ap.add_argument('--output', help='evidence directory (default: temporary)')
    a = ap.parse_args()
    hb = Path(a.harbour)
    gcc = Path(a.mingw_bin) / 'gcc.exe'
    here = Path(__file__).resolve().parent
    out = Path(a.output) if a.output else Path(tempfile.mkdtemp(prefix='hbc-dbf-fields-'))
    out.mkdir(parents=True, exist_ok=True)
    # The link line of the project's Harbour oracle (gcc + Harbour 3.2 mingw64).
    libs = ('-Wl,--start-group -lhbextern -lhbdebug -lhbvm -lhbrtl -lhblang '
            '-lhbcpage -lgtcgi -lgtpca -lgtstd -lgtwin -lgtwvt -lgtgui -lhbrdd '
            '-lhbuddall -lhbusrrdd -lrddntx -lrddcdx -lrddnsx -lrddfpt -lhbrdd '
            '-lhbhsx -lhbsix -lhbmacro -lhbcplr -lhbpp -lhbcommon -lhbmainstd '
            '-lwinmm -lkernel32 -luser32 -lgdi32 -ladvapi32 -lws2_32 -liphlpapi '
            '-lwinspool -lcomctl32 -lcomdlg32 -lshell32 -luuid -lole32 -loleaut32 '
            '-lmpr -lmapi32 -limm32 -lmsimg32 -lwininet -lhbpcre -lhbzlib '
            '-Wl,--end-group').split()

    def hb_build(prg, exe):
        src = out / (exe + '_hb.prg')
        src.write_text(prg.read_text() + '\nREQUEST HB_GT_CGI_DEFAULT\nREQUEST DBFCDX\n')
        subprocess.run([hb / 'bin/harbour.exe', '-n2', '-q0', src.name, '-o./', '-i' + str(hb / 'include')],
                       cwd=out, check=True, capture_output=True)
        cmd = [gcc, '-O1', src.stem + '.c', '-mconsole', '-I' + str(hb / 'include'), *libs,
               '-L' + str(hb / 'lib/win/mingw64'), '-o', exe + '_hb.exe']
        subprocess.run(cmd, cwd=out, check=True, capture_output=True)
        return out / (exe + '_hb.exe')

    def run(exe):
        p = subprocess.run([str(exe)], cwd=out, capture_output=True, timeout=60)
        return p.returncode, p.stdout.replace(b'\r\n', b'\n'), p.stderr.replace(b'\r\n', b'\n')

    fx = run(hb_build(here / 'build_fixture.prg', 'fixture'))
    assert fx[0] == 0, ('fixture builder failed', fx)
    raw = (out / 'fields.dbf').read_bytes()
    assert int.from_bytes(raw[4:8], 'little') == 3, 'fixture table must hold 3 records'
    alert = re.compile(rb'Error [^\n]*\(Quit[^)]*\) $')
    bad = 0
    progs = sorted((here / 'programs').glob('*.prg'))
    for prg in progs:
        name = prg.stem
        h = run(hb_build(prg, name))
        shutil.copy(prg, out / (name + '.prg'))
        c = subprocess.run([a.compiler, name + '.prg', name + '_hbc.exe', '--target=windows'], cwd=out, capture_output=True)
        if c.returncode:
            print('FAIL', name, 'hbc compile:', c.stderr.decode(errors='replace').strip())
            bad += 1
            continue
        g = run(out / (name + '_hbc.exe'))
        hout = alert.sub(b'', h[1])
        ok = h[0] == g[0] and h[2] == g[2] and hout == g[1]
        if not ok:
            bad += 1
            print('FAIL', name, '\n  harbour', h[0], hout, h[2], '\n  hbc    ', g[0], g[1], g[2])
        else:
            print('PASS', name, 'rc', g[0])
    print(f'{len(progs) - bad}/{len(progs)} identical; evidence in {out}')
    return 1 if bad else 0


if __name__ == '__main__':
    raise SystemExit(main())

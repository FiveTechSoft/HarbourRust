#!/usr/bin/env python3
"""Structural CDX autoopen differential gate. Same contract as
tests/dbf/goto-setorder/check_goto_setorder.py: every program is built by
real Harbour 3.2 (mingw64) and by hbc --target=windows and compared (exit
code, stderr, stdout after dropping Harbour's interactive alert line).

Fixture (build_fixture.prg, built by Harbour only), records shuffled so
natural and key order disagree:
- auto_s.dbf + auto_s.cdx: structural bag, production flag (byte 28) set;
- auto_n.dbf + auto_n.cdx: same bag, byte 28 cleared here (Harbour still
  opens it);
- auto_m.dbf: a copy of auto_s.dbf with the flag set and no bag (silent).

Registered difference (not admitted here): a readonly=.F. open with a
structural bag. Harbour opens and maintains the bag; hbc does not open it
and fails with an explicit message on dbSetOrder(n>=1), dbSeek or
ordListAdd of that bag.
"""
import argparse, re, shutil, subprocess, tempfile
from pathlib import Path


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True, help='hbc.exe')
    ap.add_argument('--harbour', required=True, help='Harbour 3.2 install dir (harbour.exe in bin/ or bin/win/mingw64/, include, lib/win/mingw64)')
    ap.add_argument('--mingw-bin', required=True, help='MinGW-w64 bin dir (gcc.exe)')
    ap.add_argument('--output', help='evidence directory (default: temporary)')
    a = ap.parse_args()
    hb = Path(a.harbour)
    harbour = next(p for p in (hb / 'bin/harbour.exe', hb / 'bin/win/mingw64/harbour.exe') if p.exists())
    gcc = Path(a.mingw_bin) / 'gcc.exe'
    compiler = Path(a.compiler).resolve()
    here = Path(__file__).resolve().parent
    out = Path(a.output) if a.output else Path(tempfile.mkdtemp(prefix='hbc-cdx-autoopen-'))
    out.mkdir(parents=True, exist_ok=True)
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
        subprocess.run([harbour, '-n2', '-q0', src.name, '-o./', '-i' + str(hb / 'include')],
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
    s = (out / 'auto_s.dbf').read_bytes()
    assert s[28] & 1, 'ordCreate must set the production flag on auto_s.dbf'
    assert int.from_bytes(s[4:8], 'little') == 3, 'fixture table must hold 3 records'
    n = bytearray((out / 'auto_n.dbf').read_bytes())
    n[28] = 0
    (out / 'auto_n.dbf').write_bytes(bytes(n))
    (out / 'auto_m.dbf').write_bytes(s)
    assert not (out / 'auto_m.cdx').exists()
    alert = re.compile(rb'Error [^\n]*\(Quit[^)]*\) $')
    bad = 0
    progs = sorted((here / 'programs').glob('*.prg'))
    for prg in progs:
        name = prg.stem
        h = run(hb_build(prg, name))
        shutil.copy(prg, out / (name + '.prg'))
        c = subprocess.run([compiler, name + '.prg', name + '_hbc.exe', '--target=windows'], cwd=out, capture_output=True)
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

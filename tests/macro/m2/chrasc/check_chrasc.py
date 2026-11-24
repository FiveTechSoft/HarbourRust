"""M2 Chr/Asc differential gate: same-source macro programs compiled and
run under official Harbour 3.2 (mingw64, native Windows) and hbc,
stdout/stderr/rc byte-identical after stripping Harbour's trailing alert
suffix and normalising CRLF to LF (the goto-setorder/delete-recall
pattern, applied to the M2 macro dispatcher increment 2026-11-24).

Oracle-measured shape (m2_p1/m2_p2* probes, native Windows):
- Chr(<numeric>): owned one-byte string, value & 255 (Chr(0) is a one-byte
  NUL string, Chr(256)=0x00, Chr(-1)=0xFF); a float argument truncates
  toward zero (Chr(65.7)="A"); "Error BASE/1104  Argument error: CHR" for
  string/logical arguments and for the zero-argument form.
- Asc(<string>): unsigned first byte; the empty string is 0, no error;
  "Error BASE/1107  Argument error: ASC" for numeric arguments and for
  the zero-argument form.

The a01_values program composes Chr/Asc with Upper/Lower/Round to exercise
the mixed dispatch (M2 IDs 1..5) in one macro. Negative rows are one
program per error so the oracle's Quit stop exposes each message alone.

Only the Windows target is verified here (no Wine/Linux host in this
session); the ELF battery in tests/memvar/context-macro covers the rest of
the manifest on Linux CI.
"""
import argparse, re, shutil, subprocess, tempfile
from pathlib import Path


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True, help='hbc.exe')
    ap.add_argument('--harbour', required=True, help='Harbour 3.2 mingw64 install dir')
    ap.add_argument('--mingw-bin', required=True, help='MinGW-w64 bin dir (gcc.exe)')
    ap.add_argument('--output', help='evidence directory (default: temporary)')
    a = ap.parse_args()
    hb = Path(a.harbour)
    gcc = Path(a.mingw_bin) / 'gcc.exe'
    here = Path(__file__).resolve().parent
    out = Path(a.output) if a.output else Path(tempfile.mkdtemp(prefix='hbc-m2-chrasc-'))
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
        src.write_text(prg.read_text() + '\nREQUEST HB_GT_CGI_DEFAULT\n')
        hbexe = hb / 'bin/harbour.exe'
        if not hbexe.exists(): hbexe = hb / 'bin/win/mingw64/harbour.exe'
        subprocess.run([hbexe, '-n2', '-q0', src.name, '-o./', '-i' + str(hb / 'include')],
                       cwd=out, check=True, capture_output=True)
        cmd = [gcc, '-O1', src.stem + '.c', '-mconsole', '-I' + str(hb / 'include'), *libs,
               '-L' + str(hb / 'lib/win/mingw64'), '-o', exe + '_hb.exe']
        subprocess.run(cmd, cwd=out, check=True, capture_output=True)
        return out / (exe + '_hb.exe')

    def run(exe):
        p = subprocess.run([str(exe)], cwd=out, capture_output=True, timeout=60)
        return p.returncode, p.stdout.replace(b'\r\n', b'\n'), p.stderr.replace(b'\r\n', b'\n')

    alert = re.compile(rb'Error [^\n]*\(Quit[^)]*\) $')
    bad = 0
    progs = sorted(here.glob('*.prg'))
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

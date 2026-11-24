"""D6 delete-flag write differential gate: same-source dbDelete/dbRecall
programs compiled and run under official Harbour 3.2 (mingw64, native
Windows) and hbc, stdout/stderr/rc byte-identical after stripping
Harbour's trailing alert suffix and normalising CRLF to LF.

Covers (oracle-measured 2026-11-24, probes d6_sem/d6_eof/d6_ro/d6_commit):
- mark/unmark the current record with immediate commit; Deleted() through
  the existing reader; delete on an already-deleted record stays marked;
- reopen persistence: a marked record stays marked after close/reopen and
  a recalled record stays unmarked;
- dbDelete/dbRecall at EOF are silent no-ops (no error, no flag change);
- dbCommit()/dbCommit(1) on a writable exclusive open: accepted, no output
  (differential rows live in d01 with one call each).

hbc named rejections (compile-time, this compiler only, not differential):
readonly open, open index, wrong arity, non-integer dbCommit argument.

Out of scope (unchanged rejections, D7/D8): writes with an open index,
ordCreate, ordSetFocus, shared opens, dbDelete with arguments.
"""
import argparse, re, shutil, subprocess, tempfile
from pathlib import Path


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True, help='hbc.exe')
    ap.add_argument('--harbour', required=True, help='Harbour 3.2 mingw64 install dir (bin/win/mingw64/harbour.exe, include, lib/win/mingw64)')
    ap.add_argument('--mingw-bin', required=True, help='MinGW-w64 bin dir (gcc.exe)')
    ap.add_argument('--output', help='evidence directory (default: temporary)')
    a = ap.parse_args()
    hb = Path(a.harbour)
    gcc = Path(a.mingw_bin) / 'gcc.exe'
    here = Path(__file__).resolve().parent
    out = Path(a.output) if a.output else Path(tempfile.mkdtemp(prefix='hbc-dbf-delrec-'))
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
        src.write_text(prg.read_text() + '\nREQUEST HB_GT_CGI_DEFAULT\nREQUEST DBFNTX\n')
        subprocess.run([hb / 'bin/win/mingw64/harbour.exe', '-n2', '-q0', src.name, '-o./', '-i' + str(hb / 'include')],
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
    raw = (out / 'del_rec.dbf').read_bytes()
    hdrlen = int.from_bytes(raw[8:10], 'little')
    assert (hdrlen - 33) // 32 == 5, 'fixture table must hold 5 fields'
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
    # Named failures: like fieldput's require_writable, the readonly and
    # open-index conditions are RUNTIME fail-fast lines on stderr (the
    # oracle raises DBFNTX/1025 "Write not allowed" for the readonly
    # case; hbc names its own message and exits). The arity/type rows
    # are compile-time named rejections (lowercase id, like the other
    # call-family messages).
    runtime_rows = [
        ('r01_readonly', 'function main()\n dbUseArea(.T., "DBFNTX", "del_rec.dbf", "X", .F., .T.)\n dbGoTop()\n dbDelete()\nreturn nil\n',
         b'hbc: DBF delete/recall requires a readonly=.F. open\n'),
        ('r02_open_index', 'function main()\n dbUseArea(.T., "DBFNTX", "del_rec.dbf", "X", .F., .F.)\n ordListAdd("del_tag.ntx")\n dbGoTop()\n dbDelete()\nreturn nil\n',
         b'hbc: DBF delete/recall with an open index is outside this increment\n'),
    ]
    for name, src, needle in runtime_rows:
        p = out / (name + '.prg')
        p.write_text(src)
        c = subprocess.run([a.compiler, p.name, name + '_hbc.exe', '--target=windows'], cwd=out, capture_output=True)
        if c.returncode:
            print('FAIL', name, 'hbc compile:', c.stderr.decode(errors='replace').strip()[:160])
            bad += 1
            continue
        g = run(out / (name + '_hbc.exe'))
        if g[0] == 0 or g[2] != needle:
            print('FAIL', name, '\n  hbc rc', g[0], 'stderr', g[2])
            bad += 1
        else:
            print('PASS', name, 'named runtime failure:', needle.decode().strip())
    rejects = [
        ('r03_delete_arg', 'function main()\n dbUseArea(.T., "DBFNTX", "del_rec.dbf", "X", .F., .F.)\n dbDelete(1)\nreturn nil\n',
         'dbdelete takes no arguments'),
        ('r04_recall_arg', 'function main()\n dbUseArea(.T., "DBFNTX", "del_rec.dbf", "X", .F., .F.)\n dbRecall(.T.)\nreturn nil\n',
         'dbrecall takes no arguments'),
        ('r05_commit_type', 'function main()\n dbUseArea(.T., "DBFNTX", "del_rec.dbf", "X", .F., .F.)\n dbCommit("x")\nreturn nil\n',
         'dbCommit takes an optional integer workarea argument'),
    ]
    for name, src, needle in rejects:
        p = out / (name + '.prg')
        p.write_text(src)
        c = subprocess.run([a.compiler, p.name, name + '_hbc.exe', '--target=windows'], cwd=out, capture_output=True)
        err = c.stderr.decode(errors='replace')
        if c.returncode == 0:
            print('FAIL', name, 'hbc accepted (must reject)')
            bad += 1
        elif needle not in err:
            print('FAIL', name, 'wrong message:', err.strip()[:160])
            bad += 1
        else:
            print('PASS', name, 'rejected:', needle)
    print(f'differential progs: {len(progs)}, named runtime failures: {len(runtime_rows)}, named rejects: {len(rejects)}; evidence in {out}')
    return 1 if bad else 0


if __name__ == '__main__':
    raise SystemExit(main())

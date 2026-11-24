"""D7 NTX index-write differential gate: same-source programs compiled and
run under official Harbour 3.2 (mingw64, native Windows) and hbc,
stdout/stderr/rc byte-identical after stripping Harbour's trailing alert
suffix and normalising CRLF to LF (the goto-setorder/delete-recall
pattern, applied to the NTX index maintenance increment of 2026-11-24).

Covers the oracle-measured facts (d7_ntx2/d7_ntx3 probes): a FieldPut of
the indexed key makes dbSeek lose the old key and find the new one
immediately, dbGoTop reflects the order, the change persists in the .ntx
FILE over close/reopen (i02), dbAppend's key enters the order at once and
persists (i03, with Eof at LastRec+1 after the append), and dbDelete
never touches the index (i04, the deleted record still seeks, across
reopen too). The oracle-measured alias rule: multi-letter aliases only
(single-letter aliases are unreliable in the oracle's close/reopen cycle
around writes).

hbc named rejection (compile-time, this compiler only): a field write
with an open CDX index stays outside the increment (CDX page writes are
a later increment; NTX only in D7).

Only the Windows target is verified here; the Linux blob carries the
same C sources (hrntx_build/flush are port-agnostic) and the Linux lane
runs in CI.
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
    out = Path(a.output) if a.output else Path(tempfile.mkdtemp(prefix='hbc-dbf-ixw-'))
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

    fx = run(hb_build(here / 'build_fixture.prg', 'fixture'))
    assert fx[0] == 0, ('fixture builder failed', fx)
    assert int.from_bytes((out / 'ixwrite.dbf').read_bytes()[4:8], 'little') == 8, 'fixture must hold 8 records'
    assert (out / 'ixwrite.ntx').exists(), 'fixture builder must leave the NTX'
    assert (out / 'ixw_tag.cdx').exists(), 'fixture builder must leave the CDX bag'
    pristine = {n: (out / n).read_bytes() for n in ('ixwrite.dbf', 'ixwrite.ntx', 'ixw_cdx.dbf', 'ixw_tag.cdx')}
    def restore():
        for n, b in pristine.items(): (out / n).write_bytes(b)
    alert = re.compile(rb'Error [^\n]*\(Quit[^)]*\) $')
    bad = 0
    progs = sorted((here / 'programs').glob('*.prg'))
    for prg in progs:
        name = prg.stem
        restore()
        h = run(hb_build(prg, name))
        restore()
        shutil.copy(prg, out / (name + '.prg'))
        c = subprocess.run([a.compiler, name + '.prg', name + '_hbc.exe', '--target=windows'], cwd=out, capture_output=True)
        if c.returncode:
            print('FAIL', name, 'hbc compile:', c.stderr.decode(errors='replace').strip())
            bad += 1
            continue
        restore()
        g = run(out / (name + '_hbc.exe'))
        hout = alert.sub(b'', h[1])
        ok = h[0] == g[0] and h[2] == g[2] and hout == g[1]
        if not ok:
            bad += 1
            print('FAIL', name, '\n  harbour', h[0], hout, h[2], '\n  hbc    ', g[0], g[1], g[2])
        else:
            print('PASS', name, 'rc', g[0])
    # Named rejection: CDX index writes stay outside D7 (runtime named
    # failure on the CDX bag fixture, like the readonly/open-index rows).
    p = out / 'r01_cdx_write.prg'
    p.write_text('function main()\n dbUseArea(.T., "DBFCDX", "ixw_cdx.dbf", "IXC", .F., .F.)\n ordListAdd("ixw_tag.cdx")\n FieldPut(1, "K00099")\nreturn nil\n')
    c = subprocess.run([a.compiler, p.name, 'r01_hbc.exe', '--target=windows'], cwd=out, capture_output=True)
    if c.returncode:
        print('FAIL r01_cdx_write hbc compile:', c.stderr.decode(errors='replace').strip()[:160])
        bad += 1
    else:
        g = run(out / 'r01_hbc.exe')
        want = b'hbc: DBF field write with an open CDX index is outside this increment (NTX only)\n'
        if g[0] == 0 or g[2] != want:
            print('FAIL r01_cdx_write\n  hbc rc', g[0], 'stderr', g[2])
            bad += 1
        else:
            print('PASS r01_cdx_write named runtime failure')
    print(f'differential progs: {len(progs)} + 1 named runtime failure; evidence in {out}')
    return 1 if bad else 0


if __name__ == '__main__':
    raise SystemExit(main())

#!/usr/bin/env python3
"""Native-Windows differential gate for `hbc --harbour-rdd`.

Each program in programs/ is built twice - by real Harbour 3.2 and by
`hbc --harbour-rdd` (static and, unless --modes says otherwise, DLL) - and
each build runs in its own fresh copy of the fixture tables (written by
Harbour itself, build_fixture.prg). The gate compares, byte for byte:
  * exit code, stderr, stdout (CRLF normalised; Harbour's interactive alert
    line `Error ... (Quit, ...) ` removed from stdout, which hbc's headless
    profile omits by design: docs/MACRO-ERROR-CONTRACT.md);
  * every table/index/memo file left in the run directory (*.dbf, *.cdx,
    *.ntx, *.fpt), including the ones the program created.
First-line directives: `// expect-reject: <text>` - hbc must reject the
program with <text> in its message and the Harbour run must leave every
table unchanged; `// compare: rc,files` - streams are not compared (used
where hbc's own, non-RDD error text differs from Harbour's in every mode).
Programs never end a `?` line with a padded character field (hbc's console
drops a line's trailing spaces; docs/BASELINE-2026-11-13.md). A DBF header
stores the date of the last update, so both sides must run on the same day
(they run seconds apart).
"""
from pathlib import Path
import argparse, re, shutil, subprocess, tempfile

TABLE_EXT = ('.dbf', '.cdx', '.ntx', '.fpt')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True, help='hbc.exe')
    ap.add_argument('--harbour', required=True, help='Harbour 3.2 mingw64 install dir (bin/harbour.exe, include, lib/win/mingw64)')
    ap.add_argument('--mingw-bin', required=True, help='MinGW-w64 bin dir (gcc.exe)')
    ap.add_argument('--modes', default='static,dll', help='hbc link modes to check: static, dll or both')
    ap.add_argument('--output', help='evidence directory (default: temporary)')
    a = ap.parse_args()
    hb = Path(a.harbour)
    mingw = Path(a.mingw_bin)
    gcc = mingw / 'gcc.exe'
    here = Path(__file__).resolve().parent
    out = Path(a.output) if a.output else Path(tempfile.mkdtemp(prefix='hbc-harbour-rdd-'))
    out.mkdir(parents=True, exist_ok=True)
    env = dict(__import__('os').environ)
    env['PATH'] = str(mingw) + ';' + env.get('PATH', '')
    libs = ('-Wl,--start-group -lhbextern -lhbdebug -lhbvm -lhbrtl -lhblang '
            '-lhbcpage -lgtcgi -lgtpca -lgtstd -lgtwin -lgtwvt -lgtgui -lhbrdd '
            '-lhbuddall -lhbusrrdd -lrddntx -lrddcdx -lrddnsx -lrddfpt -lhbrdd '
            '-lhbhsx -lhbsix -lhbmacro -lhbcplr -lhbpp -lhbcommon -lhbmainstd '
            '-lwinmm -lkernel32 -luser32 -lgdi32 -ladvapi32 -lws2_32 -liphlpapi '
            '-lwinspool -lcomctl32 -lcomdlg32 -lshell32 -luuid -lole32 -loleaut32 '
            '-lmpr -lmapi32 -limm32 -lmsimg32 -lwininet -lhbpcre -lhbzlib '
            '-Wl,--end-group').split()

    def hb_build(prg, d, exe):
        src = d / (exe + '.prg')
        src.write_text(prg.read_text() + '\nREQUEST HB_GT_CGI_DEFAULT\nREQUEST DBFCDX\nREQUEST DBFNTX\n')
        subprocess.run([hb / 'bin/harbour.exe', '-n2', '-q0', src.name, '-o./', '-i' + str(hb / 'include')],
                       cwd=d, check=True, capture_output=True)
        subprocess.run([gcc, '-O1', src.stem + '.c', '-mconsole', '-I' + str(hb / 'include'), *libs,
                        '-L' + str(hb / 'lib/win/mingw64'), '-o', exe + '.exe'], cwd=d, check=True, capture_output=True, env=env)
        return d / (exe + '.exe')

    def run(exe, d):
        p = subprocess.run([str(exe)], cwd=d, capture_output=True, timeout=60)
        return p.returncode, p.stdout.replace(b'\r\n', b'\n'), p.stderr.replace(b'\r\n', b'\n')

    def tables(d):
        return {f.name.lower(): f.read_bytes() for f in d.iterdir() if f.suffix.lower() in TABLE_EXT}

    fxd = out / 'fixture'
    fxd.mkdir(exist_ok=True)
    fx = run(hb_build(here / 'build_fixture.prg', fxd, 'fixture'), fxd)
    assert fx[0] == 0, ('fixture builder failed', fx)
    fixture = [f for f in fxd.iterdir() if f.suffix.lower() in TABLE_EXT]
    assert {f.name.lower() for f in fixture} == {'clie.dbf', 'clie.fpt', 'clin.dbf'}, fixture

    def fresh(d):
        if d.exists():
            shutil.rmtree(d)
        d.mkdir(parents=True)
        for f in fixture:
            shutil.copy(f, d / f.name)
        return d

    # The alert text may wrap before "(DOS Error n)".
    alert = re.compile(rb'(?:Error|Warning) [^\n]*(?:\n\(DOS Error \d+\))? ?\(Quit[^)]*\) $', re.M)
    modes = [m for m in a.modes.split(',') if m]
    bad = total = 0
    for prg in sorted((here / 'programs').glob('*.prg')):
        name = prg.stem
        hd = fresh(out / name / 'harbour')
        h = run(hb_build(prg, hd, name), hd)
        htab = tables(hd)
        hout = alert.sub(b'', h[1])
        m = re.match(r'// expect-reject: (.*)', prg.read_text().splitlines()[0])
        for mode in modes:
            total += 1
            cd = fresh(out / name / mode)
            shutil.copy(prg, cd / (name + '.prg'))
            cmd = [a.compiler, name + '.prg', name + '.exe', '--target=windows', '--harbour-rdd', '--harbour-dir=' + str(hb)]
            if mode == 'dll':
                cmd.append('--harbour-dll')
            c = subprocess.run(cmd, cwd=cd, capture_output=True, env=env)
            if m:
                # hbc must reject at compile time; the Harbour run must leave
                # every table exactly as the fixture (no field was stored).
                err = c.stderr.decode(errors='replace')
                same = all(htab.get(f.name.lower()) == f.read_bytes() for f in fixture)
                if c.returncode == 1 and m.group(1) in err and h[0] == 0 and same:
                    print('PASS', name, mode, 'rejected; Harbour left the tables unchanged')
                else:
                    bad += 1
                    print('FAIL', name, mode, 'hbc rc', c.returncode, err.strip(), '| harbour rc', h[0], 'tables unchanged', same)
                continue
            if c.returncode:
                bad += 1
                print('FAIL', name, mode, 'hbc build:', c.stderr.decode(errors='replace').strip())
                continue
            g = run(cd / (name + '.exe'), cd)
            gtab = tables(cd)
            why = []
            streams = not prg.read_text().startswith('// compare: rc,files')
            if h[0] != g[0]: why.append(f'rc harbour={h[0]} hbc={g[0]}')
            if streams and h[2] != g[2]: why.append(f'stderr\n    harbour={h[2]!r}\n    hbc    ={g[2]!r}')
            if streams and hout != g[1]: why.append(f'stdout\n    harbour={hout!r}\n    hbc    ={g[1]!r}')
            if set(htab) != set(gtab): why.append(f'files harbour={sorted(htab)} hbc={sorted(gtab)}')
            why += [f'{f} differs' for f in sorted(set(htab) & set(gtab)) if htab[f] != gtab[f]]
            if why:
                bad += 1
                print('FAIL', name, mode, '\n  ' + '\n  '.join(why))
            else:
                print('PASS', name, mode, 'rc', g[0], 'files', ','.join(sorted(gtab)))
    print(f'{total - bad}/{total} identical; evidence in {out}')
    return 1 if bad else 0


if __name__ == '__main__':
    raise SystemExit(main())

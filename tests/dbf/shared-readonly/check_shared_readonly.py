#!/usr/bin/env python3
"""shared=.T. readonly=.T. differential gate (native Windows, two processes).

Same build contract as tests/dbf/cdx-autoopen/check_cdx_autoopen.py: every
program under programs/ is built by real Harbour 3.2 (mingw64) and by hbc
--target=windows. Exit code, stderr and stdout are compared after dropping
Harbour's interactive alert line. The programs under harbour/ are built by
Harbour only and play the other process.

Scenarios (fixture rebuilt from pristine bytes before each run):
  alone       r1 with no other process.
  holder-S    r1 while a Harbour process holds shr.dbf shared read-write.
  reverse     r1 holds shr.dbf; a Harbour shared read-write writer appends
              and a Harbour exclusive open is refused. The writer and
              exclusive outputs must not depend on which compiler built r1.
Registered differences (asserted, not compared):
  append      the holder appends after r1 opened. Harbour sees the new
              record; hbc reads a snapshot taken at open, so its output
              equals its holder-S output. Same for r1 in reverse.
  holder-X    a Harbour process holds shr.dbf exclusively. Harbour sets
              NetErr() and continues (then fails on the alias); hbc aborts
              at the open with win32 error 32.
  r2          shc.dbf has a structural bag. Harbour uses it; hbc refuses
              any index on a shared open (index lock protocol).
"""
import argparse, os, re, shutil, subprocess, tempfile, time
from pathlib import Path

ALERT = re.compile(rb'Error [^\n]*\(Quit[^)]*\) $')
FLAGS = ('ready.flag', 'append.flag', 'appended.flag', 'go.flag', 'stop.flag')


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
    out = Path(a.output) if a.output else Path(tempfile.mkdtemp(prefix='hbc-shared-ro-'))
    out.mkdir(parents=True, exist_ok=True)
    libs = ('-Wl,--start-group -lhbextern -lhbdebug -lhbvm -lhbrtl -lhblang '
            '-lhbcpage -lgtcgi -lgtpca -lgtstd -lgtwin -lgtwvt -lgtgui -lhbrdd '
            '-lhbuddall -lhbusrrdd -lrddntx -lrddcdx -lrddnsx -lrddfpt -lhbrdd '
            '-lhbhsx -lhbsix -lhbmacro -lhbcplr -lhbpp -lhbcommon -lhbmainstd '
            '-lwinmm -lkernel32 -luser32 -lgdi32 -ladvapi32 -lws2_32 -liphlpapi '
            '-lwinspool -lcomctl32 -lcomdlg32 -lshell32 -luuid -lole32 -loleaut32 '
            '-lmpr -lmapi32 -limm32 -lmsimg32 -lwininet -lhbpcre -lhbzlib '
            '-Wl,--end-group').split()
    env = {**os.environ, 'PATH': str(gcc.parent) + os.pathsep + os.environ.get('PATH', '')}

    def hb_build(prg, exe):
        src = out / (exe + '_hb.prg')
        src.write_text(prg.read_text() + '\nREQUEST HB_GT_CGI_DEFAULT\nREQUEST DBFCDX\n')
        subprocess.run([harbour, '-n2', '-q0', src.name, '-o./', '-i' + str(hb / 'include')],
                       cwd=out, check=True, capture_output=True)
        subprocess.run([gcc, '-O1', src.stem + '.c', '-mconsole', '-I' + str(hb / 'include'), *libs,
                        '-L' + str(hb / 'lib/win/mingw64'), '-o', exe + '_hb.exe'],
                       cwd=out, check=True, capture_output=True, env=env)
        return str(out / (exe + '_hb.exe'))

    def hbc_build(prg, exe):
        shutil.copy(prg, out / (exe + '.prg'))
        c = subprocess.run([compiler, exe + '.prg', exe + '_hbc.exe', '--target=windows'], cwd=out, capture_output=True)
        assert c.returncode == 0, ('hbc compile', exe, c.stderr)
        return str(out / (exe + '_hbc.exe'))

    def norm(b):
        return b.replace(b'\r\n', b'\n')

    def clean():
        for f in FLAGS:
            (out / f).unlink(missing_ok=True)

    def flag(f):
        (out / f).write_text('1')

    def wait_file(f, t=20):
        end = time.time() + t
        while not (out / f).exists():
            assert time.time() < end, ('timeout waiting for', f)
            time.sleep(0.02)

    def start(exe, *args):
        return subprocess.Popen([exe, *args], cwd=out, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def wait_marker(p, marker=b'opened', t=20):
        """Read p's stdout until marker appears; return the bytes read."""
        got = b''
        end = time.time() + t
        while marker not in got:
            assert time.time() < end and p.poll() is None, ('reader did not open', got, p.poll())
            chunk = os.read(p.stdout.fileno(), 4096)
            if not chunk:
                break
            got += chunk
        return got

    def finish(p, head=b''):
        o, e = p.communicate(timeout=60)
        return p.returncode, norm(head + o), norm(e)

    fx = subprocess.run([hb_build(here / 'build_fixture.prg', 'fixture')], cwd=out, capture_output=True, timeout=60)
    assert fx.returncode == 0, ('fixture builder failed', fx)
    pristine = {f: (out / f).read_bytes() for f in ('shr.dbf', 'shc.dbf', 'shc.cdx')}
    assert int.from_bytes(pristine['shr.dbf'][4:8], 'little') == 3

    def reset():
        clean()
        for f, b in pristine.items():
            (out / f).write_bytes(b)

    holder = hb_build(here / 'harbour/holder.prg', 'holder')
    writer = hb_build(here / 'harbour/writer.prg', 'writer')
    exclusive = hb_build(here / 'harbour/exclusive.prg', 'exclusive')
    r1 = {'harbour': hb_build(here / 'programs/r1.prg', 'r1'), 'hbc': hbc_build(here / 'programs/r1.prg', 'r1')}
    r2 = {'harbour': hb_build(here / 'programs/r2.prg', 'r2'), 'hbc': hbc_build(here / 'programs/r2.prg', 'r2')}

    def alone(exe):
        reset(); flag('go.flag')
        p = subprocess.run([exe], cwd=out, capture_output=True, timeout=60)
        return p.returncode, norm(p.stdout), norm(p.stderr)

    def with_holder(mode, exe, append):
        reset()
        h = start(holder, mode)
        wait_file('ready.flag')
        r = start(exe)
        head = wait_marker(r) if mode == 'S' else b''
        if append:
            flag('append.flag'); wait_file('appended.flag')
        flag('go.flag')
        res = finish(r, head)
        flag('stop.flag')
        hres = finish(h)
        assert hres[0] == 0 and not hres[1].strip(), ('holder', hres)
        return res

    def reverse(exe):
        reset()
        r = start(exe)
        head = wait_marker(r)
        w = subprocess.run([writer], cwd=out, capture_output=True, timeout=60)
        x = subprocess.run([exclusive], cwd=out, capture_output=True, timeout=60)
        flag('go.flag')
        res = finish(r, head)
        return res, (w.returncode, norm(w.stdout), norm(w.stderr)), (x.returncode, norm(x.stdout), norm(x.stderr))

    bad = 0

    def same(name, h, g):
        nonlocal bad
        hs = (h[0], ALERT.sub(b'', h[1]), h[2])
        if hs == g:
            print('PASS', name, 'rc', g[0])
        else:
            bad += 1
            print('FAIL', name, '\n  harbour', hs, '\n  hbc    ', g)

    def check(name, ok, detail):
        nonlocal bad
        print('PASS' if ok else 'FAIL', name, '' if ok else detail)
        bad += not ok

    res = {}
    for who in ('harbour', 'hbc'):
        res[who, 'alone'] = alone(r1[who])
        res[who, 'holder-S'] = with_holder('S', r1[who], False)
        res[who, 'append'] = with_holder('S', r1[who], True)
        res[who, 'holder-X'] = with_holder('X', r1[who], False)
        res[who, 'reverse'] = reverse(r1[who])
        res[who, 'r2'] = alone(r2[who])
    same('r1 alone', res['harbour', 'alone'], res['hbc', 'alone'])
    same('r1 holder-S', res['harbour', 'holder-S'], res['hbc', 'holder-S'])
    hr, hw, hx = res['harbour', 'reverse']
    gr, gw, gx = res['hbc', 'reverse']
    check('reverse: Harbour reader sees the writer append', hr == res['harbour', 'append'], (hr, res['harbour', 'append']))
    check('reverse: hbc reader reads its open-time snapshot', gr == res['hbc', 'holder-S'], (gr, res['hbc', 'holder-S']))
    check('reverse: Harbour shared writer beside the reader', hw == gw and hw[0] == 0 and b'.F.' in hw[1] and b'4' in hw[1], (hw, gw))
    check('reverse: Harbour exclusive open refused beside the reader', hx == gx and b'.T.' in hx[1], (hx, gx))
    # Registered differences.
    check('append: Harbour sees the appended record', res['harbour', 'append'] != res['harbour', 'holder-S'] and b'C000' in res['harbour', 'append'][1], res['harbour', 'append'])
    check('append: hbc reads its open-time snapshot', res['hbc', 'append'] == res['hbc', 'holder-S'], (res['hbc', 'append'], res['hbc', 'holder-S']))
    g = res['hbc', 'holder-X']
    check('holder-X: Harbour continues after NetErr', res['harbour', 'holder-X'][0] == 1 and b'Alias does not exist' in res['harbour', 'holder-X'][2], res['harbour', 'holder-X'])
    check('holder-X: hbc aborts at the open (win32 error 32)', g[0] != 0 and not g[1].strip() and b'win32 error 32' in g[2], g)
    g = res['hbc', 'r2']
    check('r2: Harbour reads the structural bag', res['harbour', 'r2'][0] == 0, res['harbour', 'r2'])
    check('r2: hbc refuses an index on a shared open', g[0] != 0 and b'structural CDX on a shared=.T. open' in g[2], g)
    for k, v in sorted(res.items()):
        (out / ('%s.%s.txt' % k)).write_text(repr(v) + '\n')
    print(('%d failure(s)' % bad) if bad else 'ALL PASS', '; evidence in', out)
    return 1 if bad else 0


if __name__ == '__main__':
    raise SystemExit(main())

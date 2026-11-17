#!/usr/bin/env python3
"""Native Apple Silicon battery for --target=macho-arm64.

Compiles every runnable manifest row (pos, posx, pos2, posx2, streams,
streams2), the FILE compatibility positives and the DBF acceptance tests
4-7 with the native ARM64 Mach-O backend, runs the executable on the
host and compares it with the Linux expectations using the same acceptance
rules as tests/run_battery.sh. Rows the backend rejects at compile time are
reported separately (REJ), never counted as passes.

Usage: python3 tests/run_macho_arm64.py [--hbc ./hbc] [--jobs N] [regex]
Exit status 0 only when no row FAILs, no row REJs unexpectedly, the suite
total equals the expected total and (full battery) --thread-ref is given.
"""
import argparse, codecs, collections, concurrent.futures as cf, os, re, subprocess, sys, tempfile

KINDS = ('pos', 'posx', 'pos2', 'posx2', 'streams', 'streams2')

# Expected suite shape (docs/ARM64-NATIVE-2026-11-16.md, run 43985696680):
# no row may be rejected by the backend, and the totals are fixed.
EXPECTED_REJ = set()  # named rows the backend may reject; empty today
FILE_POSITIVES = 6
DBF_TESTS = 4
THREAD_PROGRAMS = 37
EXT_DEMOS = 8
# Post-run m_clie.dbf SHA-256 per DBF acceptance test, identical on Linux,
# native Windows and the arm64 emulator (generated on Linux, stdout checked
# against the committed expectations).
DBF_SHA256 = {
    4: 'cba93cb3b2b4b9caaa84a31f9824895793fcc760184a881c71f99c74d9e44237',
    5: '3b86d2f4fbf391f928194364cd2440d7ee46668e5c4033aff5517fecc29b64de',
    6: 'b53d75f1ace2b6573cd0f23c4a2ec99ac675dd9d912eb5b5999080b4f83e13b6',
    7: 'b53d75f1ace2b6573cd0f23c4a2ec99ac675dd9d912eb5b5999080b4f83e13b6',
}
SMOKE_SOURCE = 'FUNCTION Main()\n   ? "arm64 smoke ok"\n   RETURN NIL\n'
SMOKE_STDOUT = b'arm64 smoke ok\n'


def unesc(s):
    return codecs.escape_decode(s.encode('latin-1'))[0]


def run_case(line, hbc, outdir):
    p = line.split(' ')
    kind, f = p[0], p[1]
    base = re.sub(r'[^A-Za-z0-9_]', '_', f)
    exe = os.path.join(outdir, base)
    c = subprocess.run([hbc, f, exe, '--target=macho-arm64', '--instrument', '-I', 'tests'], capture_output=True)
    if c.returncode != 0:
        msg = (c.stderr.decode('latin-1').strip().splitlines() or ['?'])[-1]
        return 'REJ', f, msg[:200]
    try:
        if kind == 'posx2':
            r = subprocess.run([exe], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL, timeout=60)
            o, e = r.stdout, b''
        else:
            r = subprocess.run([exe], capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
            o, e = r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        return 'FAIL', f, 'timeout'
    code = r.returncode
    rd = lambda q: open(q, 'rb').read()
    nl = bytes([10])
    if kind == 'pos':
        exp = unesc(line.split(' ', 2)[2] if len(p) > 2 else '')
        ok = o.rstrip(nl) == exp.rstrip(nl) and code == 0 and e == b''
    elif kind == 'posx':
        exp = unesc(line.split(' ', 3)[3] if len(p) > 3 else '')
        ok = o.rstrip(nl) == exp.rstrip(nl) and code == int(p[2]) and e == b''
    elif kind == 'pos2':
        exp = rd(p[2]); ok = o == exp and code == 0 and e == b''
    elif kind == 'posx2':
        exp = rd(p[3]); ok = o == exp and code == int(p[2])
    elif kind == 'streams':
        exp = rd(p[2]); ok = o == exp and e == rd(p[3]) and code == 0
    else:
        exp = rd(p[2]); ok = o == exp and e == rd(p[4]) and code == 0
    if ok:
        return 'PASS', f, ''
    return 'FAIL', f, 'rc=%s stdout=%r stderr=%r expected=%r' % (code, o[:160], e[:160], exp[:160])


def file_suite(hbc, d):
    """tests/file-compat positives in check.py's fixture tree, against the
    Linux expectations (the matcher, not the host OS, decides the result)."""
    import json, pathlib, shutil
    root = pathlib.Path('tests/file-compat').resolve()
    cwd = pathlib.Path(d) / 'fs'
    cwd.mkdir()
    for directory in ['sub', 'default', 'search', 'odd' + chr(92), 'a' * 250]:
        (cwd / directory).mkdir()
    for f in ['Exact.TXT', '.hidden', 'noext', 'sub/nested.txt', 'default/only.txt', 'search/path.txt', '*.star', '?.question',
              '[bracket', ']bracket', '[x', 'caf' + chr(0xe9) + '.txt', 'odd' + chr(92) + '/back.txt', 'a' * 250 + '/' + 'b' * 11]:
        (cwd / f).touch()
    for name, dest in [('link.txt', 'Exact.TXT'), ('broken', 'absent'), ('linkdir', 'sub'), ('cycle', 'cycle')]:
        (cwd / name).symlink_to(dest)
    for src in root.glob('*.prg'):
        shutil.copyfile(src, cwd / src.name)
    env = dict(os.environ, LC_ALL='C.UTF-8')
    res = []
    for entry in json.loads((root / 'manifest.json').read_text())['positive']:
        name = entry['name']
        exe = pathlib.Path(d) / ('file_' + name)
        c = subprocess.run([hbc, name + '.prg', str(exe), '--target=macho-arm64', '--instrument'], cwd=cwd, capture_output=True)
        if c.returncode:
            res.append(('REJ', 'file-compat/' + name, c.stderr.decode('latin-1').strip()[-200:])); continue
        r = subprocess.run([str(exe)], cwd=cwd, env=env, capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
        exp = ((root / (name + '.linux.stdout')).read_bytes(), (root / (name + '.linux.stderr')).read_bytes(), 0)
        ok = (r.stdout, r.stderr, r.returncode) == exp
        res.append(('PASS' if ok else 'FAIL', 'file-compat/' + name, '' if ok else 'rc=%s stdout=%r stderr=%r expected=%r' % (r.returncode, r.stdout[:300], r.stderr[:200], exp[0][:300])))
    return res


def dbf_suite(hbc, d):
    """DBF acceptance tests 4-7 on a copy of the anonymized M_CLIE.DBF."""
    import pathlib, shutil
    res = []
    for t in (4, 5, 6, 7):
        src = pathlib.Path('tests/dbf/acceptance-test%d' % t).resolve()
        work = pathlib.Path(d) / ('dbf%d' % t)
        work.mkdir()
        shutil.copyfile('tests/dbf/acceptance-test3/M_CLIE.DBF', work / 'm_clie.dbf')
        exe = work / 'probe'
        c = subprocess.run([hbc, str(src / ('test%d.prg' % t)), str(exe), '--target=macho-arm64'], capture_output=True)
        if c.returncode:
            res.append(('REJ', 'dbf/test%d' % t, c.stderr.decode('latin-1').strip()[-200:])); continue
        r = subprocess.run([str(exe)], cwd=work, capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
        exp = (src / ('test%d.linux.expected.txt' % t)).read_bytes()
        ok = r.stdout == exp and r.stderr == b'' and r.returncode == 0
        res.append(('PASS' if ok else 'FAIL', 'dbf/test%d' % t, '' if ok else 'rc=%s stdout=%r stderr=%r' % (r.returncode, r.stdout[:300], r.stderr[:200])))
        h = __import__('hashlib').sha256((work / 'm_clie.dbf').read_bytes()).hexdigest()
        print('dbf/test%d m_clie.dbf sha256 %s' % (t, h))
        if h != DBF_SHA256[t]:
            res[-1] = ('FAIL', 'dbf/test%d' % t, 'm_clie.dbf sha256 %s != reference %s' % (h, DBF_SHA256[t]))
    return res


def thread_suite(hbc, d, ref):
    """tests/threads/programs against Linux outputs of the same programs
    (stdout, stderr, exit code), each run three times."""
    import pathlib
    res = []
    for src in sorted(pathlib.Path('tests/threads/programs').glob('*.prg')):
        b = src.stem
        exe = pathlib.Path(d) / ('thr_' + b)
        c = subprocess.run([hbc, str(src), str(exe), '--target=macho-arm64'], capture_output=True)
        if c.returncode:
            res.append(('REJ', 'threads/' + b, c.stderr.decode('latin-1').strip()[-200:])); continue
        r_ = pathlib.Path(ref)
        exp = ((r_ / (b + '.stdout')).read_bytes(), (r_ / (b + '.stderr')).read_bytes(), int((r_ / (b + '.rc')).read_text()))
        bad = ''
        for k in range(3):
            try:
                r = subprocess.run([str(exe)], cwd=d, capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
                got = (r.stdout, r.stderr, r.returncode)
            except subprocess.TimeoutExpired:
                got = (b'', b'', 'timeout')
            if got != exp:
                bad = 'run %d: rc=%s stdout=%r stderr=%r expected rc=%s stdout=%r' % (k, got[2], got[0][:200], got[1][:200], exp[2], exp[0][:200]); break
        res.append(('FAIL' if bad else 'PASS', 'threads/' + b, bad))
    return res


def ext_suite(hbc, d, ref):
    """EXTERNAL demos: the C extension and extend/hbhbr.c form the dylib
    libhbext.dylib next to the executable; outputs against Linux (gcc
    bridge, as, ld) runs of the same demos."""
    import pathlib
    res = []
    for n in ['apif64', 'apiecho', 'apiref', 'apistorref', 'apiitem', 'apiarr', 'apieval', 'extdemo']:
        work = pathlib.Path(d) / ('ext_' + n)
        work.mkdir()
        srcs = ['extend/hbhbr.c', 'extend/demo/' + ('myext' if n == 'extdemo' else n) + '.c']
        if n in ('apiref', 'apiitem', 'apistorref', 'apiarr', 'apieval'):
            srcs.append('extend/demo/apif64.c')
        c = subprocess.run(['clang', '-O2', '-dynamiclib', '-undefined', 'dynamic_lookup', '-Iextend', *srcs, '-o', str(work / 'libhbext.dylib')], capture_output=True)
        if c.returncode:
            res.append(('FAIL', 'extend/' + n, 'clang: ' + c.stderr.decode('latin-1')[-300:])); continue
        c = subprocess.run([hbc, 'extend/demo/%s.prg' % n, str(work / 'prog'), '--target=macho-arm64'], capture_output=True)
        if c.returncode:
            res.append(('REJ', 'extend/' + n, c.stderr.decode('latin-1').strip()[-200:])); continue
        r_ = pathlib.Path(ref)
        exp = ((r_ / ('ext_%s.stdout' % n)).read_bytes(), (r_ / ('ext_%s.stderr' % n)).read_bytes(), int((r_ / ('ext_%s.rc' % n)).read_text()))
        try:
            r = subprocess.run([str(work / 'prog')], cwd=work, capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
            got = (r.stdout, r.stderr, r.returncode)
        except subprocess.TimeoutExpired:
            got = (b'', b'', 'timeout')
        ok = got == exp
        res.append(('PASS' if ok else 'FAIL', 'extend/' + n, '' if ok else 'rc=%s stdout=%r stderr=%r expected rc=%s stdout=%r' % (got[2], got[0][:300], got[1][:300], exp[2], exp[0][:300])))
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--hbc', default='./hbc')
    ap.add_argument('--jobs', type=int, default=os.cpu_count() or 4)
    ap.add_argument('--thread-ref', help='directory with Linux <name>.stdout/.stderr/.rc of tests/threads/programs and ext_<demo> EXTERNAL demos')
    ap.add_argument('pattern', nargs='?')
    a = ap.parse_args()
    hbc = os.path.abspath(a.hbc)
    if not a.pattern and not a.thread_ref:
        print('FAIL runner: the full battery needs --thread-ref (threads + EXTERNAL reference outputs); refusing to report a partial suite as green')
        return 1
    rows = [l.rstrip('\n') for l in open('tests/manifest.txt', encoding='latin-1')]
    rows = [l for l in rows if l.split(' ')[0] in KINDS]
    if a.pattern:
        rows = [l for l in rows if re.search(a.pattern, l.split(' ')[1])]
    with tempfile.TemporaryDirectory() as d, cf.ThreadPoolExecutor(a.jobs) as ex:
        # (3) smoke: one compile+run with a known stdout before the battery,
        # so a broken compiler or host can never look like zero rows to run.
        smoke_prg = os.path.join(d, 'smoke.prg')
        open(smoke_prg, 'w').write(SMOKE_SOURCE)
        c0 = subprocess.run([hbc, smoke_prg, os.path.join(d, 'smoke'), '--target=macho-arm64'], capture_output=True)
        if c0.returncode != 0:
            print('FAIL smoke: compile rc=%s %s' % (c0.returncode, c0.stderr.decode('latin-1')[-200:]))
            return 1
        try:
            r0 = subprocess.run([os.path.join(d, 'smoke')], capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
            got0 = (r0.stdout, r0.stderr, r0.returncode)
        except (OSError, subprocess.TimeoutExpired) as e0:
            got0 = (b'', str(e0).encode('latin-1'), 'exec-error')
        if got0 != (SMOKE_STDOUT, b'', 0):
            print('FAIL smoke: rc=%s stdout=%r stderr=%r' % (got0[2], got0[0], got0[1]))
            return 1
        print('PASS smoke')
        res = list(ex.map(lambda l: run_case(l, hbc, d), rows))
        expected = len(rows)
        if not a.pattern:
            res += file_suite(hbc, d) + dbf_suite(hbc, d)
            expected += FILE_POSITIVES + DBF_TESTS
            res += thread_suite(hbc, d, a.thread_ref) + ext_suite(hbc, d, a.thread_ref)
            expected += THREAD_PROGRAMS + EXT_DEMOS
    for r in res:
        if r[0] != 'PASS':
            print('%s %s %s' % r)
    c = collections.Counter(r[0] for r in res)
    print('SUMMARY', dict(c))
    bad = 0
    if c.get('FAIL'):
        bad = 1
    unexpected_rej = [r for r in res if r[0] == 'REJ' and r[1] not in EXPECTED_REJ]
    if unexpected_rej:
        print('FAIL runner: %d unexpected REJ row(s)' % len(unexpected_rej))
        bad = 1
    if len(res) != expected:
        print('FAIL runner: suite total %d != expected %d' % (len(res), expected))
        bad = 1
    return bad


if __name__ == '__main__':
    sys.exit(main())

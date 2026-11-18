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
import argparse, codecs, collections, concurrent.futures as cf, os, re, subprocess, sys, tempfile, time

KINDS = ('pos', 'posx', 'pos2', 'posx2', 'streams', 'streams2')

# Expected suite shape (docs/ARM64-NATIVE-2026-11-16.md, run 43985696680):
# the totals are fixed and every backend rejection must be named here.
# No named compile-time rejections in this increment: hb_idleSleep got
# its Darwin lowering (Linux 35 -> libSystem _nanosleep wrapper, also
# reached by the __a64_linux_syscall dispatcher), so the five
# tests/idlesleep-linux rows run natively like every other row.
# EXPECTED_REJ stays as the fail-closed machinery for future named
# limits: a row only counts as REJ when the compiler exits normally
# (rc 1, never a signal) with the named diagnostic; a crash, an abnormal
# rc or a different message is a FAIL, never an expected rejection. A
# named REJ that stops rejecting with its diagnostic fails the battery
# (stale name). An empty map makes ANY rejection unexpected (fail).
EXPECTED_REJ = {}
# The idlesleep rows print identical bytes whether nanosleep really
# slept or the lowering silently no-ops (wrong number, ENOSYS), so each
# positive-sleep row also carries a wall-clock floor on the native run
# (monotonic; the same bounds as the Linux suite).
# A lowering that returns instantly FAILS here even on byte-exact output.
IDLESLEEP_WINDOWS = {
    'tests/idlesleep-linux/programs/idlesleep_basic.prg': (0.15, 2.0),
    'tests/idlesleep-linux/programs/idlesleep_dyn.prg': (0.15, 2.0),
    'tests/idlesleep-linux/programs/idlesleep_loop.prg': (1.1, 4.0),
    'tests/idlesleep-linux/programs/idlesleep_negative.prg': (0.0, 0.5),
    'tests/idlesleep-linux/programs/idlesleep_noarg.prg': (0.0, 0.5),

}
# Intel lowers Linux 35 to libSystem nanosleep too (hbc_dw_nanosleep),
# so both targets run the rows with the same windows and no named REJ.

def configure_target(target):
    global TARGET
    TARGET = '--target=' + target

FILE_POSITIVES = 6
DBF_TESTS = 4
THREAD_PROGRAMS = 38
EXT_DEMOS = 9
TARGET = '--target=macho-arm64'  # --target=macho runs the same battery on Intel
# Executable-row inventory of the committed tests/manifest.txt:
# 1235 through STATIC-NIL (0edc3e89), then two nullable-string method
# programs added by cd9d6884: nullable_strings and multiple_strings.
# The full battery refuses truncated/empty manifests and stale constants.
# Bump this only with the manifest change that explains it.
# Dyn/string concat adds20 runnable rows (19programs plus former negative).
# Type predicates make t415 a positive row (+1).
# tests/threads/programs gains ts01_str_dyn (Str(Dyn) in threads): 38.
# Full total:1259+6+4+38+9 =1316,0 REJ on both targets.
EXPECTED_MANIFEST_ROWS = 1259
# Post-run m_clie.dbf SHA-256 per DBF acceptance test (generated on Linux,
# stdout checked against the committed expectations). t4 appends records:
# dbAppend rewrites the header last-update date (bytes 1-3, YY MM DD of the
# run's UTC day) on Linux AND Windows, so a whole-file hash can never be
# stable across days. For t4 ONLY, those three bytes are checked against
# the run's UTC date explicitly and zeroed before hashing; t5-t7 never
# touch the header, their frozen 2024-01-03 bytes are fixture content and
# stay inside the hash (a runtime that wrongly rewrote them fails here).
DBF_SHA256 = {
    4: 'a2ae7bcd60ba8a68eecdf68a8e5593e03e868688288322b7094d639897017ec6',
    5: '3b86d2f4fbf391f928194364cd2440d7ee46668e5c4033aff5517fecc29b64de',
    6: 'b53d75f1ace2b6573cd0f23c4a2ec99ac675dd9d912eb5b5999080b4f83e13b6',
    7: 'b53d75f1ace2b6573cd0f23c4a2ec99ac675dd9d912eb5b5999080b4f83e13b6',
}
DBF_DATE_NORMALIZED = {4}
# Real compiler bytes, verified on the Linux target (same runtime): QOut
# (`? "arm64 smoke ok"`) emits a LEADING LF and no trailing one
# (b'\narm64 smoke ok'), so the smoke uses explicit OutStd instead.
SMOKE_SOURCE = 'FUNCTION Main()\n   OutStd("arm64 smoke ok" + hb_eol())\n   RETURN NIL\n'
SMOKE_STDOUT = b'arm64 smoke ok\n'


def unesc(s):
    return codecs.escape_decode(s.encode('latin-1'))[0]


def classify_compile_failure(f, rc, err_text):
    """Compile-time failure triage. A row named in EXPECTED_REJ counts as
    REJ only on a normal error exit (rc 1, never a signal) whose stderr
    carries the row's registered diagnostic substring; a crash, an
    abnormal rc or a different message is a FAIL (fail-closed: an
    expected rejection can never hide a broken compiler). A row not
    named in EXPECTED_REJ stays REJ here and is caught by the
    unexpected-REJ check in main()."""
    lines = err_text.strip().splitlines()
    last = (lines[-1] if lines else '?')[:200]
    if f not in EXPECTED_REJ:
        return 'REJ', last
    if rc == 1 and EXPECTED_REJ[f] in err_text:
        return 'REJ', last
    if rc < 0:
        return 'FAIL', 'named-limit row killed by signal %d: %s' % (-rc, last)
    if rc != 1:
        return 'FAIL', 'named-limit row abnormal reject rc=%d (expected 1): %s' % (rc, last)
    return 'FAIL', 'named-limit row rejected with the wrong diagnostic (expected substring %r): %s' % (EXPECTED_REJ[f], last)


def stale_named_rejections(res):
    """Named EXPECTED_REJ rows missing a strict REJ in the results (the
    row compiled and ran, crashed, or rejected with the wrong diagnostic
    - classify_compile_failure only produces REJ for the registered
    rc-1-with-diagnostic shape). EXPECTED_REJ is a dict row ->
    diagnostic; iterate its keys. Run 44039075657: `EXPECTED_REJ - set`
    on the dict itself raised TypeError after a PASS 1273 + REJ 5
    battery."""
    return sorted(set(EXPECTED_REJ) - {r[1] for r in res if r[0] == 'REJ'})


def run_case(line, hbc, outdir):
    p = line.split(' ')
    kind, f = p[0], p[1]
    base = re.sub(r'[^A-Za-z0-9_]', '_', f)
    exe = os.path.join(outdir, base)
    c = subprocess.run([hbc, f, exe, TARGET, '--instrument', '-I', 'tests'], capture_output=True)
    if c.returncode != 0:
        kind, msg = classify_compile_failure(f, c.returncode, c.stderr.decode('latin-1'))
        return kind, f, msg
    window = IDLESLEEP_WINDOWS.get(f)
    try:
        if window is not None:
            t0 = time.monotonic()
        if kind == 'posx2':
            r = subprocess.run([exe], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL, timeout=60)
            o, e = r.stdout, b''
        else:
            r = subprocess.run([exe], capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
            o, e = r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        return 'FAIL', f, 'timeout'
    elapsed = time.monotonic() - t0 if window is not None else None
    if window is not None and not window[0] <= elapsed <= window[1]:
        return 'FAIL', f, 'elapsed %.3fs outside [%.3f, %.3f]s' % (elapsed, *window)
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
        return 'PASS', f, ('elapsed %.3fs in [%.3f, %.3f]s' % (elapsed, *window) if window is not None else '')
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
        c = subprocess.run([hbc, name + '.prg', str(exe), TARGET, '--instrument'], cwd=cwd, capture_output=True)
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
        c = subprocess.run([hbc, str(src / ('test%d.prg' % t)), str(exe), TARGET], capture_output=True)
        if c.returncode:
            res.append(('REJ', 'dbf/test%d' % t, c.stderr.decode('latin-1').strip()[-200:])); continue
        import datetime
        pre_date = datetime.datetime.now(datetime.timezone.utc).date()
        r = subprocess.run([str(exe)], cwd=work, capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
        post_date = datetime.datetime.now(datetime.timezone.utc).date()
        exp = (src / ('test%d.linux.expected.txt' % t)).read_bytes()
        ok = r.stdout == exp and r.stderr == b'' and r.returncode == 0
        res.append(('PASS' if ok else 'FAIL', 'dbf/test%d' % t, '' if ok else 'rc=%s stdout=%r stderr=%r' % (r.returncode, r.stdout[:300], r.stderr[:200])))
        raw = (work / 'm_clie.dbf').read_bytes()
        if t in DBF_DATE_NORMALIZED:
            stamp = (raw[1], raw[2], raw[3])
            valid = {(d.year - 1900, d.month, d.day) for d in (pre_date, post_date)}
            if stamp not in valid:
                res[-1] = ('FAIL', 'dbf/test%d' % t, 'm_clie.dbf date bytes %s != run UTC date(s) %s' % (stamp, sorted(valid)))
            raw = raw[:1] + b'\0\0\0' + raw[4:]
        h = __import__('hashlib').sha256(raw).hexdigest()
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
        c = subprocess.run([hbc, str(src), str(exe), TARGET], capture_output=True)
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
    for n in ['apif64', 'apiecho', 'apiref', 'apistorref', 'apiitem', 'apiarr', 'apieval', 'extdemo', 'apithreads']:
        work = pathlib.Path(d) / ('ext_' + n)
        work.mkdir()
        srcs = ['extend/hbhbr.c', 'extend/demo/' + {'extdemo': 'myext', 'apithreads': 'apieval'}.get(n, n) + '.c']
        if n in ('apiref', 'apiitem', 'apistorref', 'apiarr', 'apieval', 'apithreads'):
            srcs.append('extend/demo/apif64.c')
        c = subprocess.run(['clang', '-O2', '-dynamiclib', '-undefined', 'dynamic_lookup', '-Iextend', *srcs, '-o', str(work / 'libhbext.dylib')], capture_output=True)
        if c.returncode:
            res.append(('FAIL', 'extend/' + n, 'clang: ' + c.stderr.decode('latin-1')[-300:])); continue
        c = subprocess.run([hbc, 'extend/demo/%s.prg' % n, str(work / 'prog'), TARGET], capture_output=True)
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
    ap.add_argument('--target', default='macho-arm64', choices=['macho-arm64', 'macho'])
    ap.add_argument('pattern', nargs='?')
    a = ap.parse_args()
    hbc = os.path.abspath(a.hbc)
    configure_target(a.target)
    if not a.pattern and not a.thread_ref:
        print('FAIL runner: the full battery needs --thread-ref (threads + EXTERNAL reference outputs); refusing to report a partial suite as green')
        return 1
    rows = [l.rstrip('\n') for l in open('tests/manifest.txt', encoding='latin-1')]
    rows = [l for l in rows if l.split(' ')[0] in KINDS]
    ids = [(l.split(' ')[0], l.split(' ')[1]) for l in rows]
    if len(set(ids)) != len(ids):
        dup = [i for i in ids if ids.count(i) > 1][0]
        print('FAIL runner: duplicate manifest identity %s' % (dup,))
        return 1
    if a.pattern:
        all_rows, rows = rows, [l for l in rows if re.search(a.pattern, l.split(' ')[1])]
        if not rows:
            print('FAIL runner: pattern %r matched no manifest rows; refusing to report an empty selection as green' % a.pattern)
            return 1
        print('PARTIAL battery: pattern %r selected %d of %d manifest rows; FILE/DBF/threads/EXTERNAL suites are skipped - this is not a full-suite green' % (a.pattern, len(rows), len(all_rows)))
    elif len(rows) != EXPECTED_MANIFEST_ROWS:
        print('FAIL runner: manifest has %d executable rows, expected inventory %d (truncated/empty manifest or stale runner constant)' % (len(rows), EXPECTED_MANIFEST_ROWS))
        return 1
    with tempfile.TemporaryDirectory() as d, cf.ThreadPoolExecutor(a.jobs) as ex:
        # (3) smoke: one compile+run with a known stdout before the battery,
        # so a broken compiler or host can never look like zero rows to run.
        smoke_prg = os.path.join(d, 'smoke.prg')
        open(smoke_prg, 'w').write(SMOKE_SOURCE)
        c0 = subprocess.run([hbc, smoke_prg, os.path.join(d, 'smoke'), TARGET], capture_output=True)
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
        if r[0] != 'PASS' or r[1] in IDLESLEEP_WINDOWS:
            print('%s %s %s' % r)
    c = collections.Counter(r[0] for r in res)
    print('SUMMARY', dict(c), '(PARTIAL pattern battery)' if a.pattern else '(FULL battery)')
    bad = 0
    if c.get('FAIL'):
        bad = 1
    unexpected_rej = [r for r in res if r[0] == 'REJ' and r[1] not in EXPECTED_REJ]
    if unexpected_rej:
        print('FAIL runner: %d unexpected REJ row(s)' % len(unexpected_rej))
        bad = 1
    if not a.pattern and EXPECTED_REJ:
        stale_rej = stale_named_rejections(res)
        if stale_rej:
            print('FAIL runner: %d named REJ row(s) did not reject with their diagnostic (stale EXPECTED_REJ): %s' % (len(stale_rej), stale_rej[0]))
            bad = 1
    if len(res) != expected:
        print('FAIL runner: suite total %d != expected %d' % (len(res), expected))
        bad = 1
    return bad


if __name__ == '__main__':
    sys.exit(main())

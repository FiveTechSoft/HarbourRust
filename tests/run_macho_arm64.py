#!/usr/bin/env python3
"""Native Apple Silicon battery for --target=macho-arm64.

Compiles every runnable manifest row (pos, posx, pos2, posx2, streams,
streams2), the FILE compatibility positives and the DBF acceptance tests
4-7 with the native ARM64 Mach-O backend, runs the executable on the
host and compares it with the Linux expectations using the same acceptance
rules as tests/run_battery.sh. Rows the backend rejects at compile time are
reported separately (REJ), never counted as passes.

Usage: python3 tests/run_macho_arm64.py [--hbc ./hbc] [--jobs N] [regex]
Exit status 0 only when no row FAILs.
"""
import argparse, codecs, collections, concurrent.futures as cf, os, re, subprocess, sys, tempfile

KINDS = ('pos', 'posx', 'pos2', 'posx2', 'streams', 'streams2')


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
        exp = rd(p[2]); ok = o == exp and e == rd(p[3])
    else:
        exp = rd(p[2]); ok = o == exp and e == rd(p[4])
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
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--hbc', default='./hbc')
    ap.add_argument('--jobs', type=int, default=os.cpu_count() or 4)
    ap.add_argument('pattern', nargs='?')
    a = ap.parse_args()
    hbc = os.path.abspath(a.hbc)
    rows = [l.rstrip('\n') for l in open('tests/manifest.txt', encoding='latin-1')]
    rows = [l for l in rows if l.split(' ')[0] in KINDS]
    if a.pattern:
        rows = [l for l in rows if re.search(a.pattern, l.split(' ')[1])]
    with tempfile.TemporaryDirectory() as d, cf.ThreadPoolExecutor(a.jobs) as ex:
        res = list(ex.map(lambda l: run_case(l, hbc, d), rows))
        if not a.pattern:
            res += file_suite(hbc, d) + dbf_suite(hbc, d)
    for r in res:
        if r[0] != 'PASS':
            print('%s %s %s' % r)
    c = collections.Counter(r[0] for r in res)
    print('SUMMARY', dict(c))
    return 1 if c.get('FAIL') else 0


if __name__ == '__main__':
    sys.exit(main())

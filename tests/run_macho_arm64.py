#!/usr/bin/env python3
"""Native Apple Silicon battery for --target=macho-arm64.

Compiles every runnable manifest row (pos, posx, pos2, posx2, streams,
streams2) with the native ARM64 Mach-O backend, runs the executable on the
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
    for r in res:
        if r[0] != 'PASS':
            print('%s %s %s' % r)
    c = collections.Counter(r[0] for r in res)
    print('SUMMARY', dict(c))
    return 1 if c.get('FAIL') else 0


if __name__ == '__main__':
    sys.exit(main())

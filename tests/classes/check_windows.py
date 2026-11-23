#!/usr/bin/env python3
"""Windows/PE class battery. Wine on Linux or real Windows; Python 3 provides
bounded process execution. Baselines are the Linux post-fix captures in
expected/, NOT a fresh Harbour oracle run on Windows. Windows console output
is CRLF (measured: tests/classes/windows-separators oracle fixtures captured
from official Harbour 3.2.1dev under Wine); this battery compares stdout
after mapping CRLF -> LF and records the raw byte counts per case so the
normalization stays visible in the evidence. Byte-exact CRLF parity is
covered separately and only by tests/classes/windows-separators.
Only evidence directories are written; the compiler is never modified.

Usage:
  python3 tests/classes/check_windows.py /path/to/hbc [--wine /path/to/wine]
  python3 tests/classes/check_windows.py /path/to/hbc --emit-only

--emit-only compiles and validates the PE32+ structure of every positive and
the named rejection of every negative, without executing anything: emission
evidence for hosts with no Windows runner (no Wine, no real Windows).
"""
from pathlib import Path
import argparse, hashlib, json, platform, struct, subprocess, sys, tempfile

def pe64_ok(exe):
    # Structural PE32+ validation: DOS header, COFF file header and the
    # PE32+ optional header, all bounds-checked. Any malformed or
    # truncated file answers False (a FAIL for the case), never an
    # exception aborting the battery.
    try:
        b = exe.read_bytes()
        if len(b) < 0x40 or b[:2] != b'MZ':
            return False
        lfanew = struct.unpack_from('<I', b, 0x3C)[0]
        if lfanew + 24 > len(b):  # signature (4) + COFF file header (20)
            return False
        if b[lfanew:lfanew+4] != b'PE\0\0':
            return False
        machine, nsec, _ts, _sym, _nsym, opt_size, _char = \
            struct.unpack_from('<HHIIIHH', b, lfanew+4)
        if machine != 0x8664 or nsec == 0:
            return False
        # PE32+ optional header: fixed part is 0x70 bytes plus data
        # directories, and must lie inside the file.
        if opt_size < 0x70 or lfanew + 24 + opt_size > len(b):
            return False
        if struct.unpack_from('<H', b, lfanew+24)[0] != 0x20B:
            return False
        # Section table follows the optional header (40 bytes per entry).
        if lfanew + 24 + opt_size + 40*nsec > len(b):
            return False
        return True
    except (OSError, struct.error, IndexError):
        return False

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('compiler', help='HarbourRust hbc executable built from the current checkout')
    ap.add_argument('--wine', help='Wine executable; omit on real Windows')
    ap.add_argument('--emit-only', action='store_true',
                    help='compile + PE structure + named rejections only, no execution')
    a = ap.parse_args()
    root = Path(__file__).resolve().parents[2]
    hbc = Path(a.compiler).resolve()
    if not hbc.is_file():
        sys.exit('Missing compiler: build hbc from the current checkout and pass its path.')
    work = Path(tempfile.mkdtemp(prefix='hbc-classes-windows.'))
    print('Evidence:', work, flush=True)
    inputs = root / 'tests/classes/programs'
    expected = root / 'tests/classes/expected'
    positive = {p.stem for p in expected.glob('*.out')}
    negative = dict(line.split('\t', 1) for line in (expected / 'rejections.tsv').read_text().splitlines())
    actual = {p.stem for p in inputs.glob('*.prg')}
    if len(positive) != 27 or len(negative) != 16 or positive & set(negative) or positive | set(negative) != actual:
        sys.exit('STOP: suite inventory mismatch (expected 27 runnable + 16 rejection cases).')
    paths = [hbc, root/'src/hbc.rs', root/'src/hrobj_blob.s', root/'src/hrobj_blob_win.s'] \
        + sorted(inputs.glob('*.prg')) + sorted(expected.iterdir())
    manifest = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    (work/'identity.json').write_text(json.dumps(
        {'machine': platform.platform(), 'compiler': str(hbc), 'wine': a.wine,
         'emit_only': a.emit_only, 'sha256': manifest}, indent=2))

    def run(cmd, label, limit):
        try:
            p = subprocess.run([str(x) for x in cmd], cwd=root, capture_output=True, timeout=limit)
            rc, out, err = p.returncode, p.stdout, p.stderr
        except subprocess.TimeoutExpired as e:
            rc, out, err = 124, e.stdout or b'', (e.stderr or b'') + b'\nTIMEOUT\n'
        except OSError as e:
            rc, out, err = 127, b'', str(e).encode()
        for suffix, data in [('stdout', out), ('stderr', err), ('rc', str(rc).encode())]:
            (work/(label+'.'+suffix)).write_bytes(data)
        return rc, out, err

    run([hbc, '--version'], 'version', 15)
    failed = []
    for name in sorted(actual):
        exe = work/(name + '.exe')
        rc, out, err = run([hbc, inputs/(name+'.prg'), exe, '--target=windows', '-I', root/'tests'],
                           name+'.compile', 60)
        if name in negative:
            ok = rc == 1 and negative[name].encode() in err and b'panic' not in err.lower()
        elif rc != 0:
            ok = False
        else:
            ok = exe.is_file() and pe64_ok(exe)
            if ok and not a.emit_only:
                rc, out, err = run(([a.wine] if a.wine else []) + [exe], name+'.run', 20)
                crlf = out.count(b'\r\n')
                bare_cr = out.replace(b'\r\n', b'').count(b'\r')
                (work/(name+'.crlf')).write_text(f'crlf={crlf} bare_cr={bare_cr}\n')
                ok = (rc == 0 and not err and bare_cr == 0
                      and out.replace(b'\r\n', b'\n') == (expected/(name+'.out')).read_bytes())
        print(('PASS ' if ok else 'FAIL ') + name, flush=True)
        if not ok:
            failed.append(name)
    mode = 'emit-only' if a.emit_only else ('wine' if a.wine else 'native')
    print(f'windows class battery ({mode}): {43-len(failed)} pass, {len(failed)} fail (of 43)')
    if failed:
        print('FAILED:', ', '.join(failed))
    sys.exit(bool(failed))

if __name__ == '__main__':
    main()

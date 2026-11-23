#!/usr/bin/env python3
"""Windows differential class gate: HarbourRust vs official Harbour, both as
Windows PE programs under Wine (or on real Windows with a native hbmk2).

Unlike tests/classes/check_windows.py (which compares against the Linux
baseline captures after CRLF -> LF normalization), this gate compiles every
runnable probe with the official Windows hbmk2.exe and runs BOTH executables
in the same environment, comparing stdout/stderr/exit byte for byte with no
normalization. With --write-fixtures the oracle streams are versioned into
tests/classes/expected-windows/ so later runs only need the candidate side.

Declared-limit and negative probes must run under Harbour and be a named
compile-time rejection under HarbourRust (same expectations as the Linux
differential gate).

--emit-only covers hosts with no Windows runner (no Wine, no Windows
hbmk2.exe): HarbourRust compilation, PE32+ structure and named rejections
only. Emission evidence, not execution.

Usage:
  python3 tests/classes/check_windows_differential.py /path/to/hbc \
      --hbmk2-win /path/to/windows/hbmk2.exe --wine /path/to/wine [--write-fixtures]
  python3 tests/classes/check_windows_differential.py /path/to/hbc --emit-only
"""
from pathlib import Path
import argparse, hashlib, json, platform, struct, subprocess, sys, tempfile

POSITIVE = ["p01_defaults","p02_nil_default","p04_method_ret","p05_method_over_data",
    "p09","p10_init_per_inst","p10b_init_rerun","p11_sharing_assign","p12_sharing_param",
    "p13_virtual","p14_inherit_data","p15_inherit_method","p16","p17_arity","p18_identity",
    "p22_nodata","p23_print_obj","p24_param_virtual","p25_stress","p_sep","neg4",
    "t1","t1b","t2","t3","t4","neg15_dyn_concat"]
DECLARED_LIMITS = ["p03_readwrite", "p07_self_chain", "p21_multi_inherit"]
NEGATIVES = ["neg1","neg2","neg3","neg5","neg6","neg7","neg8","neg9","neg10",
    "neg11","neg12","neg13","neg14_ambig_member"]

def pe64_ok(exe):
    b = exe.read_bytes()
    if len(b) < 0x40 or b[:2] != b'MZ':
        return False
    lfanew = struct.unpack_from('<I', b, 0x3C)[0]
    return b[lfanew:lfanew+4] == b'PE\0\0' and struct.unpack_from('<H', b, lfanew+4)[0] == 0x8664

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('compiler', help='HarbourRust hbc built from the current checkout')
    ap.add_argument('--hbmk2-win', help='official Harbour Windows hbmk2.exe (with its install tree)')
    ap.add_argument('--wine', help='Wine executable; omit only on real Windows')
    ap.add_argument('--write-fixtures', action='store_true',
                    help='version the oracle streams into tests/classes/expected-windows/')
    ap.add_argument('--emit-only', action='store_true',
                    help='HarbourRust emission + named rejections only, no execution')
    a = ap.parse_args()
    root = Path(__file__).resolve().parents[2]
    hbc = Path(a.compiler).resolve()
    if not hbc.is_file():
        sys.exit('Missing compiler: build hbc from the current checkout and pass its path.')
    if not a.emit_only and not a.hbmk2_win:
        sys.exit('STOP: full mode needs --hbmk2-win (and --wine off Windows). Use --emit-only without a runner.')
    hbmk2 = Path(a.hbmk2_win).resolve() if a.hbmk2_win else None
    if hbmk2 and not hbmk2.is_file():
        sys.exit(f'Missing Windows hbmk2.exe: {hbmk2}')
    inputs = root / 'tests/classes/programs'
    expected = root / 'tests/classes/expected'
    fixtures = root / 'tests/classes/expected-windows'
    negative = dict(line.split('\t', 1) for line in (expected / 'rejections.tsv').read_text().splitlines())
    actual = {p.stem for p in inputs.glob('*.prg')}
    if set(POSITIVE) | set(DECLARED_LIMITS) | set(NEGATIVES) != actual or len(actual) != 43:
        sys.exit('STOP: suite inventory mismatch (expected 27 runnable + 3 declared limits + 13 negatives).')
    work = Path(tempfile.mkdtemp(prefix='hbc-classes-windows-diff.'))
    print('Evidence:', work, flush=True)
    paths = [hbc, root/'src/hbc.rs'] + ([hbmk2] if hbmk2 else []) \
        + sorted(inputs.glob('*.prg')) + sorted(expected.iterdir())
    (work/'identity.json').write_text(json.dumps(
        {'machine': platform.platform(), 'compiler': str(hbc), 'hbmk2_win': str(hbmk2),
         'wine': a.wine, 'emit_only': a.emit_only,
         'sha256': {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}}, indent=2))

    runner = [a.wine] if a.wine else []
    def run(cmd, label, limit):
        try:
            p = subprocess.run([str(x) for x in cmd], cwd=work, capture_output=True, timeout=limit)
            rc, out, err = p.returncode, p.stdout, p.stderr
        except subprocess.TimeoutExpired as e:
            rc, out, err = 124, e.stdout or b'', (e.stderr or b'') + b'\nTIMEOUT\n'
        except OSError as e:
            rc, out, err = 127, b'', str(e).encode()
        for suffix, data in [('stdout', out), ('stderr', err), ('rc', str(rc).encode())]:
            (work/(label+'.'+suffix)).write_bytes(data)
        return rc, out, err

    failed = []
    for name in sorted(actual):
        src = inputs/(name + '.prg')
        cand = work/(name + '.exe')
        rc, out, err = run([hbc, src, cand, '--target=windows', '-I', root/'tests'],
                           name + '.hbc.compile', 60)
        if name in NEGATIVES or name in DECLARED_LIMITS:
            # Harbour runs these; HarbourRust must answer the named rejection.
            ok = rc == 1 and negative[name].encode() in err and b'panic' not in err.lower()
            if ok and not a.emit_only:
                oracle = work/(name + '_hb.exe')
                orc, oout, oerr = run(runner + [hbmk2, '-quiet', '-gtstd', '-w0',
                                                '-o' + str(oracle), src], name + '.hb.compile', 300)
                ok = orc == 0 and oracle.is_file()
                if ok:
                    orc, oout, oerr = run(runner + [oracle], name + '.hb.run', 20)
                    ok = orc == 0
        else:
            ok = rc == 0 and cand.is_file() and pe64_ok(cand)
            if ok and not a.emit_only:
                oracle = work/(name + '_hb.exe')
                orc, oout, oerr = run(runner + [hbmk2, '-quiet', '-gtstd', '-w0',
                                                '-o' + str(oracle), src], name + '.hb.compile', 300)
                ok = orc == 0 and oracle.is_file()
                if ok:
                    orc, oout, oerr = run(runner + [oracle], name + '.hb.run', 20)
                    crc, cout, cerr = run(runner + [cand], name + '.hbc.run', 20)
                    ok = (crc == orc == 0 and cout == oout and cerr == oerr)
                    if ok and a.write_fixtures:
                        fixtures.mkdir(exist_ok=True)
                        (fixtures/(name + '.out')).write_bytes(oout)
        print(('PASS ' if ok else 'FAIL ') + name, flush=True)
        if not ok:
            failed.append(name)
    mode = 'emit-only' if a.emit_only else ('wine' if a.wine else 'native')
    print(f'windows differential class gate ({mode}): {43-len(failed)} pass, {len(failed)} fail (of 43)')
    if failed:
        print('FAILED:', ', '.join(failed))
    sys.exit(bool(failed))

if __name__ == '__main__':
    main()

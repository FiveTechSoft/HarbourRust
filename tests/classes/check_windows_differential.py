#!/usr/bin/env python3
"""Windows differential class gate: HarbourRust vs official Harbour, both as
Windows PE programs under Wine (or on real Windows with a native hbmk2).

Unlike tests/classes/check_windows.py (which compares against the Linux
baseline captures after CRLF -> LF normalization), this gate compiles every
runnable probe with the official Windows hbmk2.exe and runs BOTH executables
in the same environment, comparing stdout/stderr/exit byte for byte with no
normalization.

Oracle scope per probe set (same policy as the Linux differential gate):
- 27 runnable probes: Harbour compiles and runs them; HarbourRust must
  compile, run and match byte for byte.
- 3 declared-limit probes (p03_readwrite, p07_self_chain,
  p21_multi_inherit): Harbour compiles and runs them with rc 0;
  HarbourRust answers the recorded named compile-time rejection.
- 13 named negatives: only HarbourRust is exercised; it must answer the
  recorded named rejection. Harbour is NOT required to reject or run them
  (several are programs Harbour compiles fine; the named rejection is a
  HarbourRust increment limit, not a Harbour error).

--write-fixtures versions the oracle streams (stdout, stderr, exit code)
of the 27 runnable probes into tests/classes/expected-windows/. With those
fixtures present, the gate runs in replay mode: no --hbmk2-win needed, the
candidate runs are compared against the versioned oracle streams. Replay
still needs a runner for the candidate (Wine off Windows).

--emit-only covers hosts with no Windows runner (no Wine, no Windows
hbmk2.exe): HarbourRust compilation, PE32+ structure and named rejections
only. Emission evidence, not execution.

Usage:
  python3 tests/classes/check_windows_differential.py /path/to/hbc \
      --hbmk2-win /path/to/windows/hbmk2.exe --wine /path/to/wine [--write-fixtures]
  python3 tests/classes/check_windows_differential.py /path/to/hbc --wine /path/to/wine   # replay
  python3 tests/classes/check_windows_differential.py /path/to/hbc --emit-only
"""
from pathlib import Path
import argparse, hashlib, json, platform, subprocess, sys, tempfile

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_windows import pe64_ok  # shared hardened PE32+ validator (review S1)

POSITIVE = ["p01_defaults","p02_nil_default","p04_method_ret","p05_method_over_data",
    "p09","p10_init_per_inst","p10b_init_rerun","p11_sharing_assign","p12_sharing_param",
    "p13_virtual","p14_inherit_data","p15_inherit_method","p16","p17_arity","p18_identity",
    "p22_nodata","p23_print_obj","p24_param_virtual","p25_stress","p_sep","neg4",
    "t1","t1b","t2","t3","t4","neg15_dyn_concat"]
DECLARED_LIMITS = ["p03_readwrite", "p07_self_chain", "p21_multi_inherit"]
NEGATIVES = ["neg1","neg2","neg3","neg5","neg6","neg7","neg8","neg9","neg10",
    "neg11","neg12","neg13","neg14_ambig_member"]

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('compiler', help='HarbourRust hbc built from the current checkout')
    ap.add_argument('--hbmk2-win', help='official Harbour Windows hbmk2.exe (with its install tree)')
    ap.add_argument('--wine', help='Wine executable; required off Windows in full and replay modes')
    ap.add_argument('--write-fixtures', action='store_true',
                    help='version the oracle stdout/stderr/rc of the runnable probes into '
                         'tests/classes/expected-windows/')
    ap.add_argument('--emit-only', action='store_true',
                    help='HarbourRust emission + named rejections only, no execution')
    a = ap.parse_args()
    root = Path(__file__).resolve().parents[2]
    hbc = Path(a.compiler).resolve()
    if not hbc.is_file():
        sys.exit('Missing compiler: build hbc from the current checkout and pass its path.')
    inputs = root / 'tests/classes/programs'
    expected = root / 'tests/classes/expected'
    fixtures = root / 'tests/classes/expected-windows'
    negative = dict(line.split('\t', 1) for line in (expected / 'rejections.tsv').read_text().splitlines())
    actual = {p.stem for p in inputs.glob('*.prg')}
    if set(POSITIVE) | set(DECLARED_LIMITS) | set(NEGATIVES) != actual or len(actual) != 43:
        sys.exit('STOP: suite inventory mismatch (expected 27 runnable + 3 declared limits + 13 negatives).')

    # Runner validation: explicit STOP, never a FAIL rc 127.
    hbmk2 = None
    replay = False
    if not a.emit_only:
        on_windows = platform.system() == 'Windows'
        if not on_windows and not a.wine:
            sys.exit('STOP: running PE programs off Windows needs --wine (or use --emit-only).')
        if a.wine and not Path(a.wine).is_file():
            sys.exit(f'STOP: Wine executable not found: {a.wine}')
        if a.hbmk2_win:
            hbmk2 = Path(a.hbmk2_win).resolve()
            if not hbmk2.is_file():
                sys.exit(f'STOP: Windows hbmk2.exe not found: {hbmk2}')
        else:
            have = {p.stem for p in fixtures.glob('*.out')} if fixtures.is_dir() else set()
            have &= {p.stem for p in fixtures.glob('*.err')} & {p.stem for p in fixtures.glob('*.rc')}
            if not set(POSITIVE) <= have:
                sys.exit('STOP: no --hbmk2-win and no complete versioned fixtures in '
                         'tests/classes/expected-windows/ (capture them with --write-fixtures).')
            replay = True
    elif a.wine or a.hbmk2_win:
        print('note: --emit-only ignores --wine/--hbmk2-win', flush=True)

    work = Path(tempfile.mkdtemp(prefix='hbc-classes-windows-diff.'))
    print('Evidence:', work, flush=True)
    paths = [hbc, root/'src/hbc.rs'] + ([hbmk2] if hbmk2 else []) \
        + sorted(inputs.glob('*.prg')) + sorted(expected.iterdir())
    if replay:
        paths += sorted(fixtures.iterdir())
    (work/'identity.json').write_text(json.dumps(
        {'machine': platform.platform(), 'compiler': str(hbc), 'hbmk2_win': str(hbmk2),
         'wine': a.wine, 'emit_only': a.emit_only, 'replay': replay,
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
        if name in NEGATIVES:
            # HarbourRust increment limit; Harbour is not exercised.
            ok = rc == 1 and negative[name].encode() in err and b'panic' not in err.lower()
        elif name in DECLARED_LIMITS:
            ok = rc == 1 and negative[name].encode() in err and b'panic' not in err.lower()
            if ok and not a.emit_only and not replay:
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
                crc, cout, cerr = run(runner + [cand], name + '.hbc.run', 20)
                if replay:
                    ok = (cout == (fixtures/(name + '.out')).read_bytes()
                          and cerr == (fixtures/(name + '.err')).read_bytes()
                          and str(crc).encode() == (fixtures/(name + '.rc')).read_bytes())
                else:
                    oracle = work/(name + '_hb.exe')
                    orc, oout, oerr = run(runner + [hbmk2, '-quiet', '-gtstd', '-w0',
                                                    '-o' + str(oracle), src], name + '.hb.compile', 300)
                    ok = orc == 0 and oracle.is_file()
                    if ok:
                        orc, oout, oerr = run(runner + [oracle], name + '.hb.run', 20)
                        ok = crc == orc and cout == oout and cerr == oerr
                        if ok and a.write_fixtures:
                            fixtures.mkdir(exist_ok=True)
                            (fixtures/(name + '.out')).write_bytes(oout)
                            (fixtures/(name + '.err')).write_bytes(oerr)
                            (fixtures/(name + '.rc')).write_text(str(orc))
        print(('PASS ' if ok else 'FAIL ') + name, flush=True)
        if not ok:
            failed.append(name)
    mode = 'emit-only' if a.emit_only else ('replay' if replay else 'differential')
    print(f'windows differential class gate ({mode}): {43-len(failed)} pass, {len(failed)} fail (of 43)')
    if failed:
        print('FAILED:', ', '.join(failed))
    sys.exit(bool(failed))

if __name__ == '__main__':
    main()

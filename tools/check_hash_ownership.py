#!/usr/bin/env python3
"""Check hash string ownership against pinned expected channels and the real registry.

Windows runs compare the Linux GTSTD oracle contract, not a native Windows oracle.
See docs/HASH-STRING-OWNERSHIP-2026-11-14.md for the oracle shim and limits.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True)
    ap.add_argument('--output', required=True, help='JSON evidence file')
    ap.add_argument('--wine', help='also check Windows with this Wine executable')
    ap.add_argument('--wine-prefix')
    a = ap.parse_args()
    repo = Path(__file__).resolve().parents[1]
    compiler = Path(a.compiler).resolve()
    rows = []
    env = dict(os.environ, WINEDEBUG='-all')
    if a.wine_prefix:
        env['WINEPREFIX'] = a.wine_prefix
    sources = sorted((repo / 'tests/hash-ownership').glob('*.prg'))
    if len(sources) != 28:
        raise SystemExit('Expected 28 ownership fixtures; inspect changes before updating this check')
    with tempfile.TemporaryDirectory(prefix='hbc-hash-ownership-') as scratch:
        for src in sources:
            for target in (['linux', 'windows'] if a.wine else ['linux']):
                for instrument in (False, True):
                    exe = Path(scratch) / ('probe.exe' if target == 'windows' else 'probe')
                    row = dict(source=str(src.relative_to(repo)),
                               source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),
                               target=target, instrument=instrument, **{'pass': False})
                    try:
                        p = subprocess.run([str(compiler), str(src), str(exe), '--target=' + target]
                                           + (['--instrument'] if instrument else []),
                                           cwd=repo, capture_output=True, timeout=30)
                        row.update(compile_rc=p.returncode, compile_stdout=p.stdout.hex(),
                                   compile_stderr=p.stderr.hex())
                        if p.returncode == 0:
                            p = subprocess.run(([a.wine] if target == 'windows' else []) + [str(exe)],
                                               cwd=repo, capture_output=True, timeout=10,
                                               stdin=subprocess.DEVNULL, env=env)
                            expected = src.with_suffix('.stdout').read_bytes()
                            row.update(rc=p.returncode, stdout=p.stdout.hex(), stderr=p.stderr.hex())
                            # Every fixture calls the compiler's real hb_memcheck after work returns.
                            # Compare exact bytes, including its final zero, not only process rc.
                            row['pass'] = (p.returncode == 0 and p.stdout == expected
                                           and p.stderr == src.with_suffix('.stderr').read_bytes())
                    except subprocess.TimeoutExpired as e:
                        row.update(timeout=True, timeout_stdout=(e.stdout or b'').hex(),
                                   timeout_stderr=(e.stderr or b'').hex())
                    finally:
                        exe.unlink(missing_ok=True)
                    rows.append(row)
                    if not row['pass']:
                        print('FAIL', row)
    output = Path(a.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(compiler.read_bytes()).hexdigest(),
                                      oracle_pin='694428e1c12f726675b19324d62167fa77d68185',
                                      rows=rows), indent=2) + '\n')
    print('PASS', sum(r['pass'] for r in rows), '/', len(rows))
    return 0 if all(r['pass'] for r in rows) else 1


if __name__ == '__main__':
    raise SystemExit(main())

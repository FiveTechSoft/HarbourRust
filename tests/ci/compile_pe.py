#!/usr/bin/env python3
"""Compile every root manifest case to PE assembly, without executing PE.
Known front-end mismatches are explicit debt, not green runtime claims.
No Harbour, Wine, shell, binutils or platform-dependent path text needed.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
KINDS = {'pos', 'pos2', 'posx', 'posx2', 'streams', 'streams2', 'neg', 'cli'}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True)
    ap.add_argument('--output', required=True, help='new evidence directory')
    ap.add_argument('--known-mismatches', type=Path,
                    default=ROOT / 'tests/ci/pe-known-mismatches.json')
    a = ap.parse_args()
    hbc = Path(a.compiler).resolve()
    out = Path(a.output).resolve()
    out.mkdir(parents=True, exist_ok=False)
    manifest = ROOT / 'tests/manifest.txt'
    known_rows = json.loads(a.known_mismatches.read_text())['cases']
    known = {(x['kind'], x['source']): x for x in known_rows}
    if len(known) != len(known_rows):
        raise ValueError('duplicate known-mismatch key')
    seen, records, failures = set(), [], []
    asm = out / 'probe.s'
    for number, line in enumerate(manifest.read_text(encoding='utf-8').splitlines(), 1):
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        parts = line.split(maxsplit=2)
        if len(parts) < 2 or parts[0] not in KINDS:
            raise ValueError(f'unknown or malformed manifest row {number}: {line}')
        kind, source = parts[:2]
        rest = parts[2] if len(parts) == 3 else ''
        # Same logical-retag source is compiled on PE, whose profile guard fires first.
        if kind == 'neg' and source == 'tests/t1613_startup_neg_static.prg':
            rest = 'INIT STATIC platform guard'
        key = (kind, source)
        if key in seen:
            raise ValueError(f'duplicate manifest key at {number}: {key}')
        seen.add(key)
        src = ROOT / source
        if not src.is_file():
            raise ValueError(f'missing manifest input: {source}')
        asm.unlink(missing_ok=True)
        if kind == 'cli':
            # Current CLI fixture uses individual flags, with no shell syntax.
            cmd = [str(hbc), *rest.split()]
        else:
            cmd = [str(hbc), source, str(asm), '--target=windows', '--instrument', '-I', 'tests']
        try:
            p = subprocess.run(cmd, cwd=ROOT, capture_output=True, timeout=15)
        except subprocess.TimeoutExpired as e:
            p = subprocess.CompletedProcess(cmd, 124, e.stdout or b'', (e.stderr or b'') + b'\nTIMEOUT\n')
        except OSError as e:
            p = subprocess.CompletedProcess(cmd, 127, b'', str(e).encode())
        err = p.stderr.decode('utf-8', 'replace')
        fatal = p.returncode not in (0, 1) or 'panicked' in err.lower()
        if kind == 'cli':
            ok = p.returncode == 0 and not p.stderr and p.stdout == src.read_bytes()
        elif kind == 'neg':
            ok = p.returncode == 1 and p.stderr.startswith(b'error:') and rest.encode('utf-8') in p.stderr
        else:
            ok = p.returncode == 0 and asm.is_file() and asm.stat().st_size > 0
        debt = known.get(key)
        if debt:
            matched = (not fatal and not ok and p.returncode == debt['rc']
                       and err == debt['stderr'] and digest(src) == debt['source_sha256']
                       and (p.returncode != 0 or (asm.is_file() and asm.stat().st_size > 0)))
            if matched:
                status = 'KNOWN-MISMATCH'
            else:
                status = 'FAIL'
                failures.append(f'{source}: known mismatch changed or fixed; review debt entry')
        elif ok and not fatal:
            status = 'PASS'
        else:
            status = 'FAIL'
            failures.append(f'{source}: unexpected compiler/CLI outcome rc={p.returncode}')
        record = {'line': number, 'kind': kind, 'source': source,
                  'status': status, 'rc': p.returncode}
        records.append(record)
        if status != 'PASS':
            print(f'{status}: {kind} {source} rc={p.returncode}', flush=True)
        if status == 'FAIL':
            (out / f'case-{number}.stdout').write_bytes(p.stdout)
            (out / f'case-{number}.stderr').write_bytes(p.stderr)
            print(err[:4000], flush=True)
    for key in sorted(set(known) - seen):
        failures.append(f'stale known-mismatch entry: {key}')
    counts = {s: sum(x['status'] == s for x in records)
              for s in ['PASS', 'KNOWN-MISMATCH', 'FAIL']}
    report = {'compiler_sha256': digest(hbc), 'manifest_sha256': digest(manifest),
              'known_mismatches_sha256': digest(a.known_mismatches),
              'counts': counts, 'records': records, 'failures': failures,
              'scope': 'PE assembly emission / diagnostics / CLI only; no PE execution'}
    (out / 'result.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'records'}, indent=2))
    return bool(failures)


if __name__ == '__main__':
    sys.exit(main())

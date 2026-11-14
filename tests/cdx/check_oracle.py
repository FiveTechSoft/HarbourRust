#!/usr/bin/env python3
"""Linux read-only CDX differential gate. Requires an external real Harbour hbmk2.
Only the fixture builders use writes; they are compiled by Harbour, never hbc.
No network, installed-runtime changes, or repository fixture mutation.
"""
from pathlib import Path
import argparse, json, shutil, subprocess, tempfile, gzip


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True, help='HarbourRust hbc executable')
    ap.add_argument('--hbmk2', required=True, help='external official Harbour hbmk2')
    ap.add_argument('--output', help='new directory for full evidence; defaults to a temporary directory')
    args = ap.parse_args()
    compiler = Path(args.compiler).resolve()
    hbmk2 = Path(args.hbmk2).resolve()
    inputs = Path(__file__).resolve().parent
    if args.output:
        output = Path(args.output).resolve()
        output.mkdir(parents=True, exist_ok=False)
    else:
        output = Path(tempfile.mkdtemp(prefix='harbourrust-cdx-'))
    print('Evidence:', output, flush=True)

    def run(cmd, cwd, label):
        p = subprocess.run([str(v) for v in cmd], cwd=cwd, capture_output=True, timeout=60)
        for suffix, data in [('stdout', p.stdout), ('stderr', p.stderr), ('rc', str(p.returncode).encode())]:
            (cwd / (label + '.' + suffix)).write_bytes(data)
        return p

    def require(cmd, cwd, label):
        p = run(cmd, cwd, label)
        if p.returncode:
            raise RuntimeError(f'{label} failed ({p.returncode}); see {cwd}')
        return p

    fixtures = output / 'fixtures'
    fixtures.mkdir()
    for name in ['fixtures', 'variants', 'wide-fixture', 'deep-fixture']:
        shutil.copyfile(inputs / (name + '.prg'), fixtures / (name + '.prg'))
        require([hbmk2, name + '.prg', '-gtstd', '-o' + name], fixtures, name + '-build')
        require([fixtures / name], fixtures, name + '-run')
        (fixtures/name).unlink()
    rows = []
    for source in sorted((inputs / 'programs').glob('*.prg')):
        case = output / source.stem
        case.mkdir()
        shutil.copyfile(source, case / 'probe.prg')
        for pattern in ['*.dbf', '*.cdx']:
            for fixture in fixtures.glob(pattern):
                shutil.copyfile(fixture, case / fixture.name)
        require([hbmk2, 'probe.prg', '-gtstd', '-ooracle'], case, 'oracle-build')
        oracle = require([case / 'oracle'], case, 'oracle')
        for mode, flags in [('normal', []), ('instrument', ['--instrument'])]:
            require([compiler, 'probe.prg', mode + '.s', '--target=linux', *flags], case, mode + '-compile')
            require(['as', mode + '.s', '-o', mode + '.o'], case, mode + '-as')
            require(['ld', mode + '.o', '-o', mode], case, mode + '-ld')
            candidate = run([case / mode], case, mode + '-run')
            exact = (candidate.returncode, candidate.stdout, candidate.stderr) == (oracle.returncode, oracle.stdout, oracle.stderr)
            row = {'program': source.name, 'mode': mode, 'byte_exact': exact}
            rows.append(row)
            (output / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
            print(row, flush=True)
            if not exact:
                raise RuntimeError(f'oracle mismatch: {case}, {mode}')
            with gzip.open(case/(mode+'.s.gz'),'wb') as z:z.write((case/(mode+'.s')).read_bytes())
            for p in [case/mode,case/(mode+'.o'),case/(mode+'.s')]:p.unlink()
        (case/'oracle').unlink()
    print(f'PASS {len(rows)}/{len(rows)} paired executions ({len(rows)//2} same-source programs)')


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Check TRY trace restoration against real Harbour sequence forms.

Harbour sources differ only by TRY/CATCH/FINALLY syntax expansion, with
identical line counts. Native Windows/Mac are not exercised by this script.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--compiler', type=Path, required=True)
p.add_argument('--hbmk2', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
p.add_argument('--wine', type=Path)
p.add_argument('--wine-prefix', type=Path)
a = p.parse_args()
a.compiler = a.compiler.resolve()
a.hbmk2 = a.hbmk2.resolve()
a.output = a.output.resolve()
a.output.mkdir(parents=True, exist_ok=False)
root = Path(__file__).resolve().parent
env = dict(os.environ, WINEDEBUG='-all')
if a.wine_prefix:
    env['WINEPREFIX'] = str(a.wine_prefix.resolve())
rows = []


def run(cmd):
    return subprocess.run(list(map(str, cmd)), capture_output=True, timeout=30, env=env)


for name in ['simple', 'nested', 'finally-rethrow', 'repeated', 'normal', 'line', 'capacity']:
    src = root / (name + '.prg')
    oracle = root / (name + '-hb.prg')
    expanded = src.read_text().replace('try\n', 'begin sequence with {|err| Break(err)}\n')
    expanded = expanded.replace('catch e\n', 'recover using e\n')
    expanded = expanded.replace('finally\n', 'always\n').replace('\nend\n', '\nend sequence\n')
    assert expanded == oracle.read_text(), ('oracle syntax drift', name)
    assert len(expanded.splitlines()) == len(src.read_text().splitlines())
    exe = a.output / (name + '.harbour')
    q = run([a.hbmk2, oracle, '-quiet', '-gtstd', '-o' + str(exe)])
    (a.output / (name + '.hb-build.log')).write_bytes(q.stdout + q.stderr)
    assert q.returncode == 0, (name, q.stderr)
    z = run([exe])
    assert (z.returncode, z.stderr) == (0, b''), (name, z.returncode, z.stderr)
    assert z.stdout == (root / (name + '.stdout')).read_bytes(), ('oracle expectation changed', name)
    for target in ['linux'] + (['windows'] if a.wine else []):
        for instrument in [False, True]:
            label = name + '-' + target + ('-instrument' if instrument else '-normal')
            exe = a.output / (label + '.program')
            q = run([a.compiler, src, exe, '--target=' + target]
                    + (['--instrument'] if instrument else []))
            (a.output / (label + '.compile.stderr')).write_bytes(q.stderr)
            assert q.returncode == 0, (label, q.stderr)
            q = run([a.wine, exe] if target == 'windows' else [exe])
            (a.output / (label + '.stdout')).write_bytes(q.stdout)
            (a.output / (label + '.stderr')).write_bytes(q.stderr)
            assert (q.returncode, q.stdout, q.stderr) == (z.returncode, z.stdout, z.stderr), (
                label, q.returncode, q.stdout, z.stdout, q.stderr)
            rows.append({'name': name, 'target': target, 'instrument': instrument,
                         'stdout_exact': True, 'stderr_empty': True, 'exit': 0})
            print(label, 'exact', flush=True)

summary = {'compiler_sha256': hashlib.sha256(a.compiler.read_bytes()).hexdigest(),
           'program_pairs': 7, 'rows': rows,
           'limits': 'No owned cleanup, native Windows/Mac or thread/sequence admission claim'}
(a.output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print('PASS', len(rows), 'exact executions')

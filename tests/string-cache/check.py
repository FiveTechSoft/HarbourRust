#!/usr/bin/env python3
"""Fresh Harbour capacity/collision/MT oracles and final ownership checks.

Optional Wine runs are PE under Wine, not native Windows. Repeats do not
prove all thread schedules. Run directories must be new. No binaries shipped.
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
for key in ['compiler', 'hbmk2', 'output']:
    setattr(a, key, getattr(a, key).resolve())
a.output.mkdir(parents=True, exist_ok=False)
root = Path(__file__).resolve().parent
env = dict(os.environ, WINEDEBUG='-all')
if a.wine_prefix:
    env['WINEPREFIX'] = str(a.wine_prefix.resolve())
rows = []


def run(cmd):
    return subprocess.run(list(map(str, cmd)), capture_output=True, timeout=60, env=env)


def build(cmd, label):
    q = run(cmd)
    (a.output / (label + '.build.log')).write_bytes(q.stdout + q.stderr)
    assert q.returncode == 0, (label, q.returncode, q.stderr)


def oracle(src, name, mt=False):
    exe = a.output / (name + '.harbour')
    build([a.hbmk2, src, '-quiet', '-gtstd', '-o' + str(exe)] + (['-mt'] if mt else []), name + '-hb')
    q = run([exe])
    assert (q.returncode, q.stderr) == (0, b''), (name, q.returncode, q.stderr)
    (a.output / (name + '.oracle.stdout')).write_bytes(q.stdout)
    exe.unlink()
    return q.stdout


def paired(src, name, expected, memory=False, targets=None, repeats=1, modes=(False, True)):
    for target in targets or (['linux', 'windows'] if a.wine else ['linux']):
        for instrument in modes:
            label = name + '-' + target + ('-instrument' if instrument else '-normal')
            exe = a.output / (label + '.program')
            build([a.compiler, src, exe, '--target=' + target] + (['--instrument'] if instrument else []), label)
            for n in range(repeats):
                q = run([a.wine, exe] if target == 'windows' else [exe])
                (a.output / (label + '-' + str(n) + '.stdout')).write_bytes(q.stdout)
                (a.output / (label + '-' + str(n) + '.stderr')).write_bytes(q.stderr)
                assert (q.returncode, q.stdout, q.stderr) == (0, expected, b''), (label, n, q.returncode, q.stdout, q.stderr)
                rows.append(dict(name=name, target=target, instrument=instrument,
                                 repeat=n, exact=True, final_memcheck0=memory))
            exe.unlink()


for name in ['capacity', 'eviction']:
    src = root / (name + '.prg')
    expected = oracle(src, name)
    if name == 'capacity':
        assert expected == (root / 'capacity.stdout').read_bytes()
    paired(src, name, expected)
    wrapper = a.output / (name + '-memory.prg')
    wrapper.write_text(src.read_text().replace('Work()\nreturn', 'Work()\n? hb_memcheck()\nreturn', 1))
    paired(wrapper, name + '-memory', expected + b'\n         0', memory=True)

# Two simultaneous workers, each 1000 x 4096-byte copies, five repetitions
# Five normal-mode repetitions. Instrumented MT is not admitted by hbc.
# MT sequence/TRY is deliberately not exercised.
expected = oracle(root / 'thread-cache.prg', 'thread-cache', mt=True)
paired(root / 'thread-cache.prg', 'thread-cache', expected, targets=['linux'], repeats=5, modes=(False,))
q = run([a.compiler, root / 'thread-cache.prg', a.output / 'thread-instrument-neg', '--instrument'])
assert q.returncode != 0 and b'--instrument is not supported with threads' in q.stderr
(a.output / 'thread-instrument-neg.stderr').write_bytes(q.stderr)
rows.append(dict(name='thread-instrument-neg', rejected=True))
# Re-run the fixed ERP string/numeric fixtures from this base against a fresh
# Harbour oracle. These are separate from the unchanged full manifest.
for src in sorted((root.parent / 'erpstring').glob('*.prg')):
    if src.name.endswith('_neg.prg'):
        continue
    expected = oracle(src, src.stem)
    assert expected == src.with_suffix('.expected').read_bytes(), src
    paired(src, src.stem, expected)
negative = root.parent / 'erpstring' / 'erp_int_numlocal_neg.prg'
for target in ['linux', 'windows'] if a.wine else ['linux']:
    q = run([a.compiler, negative, a.output / ('erp-negative-' + target), '--target=' + target])
    assert q.returncode != 0 and b'mixed numeric LOCAL cannot cross' in q.stderr
    (a.output / ('erp-negative-' + target + '.stderr')).write_bytes(q.stderr)
    rows.append(dict(name=negative.stem, target=target, rejected=True))
summary = dict(compiler_sha256=hashlib.sha256(a.compiler.read_bytes()).hexdigest(),
               rows=rows, limits='Wine is not native Windows; bounded MT probe only; existing TRY owned leak remains')
(a.output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print('PASS', sum(r.get('exact', False) for r in rows), 'exact executions;', sum(r.get('rejected', False) for r in rows), 'named rejections')

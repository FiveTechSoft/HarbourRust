#!/usr/bin/env python3
"""SubStr differential gate. Requires a built hbc and a real Harbour hbmk2.

Run from any directory; source/expectations resolve relative to this file.
PE execution is optional and uses Wine, not native Windows validation.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--compiler', required=True, type=Path)
p.add_argument('--hbmk2', required=True, type=Path)
p.add_argument('--output', required=True, type=Path, help='new evidence directory')
p.add_argument('--wine', type=Path)
p.add_argument('--wine-prefix', type=Path)
a = p.parse_args()
a.compiler = a.compiler.resolve()
a.hbmk2 = a.hbmk2.resolve()
a.output = a.output.resolve()
a.output.mkdir(parents=True, exist_ok=False)
root = Path(__file__).resolve().parent
repo = root.parent.parent
env = dict(os.environ, WINEDEBUG='-all')
if a.wine_prefix:
    env['WINEPREFIX'] = str(a.wine_prefix.resolve())
rows = []


def run(cmd):
    return subprocess.run(list(map(str, cmd)), capture_output=True, timeout=30, env=env)


def oracle(src, name):
    exe = a.output / (name + '.harbour')
    result = run([a.hbmk2, src, '-quiet', '-gtstd', '-o' + str(exe)])
    (a.output / (name + '.hb-build.log')).write_bytes(result.stdout + result.stderr)
    assert result.returncode == 0, (name, result.stdout, result.stderr)
    result = run([exe])
    assert result.returncode == 0 and not result.stderr, (name, result.returncode, result.stderr)
    return result.stdout


def paired(src, expected, name):
    targets = ['linux'] + (['windows'] if a.wine else [])
    for target in targets:
        for instrument in [False, True]:
            label = name + '-' + target + ('-instrument' if instrument else '-normal')
            exe = a.output / (label + '.program')
            result = run([a.compiler, src, exe, '--target=' + target]
                         + (['--instrument'] if instrument else []))
            (a.output / (label + '.compile.stderr')).write_bytes(result.stderr)
            assert result.returncode == 0, (label, result.stderr)
            result = run([a.wine, exe] if target == 'windows' else [exe])
            (a.output / (label + '.stdout')).write_bytes(result.stdout)
            (a.output / (label + '.stderr')).write_bytes(result.stderr)
            assert (result.returncode, result.stdout, result.stderr) == (0, expected, b''), (
                label, result.returncode, result.stdout, expected, result.stderr)
            rows.append({'name': name, 'target': target, 'instrument': instrument,
                         'stdout_exact': True, 'stderr_empty': True, 'exit': 0})
            print(label, 'exact', flush=True)


# Fresh same-source oracle comparison, not only checked-in expectations.
positive = ['basic', 'bytes', 'params', 'lifetime', 'order', 'byref-mutate', 'loop', 'numeric-order']
for name in positive:
    src = root / (name + '.prg')
    expected = oracle(src, name)
    assert expected == (root / (name + '.stdout')).read_bytes(), ('oracle changed', name)
    paired(src, expected, name)

# Diagnostic-only wrappers run owners in Work and check hb_memcheck AFTER
# release. This is not a Harbour runtime API assertion; the normal same-source
# program above provides the oracle output. Only the final diagnostic is added.
for name in positive[:-1]:
    expected = (root / (name + '-memory.stdout')).read_bytes()
    assert expected == (root / (name + '.stdout')).read_bytes() + b'\n         0'
    paired(root / (name + '-memory.prg'), expected, name + '-memory')

# 312 boundary/data cases in ONE generated program. Calls are not 312
# independent compiler tests. Embedded NUL is verified with Asc in bytes.prg.
lines = ['function Main()']
number = 0
for text in ['"ABC"', '""', '"A"+Chr(0)+"BC"']:
    for start in [-8, -4, -3, -2, -1, 0, 1, 2, 3, 4, 8,
                  9223372036854775807, -9223372036854775807]:
        for length in [None, -8, -1, 0, 1, 2, 4, 9223372036854775807]:
            number += 1
            expr = 'SubStr(' + text + ',' + str(start)
            expr += (',' + str(length)) if length is not None else ''
            expr += ')'
            lines.append('? ' + str(number) + ',"["+' + expr + '+"]",Len(' + expr + ')')
assert number == 312
lines.append('return nil')
grid = a.output / 'grid.prg'
grid.write_text('\n'.join(lines) + '\n', encoding='utf-8')
paired(grid, oracle(grid, 'grid'), 'grid-312-cases')

# Named conservative limits, no panic or output artifact. These include
# values Harbour accepts (float/Dyn indices), rather than calling every
# rejection a Harbour error.
for src in sorted(root.glob('*-neg.prg')):
    exe = a.output / (src.stem + '.program')
    result = run([a.compiler, src, exe])
    assert result.returncode == 1 and b'substr' in result.stderr and not exe.exists(), (
        src.name, result.returncode, result.stderr)
    assert b'panicked' not in result.stderr
    (a.output / (src.stem + '.stderr')).write_bytes(result.stderr)
    rows.append({'name': src.stem, 'named_rejection': True, 'exit': 1})

assert len(list(root.glob('*-neg.prg'))) == 12
# Known error-path limitation, not counted as a successful compatibility
# case and deliberately not pinned to a nonzero leak as a desired outcome.
known_limits = []
for target in ['linux'] + (['windows'] if a.wine else []):
    label = 'caught-error-limit-' + target
    exe = a.output / label
    result = run([a.compiler, root / 'limits/caught-error.prg', exe,
                  '--target=' + target, '--instrument'])
    assert result.returncode == 0, result.stderr
    result = run([a.wine, exe] if target == 'windows' else [exe])
    assert result.returncode == 0 and not result.stderr, result.stderr
    assert result.stdout.startswith(b'\nBound error: array access\n')
    balance = int(result.stdout.rsplit(b'\n', 1)[1].strip())
    known_limits.append({'name': label, 'final_hb_memcheck': balance,
                         'error_path_leak_present': balance != 0})
    (a.output / (label + '.stdout')).write_bytes(result.stdout)
    print(label, 'KNOWN LIMIT final hb_memcheck=' + str(balance), flush=True)
summary = {'known_limits': known_limits, 'compiler_sha256': hashlib.sha256(a.compiler.read_bytes()).hexdigest(),
           'same_source_programs': 8, 'diagnostic_wrappers': 7,
           'grid_programs': 1, 'grid_cases': 312, 'named_rejections': 12,
           'rows': rows,
           'limits': 'integer position/count, typed byte strings; Wine is not native Windows; no native Mac run'}
(a.output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print('PASS', len(rows), 'recorded executions/rejections')

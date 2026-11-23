#!/usr/bin/env python3
"""Execute date-state and setter-only regressions against exact output bytes."""
import argparse
from pathlib import Path
import platform
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
p = argparse.ArgumentParser()
p.add_argument('--compiler', required=True)
a = p.parse_args()
hbc = str(Path(a.compiler).resolve())
target = 'windows' if platform.system() == 'Windows' else 'linux'
if platform.system() not in ('Linux', 'Windows'):
    p.error('Linux or Windows host required')
cases = [('tests/t814_set_century_neg.prg', 't814_set_century_neg')]
cases += [('tests/setdate-bb/programs/' + name + '.prg', name) for name in (
    'setter_only_date', 'setter_only_century_off')]
with tempfile.TemporaryDirectory() as temp:
    modes = [[], ['--instrument']]
    if target == 'linux':
        modes += [['--external-as'], ['--external-as', '--instrument']]
    for source, name in cases:
        for flags in modes:
            exe = Path(temp) / (name + ('.exe' if target == 'windows' else ''))
            r = subprocess.run([hbc, source, str(exe), '--target=' + target] + flags,
                               cwd=root, capture_output=True, timeout=30)
            assert r.returncode == 0, (source, flags, r.stderr)
            r = subprocess.run([str(exe)], capture_output=True, timeout=10)
            expected = root / 'tests/setdate-bb/expected' / (name + '.' + target + '.out')
            assert (r.returncode, r.stdout, r.stderr) == (0, expected.read_bytes(), b''), (source, flags, r)
            print('PASS', name, target, flags)

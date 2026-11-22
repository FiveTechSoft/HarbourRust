#!/usr/bin/env python3
"""Execute static FOR EACH regressions against explicit versioned bytes."""
import argparse
import pathlib
import platform
import subprocess
import tempfile
root = pathlib.Path(__file__).resolve().parents[2]
p = argparse.ArgumentParser()
p.add_argument('--compiler', required=True)
a = p.parse_args()
hbc = str(pathlib.Path(a.compiler).resolve())
target = 'windows' if platform.system() == 'Windows' else 'linux'
if platform.system() not in ('Linux', 'Windows'):
    p.error('Linux or Windows host required')
cases = [(f'tests/{name}.prg', name) for name in (
    't976_foreach_static_neg', 't977_foreach_static_copy_neg',
    't978_foreach_static_empty_neg', 't979_original_failed_foreach_neg')]
cases += [('tests/foreach-static/programs/' + name + '.prg', name) for name in (
    'foreach_static', 'owned_after', 'owned_inside_early', 'owned_exit_loop')]
with tempfile.TemporaryDirectory() as temp:
    for source, name in cases:
        for instrument in (False, True):
            exe = pathlib.Path(temp) / (name + ('.exe' if target == 'windows' else ''))
            flags = ['--instrument'] if instrument else []
            build = subprocess.run([hbc, source, str(exe), '--target=' + target] + flags,
                                   cwd=root, capture_output=True, timeout=30)
            assert build.returncode == 0, (name, flags, build.stderr)
            run = subprocess.run([str(exe)], capture_output=True, timeout=10)
            expected = root / 'tests/foreach-static/expected' / (name + '.' + target + '.out')
            assert (run.returncode, run.stdout, run.stderr) == (0, expected.read_bytes(), b''), (name, flags, run)
            print('PASS', name, target, 'instrument=' + str(instrument))

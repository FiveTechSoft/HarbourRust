#!/usr/bin/env python3
"""Run the user-override regressions on the compiler host, without an oracle."""
import argparse
import pathlib
import platform
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
p = argparse.ArgumentParser()
p.add_argument('--compiler', required=True)
a = p.parse_args()
compiler = str(pathlib.Path(a.compiler).resolve())
target = 'windows' if platform.system() == 'Windows' else 'linux'
if platform.system() not in ('Linux', 'Windows'):
    p.error('this runner covers Linux and Windows hosts only')

with tempfile.TemporaryDirectory() as tmp:
    for name in ('builtin_names', 'internal_valtype'):
        source = ROOT / 'tests' / 'user-overrides' / (name + '.prg')
        expected = source.parent / 'expected' / (name + '.' + target + '.out')
        for instrument in (False, True):
            output = pathlib.Path(tmp) / (name + ('.exe' if target == 'windows' else ''))
            flags = ['--instrument'] if instrument else []
            build = subprocess.run([compiler, str(source), str(output), '--target=' + target] + flags,
                                   cwd=ROOT, capture_output=True, timeout=30)
            if build.returncode:
                raise AssertionError((name, 'build', build.returncode, build.stdout, build.stderr))
            run = subprocess.run([str(output)], cwd=tmp, capture_output=True, timeout=10)
            assert (run.returncode, run.stdout, run.stderr) == (0, expected.read_bytes(), b''), (
                name, instrument, run.returncode, run.stdout, run.stderr)
            print('PASS', name, target, 'instrument=' + str(instrument))

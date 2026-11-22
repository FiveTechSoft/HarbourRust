#!/usr/bin/env python3
"""String-only JSON safety checks. No Harbour compatibility claim."""
import argparse
import pathlib
import subprocess
import tempfile

root = pathlib.Path(__file__).resolve().parents[2]
p = argparse.ArgumentParser()
p.add_argument('--compiler', required=True)
a = p.parse_args()
hbc = str(pathlib.Path(a.compiler).resolve())
expected = b'\n.T.          0 .T.\n      1002       1000 .T.\n      1000\n"short" "" "AZ"'
with tempfile.TemporaryDirectory() as temp:
    temp = pathlib.Path(temp)
    for flags in ([], ['--instrument'], ['--external-as'], ['--external-as', '--instrument']):
        exe = temp / 'strings'
        build = subprocess.run([hbc, 'tests/json-safety/programs/strings.prg', str(exe), '--target=linux'] + flags,
                               cwd=root, capture_output=True, timeout=30)
        assert build.returncode == 0, (flags, build.stderr)
        run = subprocess.run([str(exe)], capture_output=True, timeout=10)
        assert (run.returncode, run.stdout, run.stderr) == (0, expected, b''), (flags, run)
        print('PASS hbc string roundtrip', flags)
    for name in ('arrays_numbers', 'escapes_utf8', 'break_nested'):
        for flags in ([], ['--instrument'], ['--external-as', '--instrument']):
            exe = temp / name
            build = subprocess.run([hbc, 'tests/json-safety/programs/' + name + '.prg', str(exe), '--target=linux'] + flags,
                                   cwd=root, capture_output=True, timeout=30)
            assert build.returncode == 0, (name, flags, build.stderr)
            run = subprocess.run([str(exe)], capture_output=True, timeout=10)
            pin = root / 'tests/json-safety/expected' / (name + '.linux.out')
            assert (run.returncode, run.stdout, run.stderr) == (0, pin.read_bytes(), b''), (name, flags, run)
            print('PASS', name, flags)
    for depth in (3, 4):
        build = subprocess.run([hbc, 'tests/json-safety/rejects/darr' + str(depth) + '.prg', str(temp/'reject'), '--target=linux'],
                               cwd=root, capture_output=True, timeout=30)
        assert build.returncode == 1 and b'DArr3/DArr4 is outside this increment' in build.stderr
        print('PASS named DArr rejection', depth)
    harness = temp / 'harness'
    subprocess.run(['gcc', '-std=c99', '-O1', '-g', '-fsanitize=address,undefined',
                    '-fno-omit-frame-pointer', 'tests/json-safety/string_harness.c', '-o', str(harness)],
                   cwd=root, check=True, timeout=30)
    subprocess.run([str(harness)], check=True, timeout=10)

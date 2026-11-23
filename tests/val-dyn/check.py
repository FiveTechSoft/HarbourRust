#!/usr/bin/env python3
"""Linux-only pin: VAL of an untyped LOCAL holding a string (Dyn string
consumer). Other targets reject it by name (same gate as UPPER/ALLTRIM on a
Dyn), so this is not a manifest row. Usage: check.py --compiler HBC"""
import argparse, subprocess, tempfile, platform
from pathlib import Path
p = argparse.ArgumentParser(); p.add_argument('--compiler', required=True); a = p.parse_args()
root = Path(__file__).resolve().parents[2]
hbc = str(Path(a.compiler).resolve())
if platform.system() != 'Linux': raise SystemExit('Linux host required')
want = Path(__file__).with_name('val_dyn.linux.out').read_bytes()
with tempfile.TemporaryDirectory() as t:
    exe = Path(t) / 'x'
    r = subprocess.run([hbc, 'tests/val-dyn/val_dyn.prg', str(exe), '--target=linux'], cwd=root, capture_output=True, timeout=60)
    assert r.returncode == 0, r.stderr
    r = subprocess.run([str(exe)], capture_output=True, timeout=10)
    assert r.returncode == 0 and r.stdout == want, (r.returncode, r.stdout)
    # non-string runtime value: catchable Argument error
    r = subprocess.run([hbc, 'tests/val-dyn/neg_nonstring.prg', str(exe), '--target=linux'], cwd=root, capture_output=True, timeout=60)
    assert r.returncode == 0, r.stderr
    r = subprocess.run([str(exe)], capture_output=True, timeout=10)
    assert r.returncode == 0 and b'recovered' in r.stdout, (r.returncode, r.stdout)
    # other targets must reject by name, not miscompile
    for tgt in ('macho', 'windows'):
        r = subprocess.run([hbc, 'tests/val-dyn/val_dyn.prg', str(exe), '--target=' + tgt], cwd=root, capture_output=True, timeout=60)
        assert r.returncode != 0 and b'Dyn string consumers' in r.stderr, (tgt, r.stderr)
print('PASS val_dyn')

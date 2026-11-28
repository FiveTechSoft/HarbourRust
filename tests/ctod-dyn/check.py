#!/usr/bin/env python3
"""Linux-only pin: CTOD of an untyped LOCAL holding a string (Dyn string
consumer). Mach-O rejects it by name (same gate as UPPER/ALLTRIM on a Dyn);
Windows is pinned by tests/dyn-consumers-win. Not a manifest row. Usage: check.py --compiler HBC"""
import argparse, subprocess, tempfile, platform
from pathlib import Path
p = argparse.ArgumentParser(); p.add_argument('--compiler', required=True); a = p.parse_args()
root = Path(__file__).resolve().parents[2]
hbc = str(Path(a.compiler).resolve())
if platform.system() != 'Linux': raise SystemExit('Linux host required')
want = Path(__file__).with_name('ctod_dyn.linux.out').read_bytes()
with tempfile.TemporaryDirectory() as t:
    exe = Path(t) / 'x'
    r = subprocess.run([hbc, 'tests/ctod-dyn/ctod_dyn.prg', str(exe), '--target=linux'], cwd=root, capture_output=True, timeout=60)
    assert r.returncode == 0, r.stderr
    r = subprocess.run([str(exe)], capture_output=True, timeout=10)
    assert r.returncode == 0 and r.stdout == want, (r.returncode, r.stdout)
    # Mach-O must reject by name, not miscompile
    for tgt in ('macho',):
        r = subprocess.run([hbc, 'tests/ctod-dyn/ctod_dyn.prg', str(exe), '--target=' + tgt], cwd=root, capture_output=True, timeout=60)
        assert r.returncode != 0 and b'Dyn string consumers' in r.stderr, (tgt, r.stderr)
print('PASS ctod_dyn')

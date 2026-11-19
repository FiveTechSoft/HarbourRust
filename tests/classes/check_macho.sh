#!/bin/sh
# Real-Mac class battery. Python 3 provides bounded process execution.
# Baselines are Linux post-fix captures, NOT a fresh Harbour oracle run.
# Only evidence directories are written; the compiler is never modified.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
exec python3 - "$ROOT" "${1:-./hbc}" "${2:---target=macho}" <<'PY'
from pathlib import Path
import hashlib, json, platform, subprocess, sys, tempfile
root = Path(sys.argv[1])
hbc = Path(sys.argv[2]).resolve()
target = sys.argv[3]
# Mach-O CPU type the produced binaries must carry: little-endian MH_MAGIC_64 + CPU type.
magic = {'--target=macho': bytes.fromhex('cffaedfe07000001'),
         '--target=macho-arm64': bytes.fromhex('cffaedfe0c000001')}.get(target)
if magic is None:
    sys.exit(f'Unsupported target for this battery: {target}')
if not hbc.is_file():
    sys.exit('Missing compiler: build hbc from the current checkout and pass its path.')
work = Path(tempfile.mkdtemp(prefix='hbc-classes-macho.'))
print('Evidence:', work, flush=True)
inputs = root / 'tests/classes/programs'
expected = root / 'tests/classes/expected'
positive = {p.stem for p in expected.glob('*.out')}
negative = dict(line.split('\t', 1) for line in (expected / 'rejections.tsv').read_text().splitlines())
actual = {p.stem for p in inputs.glob('*.prg')}
if len(positive) != 27 or len(negative) != 16 or positive & set(negative) or positive | set(negative) != actual:
    sys.exit('STOP: suite inventory mismatch (expected 27 runnable + 16 rejection cases).')
paths = [hbc, root/'src/hbc.rs', root/'src/hrobj_blob.s'] + sorted(inputs.glob('*.prg')) + sorted(expected.iterdir())
manifest = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
(work/'identity.json').write_text(json.dumps({'machine':platform.platform(),'compiler':str(hbc),'sha256':manifest}, indent=2))
def run(cmd, label, limit):
    try:
        p = subprocess.run([str(x) for x in cmd], cwd=root, capture_output=True, timeout=limit)
        rc, out, err = p.returncode, p.stdout, p.stderr
    except subprocess.TimeoutExpired as e:
        rc, out, err = 124, e.stdout or b'', (e.stderr or b'')+b'\nTIMEOUT\n'
    except OSError as e:
        rc, out, err = 127, b'', str(e).encode()
    for suffix, data in [('stdout',out),('stderr',err),('rc',str(rc).encode())]:
        (work/(label+'.'+suffix)).write_bytes(data)
    return rc, out, err
run([hbc, '--version'], 'version', 15)
failed = []
for name in sorted(actual):
    exe = work/name
    rc, out, err = run([hbc, inputs/(name+'.prg'), exe, target, '-I', root/'tests'], name+'.compile', 60)
    if name in negative:
        ok = rc == 1 and negative[name].encode() in err and b'panic' not in err.lower()
    elif rc != 0:
        ok = False
    else:
        # Magic and CPU type matching the requested target.
        ok = exe.is_file() and exe.read_bytes()[:8] == magic
        if ok:
            rc, out, err = run([exe], name+'.run', 20)
            ok = rc == 0 and not err and out == (expected/(name+'.out')).read_bytes()
    print(('PASS ' if ok else 'FAIL ')+name, flush=True)
    if not ok:
        failed.append(name)
print(f'macho class battery ({target}): {43-len(failed)} pass, {len(failed)} fail (of 43)')
if failed:
    print('FAILED:', ', '.join(failed))
sys.exit(bool(failed))
PY

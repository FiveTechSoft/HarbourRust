#!/usr/bin/env python3
"""Runtime Linux gate for the top-level manifest Dyn-array rows (ains P2).

Regression gate for the tag-8 cell-read slot typo (73cfb85a): the tag
casilla of a bare-LOCAL Dyn array was compared at the payload offset, so
every x[k] read raised "Type error: NIL used as a number". Only the ARM64
native battery ran these rows' runtime expectations; this gate runs them
on Linux against BOTH the fresh Harbour oracle and the pinned
oracle-derived expectations (raw bytes).
"""
import argparse, hashlib, json, os, pathlib, subprocess
P = pathlib.Path

ROWS = [
    "t1510_dynarr_scalar_pos",
    "t1511_dynarr_cells_pos",
    "t1512_dynarr_bridge_pos",
    "t1520_asize_dyn_pos",
    "t1521_ains_dyn_pos",
    "t1522_adel_dyn_pos",
    "t1523_afill_dyn_pos",
    "t1524_afill_strclone_pos",
    "t1525_mutbalance_pos",
]

ap = argparse.ArgumentParser()
ap.add_argument('--compiler', required=True)
ap.add_argument('--hbmk2', required=True)
ap.add_argument('--output', required=True)
a = ap.parse_args()
root = P(__file__).resolve().parent.parent
out = P(a.output).resolve()
out.mkdir(parents=True, exist_ok=False)
compiler = str(P(a.compiler).resolve())
hbmk2 = str(P(a.hbmk2).resolve())
env = os.environ.copy()
env['LC_ALL'] = 'C.UTF-8'

def run(cmd, work, label):
    r = subprocess.run(list(map(str, cmd)), cwd=work, env=env,
                       capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
    for k, v in [('stdout', r.stdout), ('stderr', r.stderr), ('rc', str(r.returncode).encode())]:
        (work / (label + '.' + k)).write_bytes(v)
    return r

rows = []
for stem in ROWS:
    work = out / stem
    work.mkdir()
    src = root / (stem + '.prg')
    (work / src.name).write_bytes(src.read_bytes())
    ours = run([compiler, src.name, stem, '--target=linux'], work, 'hbc-build')
    ours_run = run([work / stem], work, 'hbc') if ours.returncode == 0 else None
    orc_build = run([hbmk2, src.name, '-gtstd', '-o' + stem + '_orc'], work, 'oracle-build')
    orc_run = run([work / (stem + '_orc')], work, 'oracle') if orc_build.returncode == 0 else None
    pinned = (root / 'expectations' / 'qout' / (stem + '.linux.out')).read_bytes()
    ours_b = ours_run.stdout if ours_run else b''
    orc_b = orc_run.stdout if orc_run else b''
    ok = (ours_run is not None and orc_run is not None
          and ours_run.returncode == 0 and orc_run.returncode == 0
          and ours_b == orc_b == pinned)
    rows.append({'test': stem, 'pass': ok,
                 'ours_matches_oracle': ours_b == orc_b,
                 'ours_matches_pinned': ours_b == pinned})
    print(('PASS' if ok else 'FAIL'), stem, 'linux')
(out / 'results.json').write_text(json.dumps(
    {'compiler_sha256': hashlib.sha256(P(compiler).read_bytes()).hexdigest(),
     'rows': rows}, indent=2) + '\n')
assert all(r['pass'] for r in rows), 'see evidence'

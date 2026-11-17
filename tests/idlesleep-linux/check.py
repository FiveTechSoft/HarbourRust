#!/usr/bin/env python3
"""Persistent runtime gate for hb_idleSleep([nSeconds]) (S5).

Semantics pinned against Harbour rtl/idle.c:133 (pin 694428e1, GTSTD):
negative is a NO-OP, zero/no-arg serves the idle queue once (no idle tasks
exist in this runtime, so an immediate return), positive sleeps; the call
always returns NIL. Dyn arguments follow hb_parnd: numeric payloads
convert, NIL/other tags default to 0.

Sections:
A. Manifest pos2 rows (programs/idlesleep_*): ours linux AND windows runs
   vs the pinned expectations (raw bytes), plus a fresh Harbour-oracle run
   of the SAME program whose stdout must equal the pinned linux
   expectation. Print bytes are byte-exact both sides; the sleep duration
   is NOT part of the print contract.
B. Timing windows on the linux runs (wall clock, monotonic): positive
   sleeps must actually consume the requested span (lower bound just under
   the request to absorb clock granularity), no-op forms must return
   immediately. The oracle binary's wall time is recorded for reference.

Every run records rc + stderr in results.json; PASS requires rc 0 and
EMPTY stderr on both ours and the oracle.
"""
import argparse, hashlib, json, os, pathlib, subprocess, time
P = pathlib.Path

# stem -> (min_seconds, max_seconds) for the linux wall-clock window.
ROWS = {
    "idlesleep_basic":    (0.15, 2.0),   # hb_idleSleep(0.2)
    "idlesleep_negative": (0.0, 0.5),    # hb_idleSleep(-1) is a no-op
    "idlesleep_loop":     (1.1, 4.0),    # 3 x hb_idleSleep(0.4)
    "idlesleep_noarg":    (0.0, 0.5),    # hb_idleSleep() + hb_idleSleep(0)
    "idlesleep_dyn":      (0.15, 2.0),   # Dyn local x := 0.2
}

ap = argparse.ArgumentParser()
ap.add_argument('--compiler', required=True)
ap.add_argument('--hbmk2', required=True)
ap.add_argument('--output', required=True)
ap.add_argument('--wine', default=None)
ap.add_argument('--tree', default=None)
a = ap.parse_args()
gate = P(__file__).resolve().parent
out = P(a.output).resolve(); out.mkdir(parents=True, exist_ok=False)
compiler = str(P(a.compiler).resolve()); hbmk2 = str(P(a.hbmk2).resolve())
env = os.environ.copy(); env['LC_ALL'] = 'C.UTF-8'; env['WINEDEBUG'] = '-all'
# The linux-only Harbour oracle must not inherit the mingw cross
# environment (HB_CCPATH/HB_CCPREFIX/HBC_MINGW_LIB flip hbmk2's default
# target to a Windows PE link, which then fails on -ldl/-lrt/-lz).
env_oracle = {k: v for k, v in env.items()
              if k not in ('HB_CCPATH', 'HB_CCPREFIX', 'HBC_MINGW_LIB')}

def run(cmd, work, label, envx=None):
    t0 = time.monotonic()
    r = subprocess.run(list(map(str, cmd)), cwd=work, env=envx or env,
                       capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
    dt = time.monotonic() - t0
    for k, v in [('stdout', r.stdout), ('stderr', r.stderr), ('rc', str(r.returncode).encode())]:
        (work / (label + '.' + k)).write_bytes(v)
    return r, dt

def rec(r, dt=None):
    d = {'rc': None, 'stderr': None} if r is None else {
        'rc': r.returncode, 'stderr': r.stderr.decode('utf-8', 'replace')}
    if dt is not None:
        d['wall_s'] = round(dt, 3)
    return d

rows = []
for stem, (lo, hi) in ROWS.items():
    work = out / stem; work.mkdir()
    src = gate / 'programs' / (stem + '.prg')
    pin_lin = (gate / 'expected' / (stem + '.linux.out')).read_bytes()
    pin_win = (gate / 'expected' / (stem + '.windows.out')).read_bytes()
    b, _ = run([compiler, src, work / stem, '--target=linux'], work, 'hbc-build')
    rl, dt_l = (run([work / stem], work, 'hbc-linux') if b.returncode == 0 else (None, None))
    ob, _ = run([hbmk2, src, '-gtstd', '-o' + stem + '_orc'], work, 'oracle-build', env_oracle)
    orun, dt_o = (run([work / (stem + '_orc')], work, 'oracle', env_oracle) if ob.returncode == 0 else (None, None))
    row = {'test': stem, 'kind': 'manifest-pos2',
           'ours_build_rc': b.returncode, 'oracle_build_rc': ob.returncode,
           'ours_linux': rec(rl, dt_l), 'oracle': rec(orun, dt_o),
           'timing_window_s': [lo, hi]}
    ok = (rl is not None and orun is not None and rl.returncode == 0 and orun.returncode == 0
          and rl.stderr == b'' and orun.stderr == b''
          and rl.stdout == pin_lin and orun.stdout == pin_lin
          and dt_l is not None and lo <= dt_l <= hi)
    if a.wine:
        wb, _ = run([compiler, src, work / (stem + '.exe'), '--target=windows'], work, 'hbc-build-win')
        wr, dt_w = (run([a.wine, work / (stem + '.exe')], work, 'hbc-windows') if wb.returncode == 0 else (None, None))
        row['ours_build_win_rc'] = wb.returncode; row['ours_windows'] = rec(wr, dt_w)
        ok = ok and wr is not None and wr.returncode == 0 and wr.stderr == b'' and wr.stdout == pin_win
    row['pass'] = ok
    rows.append(row); print(('PASS' if ok else 'FAIL'), stem,
                            f'linux={dt_l:.3f}s' if dt_l is not None else 'linux=n/a')

result = {
    'gate': 'idlesleep-linux',
    'compiler_sha256': hashlib.sha256(P(compiler).read_bytes()).hexdigest(),
    'compiler_tree': a.tree,
    'rows': rows,
    'pass': all(r['pass'] for r in rows),
}
(out / 'results.json').write_text(json.dumps(result, indent=2))
print('GATE', 'PASS' if result['pass'] else 'FAIL')
raise SystemExit(0 if result['pass'] else 1)

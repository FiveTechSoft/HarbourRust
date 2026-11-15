"""Whole manifest gate. Raw channels are primary; legacy trailing-LF and CRLF
columns are informational only. JSONL retains base64 raw channels and statuses.
Executables are hashed then deleted. Output directory must be NEW.
"""
import argparse
import base64
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

p = argparse.ArgumentParser()
for arg in ['compiler', 'root', 'output', 'wine', 'wine-prefix']:
    p.add_argument('--' + arg, required=True)
p.add_argument('--manifest', default='tests/manifest.txt')
p.add_argument('--jobs', type=int, default=4)
p.add_argument('--completed-jsonl')
p.add_argument('--start-index',type=int,default=0)
p.add_argument('--end-index',type=int,default=100000)
a = p.parse_args()
root = Path(a.root).resolve()
out = Path(a.output).resolve()
out.mkdir(parents=True, exist_ok=False)
compiler = str(Path(a.compiler).resolve())
env = {**os.environ, 'WINEPREFIX': a.wine_prefix, 'WINEDEBUG': '-all'}
lines = [(i, s) for i, s in enumerate((root / a.manifest).read_text().splitlines()) if s and not s.startswith('#')]
(out / 'manifest.txt').write_bytes((root / a.manifest).read_bytes())
(out / 'compiler-sha256.txt').write_text(hashlib.sha256(Path(compiler).read_bytes()).hexdigest() + '\n')


def b64(v):
    return base64.b64encode(v).decode()


def run(cmd):
    q = subprocess.run(cmd, cwd=root, env=env, capture_output=True, stdin=subprocess.DEVNULL, timeout=20)
    return q, dict(argv=cmd, rc=q.returncode, stdout_b64=b64(q.stdout), stderr_b64=b64(q.stderr))


def case(item):
    target, index, line = item
    kind, source, *spec = line.split(' ', 2)
    spec = spec[0] if spec else ''
    row = dict(target=target, index=index, kind=kind, source=source, raw_pass=False)
    try:
        with tempfile.TemporaryDirectory(prefix='run-', dir=out) as td:
            exe = str(Path(td) / ('program.exe' if target == 'windows' else 'program'))
            q, row['compile'] = run([compiler, source, exe, '--target=' + target, '--instrument'] + ([] if kind == 'neg' else ['-I', 'tests']))
            if kind == 'neg':
                row['raw_pass'] = q.returncode != 0 and spec.encode() in q.stderr
                row['stage'] = 'expected-rejection'
                return row
            if q.returncode:
                row['stage'] = 'compile'
                return row
            row['binary_sha256'] = hashlib.sha256(Path(exe).read_bytes()).hexdigest()
            q, row['run'] = run(([a.wine] if target == 'windows' else []) + [exe])
            want_rc = 0
            expected_err = b''
            if kind == 'posx':
                rc, spec = spec.split(' ', 1)
                want_rc = int(rc)
            if kind == 'streams':
                x, y = spec.split()
                expected = (root / x).read_bytes()
                expected_err = (root / y).read_bytes()
            elif kind == 'pos2':
                x, y = spec.split()
                expected = (root / (y if target == 'windows' else x)).read_bytes()
            else:
                expected = subprocess.run(['printf', '%b', spec], capture_output=True, check=True).stdout
            row.update(expected_stdout_b64=b64(expected), expected_stderr_b64=b64(expected_err), expected_exit=want_rc)
            same_status = q.returncode == want_rc and q.stderr == expected_err
            row['raw_pass'] = same_status and q.stdout == expected
            row['legacy_trim_LF_equal'] = same_status and q.stdout.rstrip(b'\n') == expected.rstrip(b'\n')
            row['CRLF_normalized_equal'] = same_status and q.stdout.replace(b'\r\n', b'\n') == expected.replace(b'\r\n', b'\n')
            row['stage'] = 'runtime'
    except Exception as e:
        row.update(stage='exception', error=str(e))
    return row


done = set()
if a.completed_jsonl:
    done = {(x['target'], x['index']) for x in map(json.loads, Path(a.completed_jsonl).read_text().splitlines())}
items = [(target, i, line) for target in ['linux', 'windows'] for i, line in lines if (target, i) not in done and a.start_index <= i < a.end_index]
rows = []
with (out / 'raw-results.jsonl').open('w') as log:
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        for row in pool.map(case, items):
            log.write(json.dumps(row) + '\n')
            log.flush()
            rows.append(row)
summary = {}
for target in ['linux', 'windows']:
    part = [x for x in rows if x['target'] == target]
    summary[target] = dict(total=len(part), raw_pass=sum(x['raw_pass'] for x in part), raw_fail=sum(not x['raw_pass'] for x in part), failures=[{k:x[k] for k in ['index','source','stage']} for x in part if not x['raw_pass']])
(out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2))

raise SystemExit(0 if all(x['raw_pass'] for x in rows) else 1)

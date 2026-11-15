"""Check explicit-output byte identity to BASE and optional-output identity.
Requires --baseline and --compiler Linux-host builds; --output must be new.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

p = argparse.ArgumentParser()
for arg in ['baseline', 'compiler', 'output']:
    p.add_argument('--' + arg, required=True)
a = p.parse_args()
r = Path(a.output).resolve()
r.mkdir(parents=True, exist_ok=False)
rows = []
for target in ['linux', 'windows', 'macho', 'assembly']:
    d = r / target
    d.mkdir()
    (d / 'MiXeD.prg').write_text('function Main()\n? "identity"\nreturn nil\n')
    flag = '--target=' + ('linux' if target == 'assembly' else target)
    outputs = ['baseline.s', 'current.s'] if target == 'assembly' else ['baseline', 'current']
    for compiler, name in zip([a.baseline, a.compiler], outputs):
        cmd = [str(Path(compiler).resolve()), flag, 'MiXeD.prg', name]
        q = subprocess.run(cmd, cwd=d, capture_output=True)
        for suffix, value in [('stdout', q.stdout), ('stderr', q.stderr), ('rc', str(q.returncode).encode())]:
            (d / (name + '.' + suffix)).write_bytes(value)
        (d / (name + '.command.json')).write_text(json.dumps(cmd) + '\n')
        assert q.returncode == 0 and not q.stderr
    assert (d / outputs[0]).read_bytes() == (d / outputs[1]).read_bytes(), target
    if target != 'assembly':
        cmd = [str(Path(a.compiler).resolve()), flag, 'MiXeD.prg']
        q = subprocess.run(cmd, cwd=d, capture_output=True)
        for suffix, value in [('stdout', q.stdout), ('stderr', q.stderr), ('rc', str(q.returncode).encode())]:
            (d / ('derived.' + suffix)).write_bytes(value)
        (d / 'derived.command.json').write_text(json.dumps(cmd) + '\n')
        derived = 'MiXeD.exe' if target == 'windows' else 'MiXeD'
        assert q.returncode == 0 and not q.stderr
        assert (d / derived).read_bytes() == (d / outputs[1]).read_bytes()
    rows.append(dict(target=target, sha256=hashlib.sha256((d / outputs[1]).read_bytes()).hexdigest(), pass_=True))
(r / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
print('PASS explicit BASE identity 4/4; derived identity 3/3')

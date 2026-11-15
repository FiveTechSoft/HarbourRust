"""Optional output stem CLI regression gate. PE host execution is Wine, not Windows.
All commands, channels, exit codes and exact directory entries are retained.
Use a NEW --output directory. Requires Linux and Windows compiler builds.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import subprocess

p = argparse.ArgumentParser()
for arg in ['compiler', 'windows-compiler', 'wine', 'wine-prefix', 'output']:
    p.add_argument('--' + arg, required=True)
a = p.parse_args()
r = Path(a.output).resolve()
r.mkdir(parents=True, exist_ok=False)
rows = []
env = {**os.environ, 'WINEPREFIX': a.wine_prefix, 'WINEDEBUG': '-all'}
comp = Path(a.compiler).resolve()
win = Path(a.windows_compiler).resolve()
(r / 'compiler-shas.json').write_text(json.dumps({str(x): hashlib.sha256(x.read_bytes()).hexdigest() for x in [comp, win]}, indent=2) + '\n')
source = b'function Main()\n? "case-probe"\nreturn nil\n'


def call(d, label, cmd):
    (d / (label + '.command.json')).write_text(json.dumps([str(x) for x in cmd]) + '\n')
    q = subprocess.run(cmd, cwd=d, env=env, capture_output=True, timeout=30)
    for suffix, value in [('stdout', q.stdout), ('stderr', q.stderr), ('rc', str(q.returncode).encode())]:
        (d / (label + '.' + suffix)).write_bytes(value)
    return q


def finish(d, **row):
    (d / 'entries.json').write_text(json.dumps(sorted(x.name for x in d.iterdir()), indent=2) + '\n')
    rows.append(dict(case=d.name, **row, pass_=True))
    print(rows[-1])


def compiler(host):
    return [a.wine, str(win)] if host == 'wine' else [str(comp)]


for host in ['linux', 'wine']:
    for stem in ['TEST', 'TeSt', 'test', 'Long.Name']:
        for explicit in [False, True]:
            d = r / (host + '-' + stem + ('-explicit' if explicit else '-default'))
            (d / 'Sub.Dir').mkdir(parents=True)
            src = d / 'Sub.Dir' / (stem + '.PrG')
            src.write_bytes(source)
            target = 'windows' if host == 'wine' else 'linux'
            name = 'OuTpUt.EXE' if explicit else stem + ('.exe' if target == 'windows' else '')
            q = call(d, 'compile', compiler(host) + ['Sub.Dir/' + src.name] + ([name] if explicit else []) + ['--target=' + target])
            assert q.returncode == 0 and not q.stderr, (q.returncode, q.stderr)
            assert name in [x.name for x in d.iterdir()] and not (d / 'Sub.Dir' / name).exists()
            q = call(d, 'run', ([a.wine] if host == 'wine' else []) + [str(d / name)])
            assert q.returncode == 0 and q.stdout == b'\ncase-probe' and not q.stderr
            finish(d, host=host, filename=name)

for host, flags, name, magic in [
    ('wine', [], 'TeSt.exe', b'MZ'),
    ('linux', [], 'TeSt', b'\x7fELF'),
    ('linux', ['--target=windows'], 'TeSt.exe', b'MZ'),
    ('wine', ['--target=linux'], 'TeSt', b'\x7fELF'),
    ('linux', ['--target=macho'], 'TeSt', b'\xcf\xfa\xed\xfe'),
]:
    d = r / ('host-default-' + host + '-' + (flags[0].split('=')[-1] if flags else 'native'))
    d.mkdir()
    (d / 'TeSt.prg').write_bytes(source)
    q = call(d, 'compile', compiler(host) + flags + ['TeSt.prg'])
    assert q.returncode == 0 and not q.stderr and (d / name).read_bytes().startswith(magic)
    finish(d, filename=name)

for host in ['linux', 'wine']:
    d = r / ('source-protection-' + host)
    d.mkdir()
    f = d / 'TeSt'
    f.write_bytes(source)
    q = call(d, 'compile', compiler(host) + ['TeSt', '--target=linux'])
    assert q.returncode == 2 and b'derived output would replace' in q.stderr and f.read_bytes() == source
    finish(d)

for args in [[], ['one', 'two', 'three']]:
    d = r / ('bad-arity-' + str(len(args)))
    d.mkdir()
    q = call(d, 'compile', [str(comp), *args])
    assert q.returncode == 2 and b'[output]' in q.stderr
    finish(d)

for host in ['linux', 'wine']:
    d = r / ('flags-before-input-' + host)
    (d / 'Sub Dir').mkdir(parents=True)
    (d / 'Sub Dir' / 'MiX.s.prg').write_bytes(source)
    sep = '\\' if host == 'wine' else '/'
    q = call(d, 'compile', compiler(host) + ['--target=linux', 'Sub Dir' + sep + 'MiX.s.prg'])
    assert q.returncode == 0 and not q.stderr and (d / 'MiX.s').read_bytes().startswith(b'\x7fELF')
    assert b'-> MiX.s ' in q.stdout
    finish(d)

for host in ['linux', 'wine']:
    d = r / ('explicit-assembly-' + host)
    d.mkdir()
    (d / 'MiXeD.prg').write_bytes(source)
    q = call(d, 'compile', compiler(host) + ['--target=linux', 'MiXeD.prg', 'OuTpUt.s'])
    assert q.returncode == 0 and not q.stderr and b'-> OuTpUt.s ' in q.stdout
    assert b'.text' in (d / 'OuTpUt.s').read_bytes()
    finish(d)

for host in ['linux', 'wine']:
    d = r / ('write-error-' + host)
    d.mkdir()
    (d / 'MiXeD.prg').write_bytes(source)
    q = call(d, 'compile', compiler(host) + ['--target=linux', 'MiXeD.prg', 'Absent/Out'])
    assert q.returncode == 2 and b'cannot write Absent/Out:' in q.stderr and b'panicked' not in q.stderr
    finish(d)

(r / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
print('PASS', len(rows))

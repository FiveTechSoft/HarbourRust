"""Same-source context oracle plus separate product allocation-balance check.
No Harbour memcheck stub: only the unmodified context program is paired.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import subprocess

p = argparse.ArgumentParser()
for flag in ['compiler', 'pe-compiler', 'hbmk2', 'mingw-bin', 'wine', 'wine-prefix', 'output']:
    p.add_argument('--' + flag, required=True)
a = p.parse_args()
r = Path(a.output).resolve()
r.mkdir(parents=True, exist_ok=False)
source = (Path(__file__).parent / 'contexts.prg').read_text()
rows = []
commands = []
for target in ['linux', 'windows']:
    d = r / target
    d.mkdir()
    (d / 'case.prg').write_text(source)
    env = {**os.environ, 'WINEPREFIX': a.wine_prefix, 'WINEDEBUG': '-all'}

    def call(cmd, label, cross=False):
        e = env.copy()
        if cross:
            e.update(PATH=a.mingw_bin + ':' + e['PATH'], HB_CCPATH=a.mingw_bin + '/', HB_CCPREFIX='x86_64-w64-mingw32-', HB_CCSUFFIX='-posix')
        else:
            for k in ['HB_CCPATH', 'HB_CCPREFIX', 'HB_CCSUFFIX']:
                e.pop(k, None)
        q = subprocess.run(cmd, cwd=d, env=e, capture_output=True, timeout=45)
        commands.append(dict(target=target, label=label, argv=cmd, cross=cross))
        for ext, value in [('stdout', q.stdout), ('stderr', q.stderr), ('rc', str(q.returncode).encode())]:
            (d / (label + '.' + ext)).write_bytes(value)
        assert q.returncode == 0 and not q.stderr, (target, label, q.stderr)
        return q

    call([str(Path(a.hbmk2).resolve()), 'case.prg', '-gtstd', '-oofficial'] + (['-plat=win', '-comp=mingw64'] if target == 'windows' else []), 'oracle-build', target == 'windows')
    execute = [a.wine] if target == 'windows' else []
    ext = '.exe' if target == 'windows' else ''
    oracle = call(execute + [str(d / ('official' + ext))], 'oracle-run')
    compiler = [a.wine, str(Path(a.pe_compiler).resolve())] if target == 'windows' else [str(Path(a.compiler).resolve())]
    for mode in ['plain', 'instrumented']:
        exe = str(d / (mode + ext))
        call(compiler + ['case.prg', exe, '--target=' + target] + (['--instrument'] if mode == 'instrumented' else []), mode + '-build')
        own = call(execute + [exe], mode + '-run')
        assert own.stdout == oracle.stdout
        rows.append(dict(target=target, mode=mode, raw_exact=True))
    # Check allocation ownership after context function has returned and its
    # locals/owned string result have been released. This is product-only.
    (d / 'balance.prg').write_text(source.replace('function Main()', 'function Check()') + '\nfunction Main()\nCheck()\n?? hb_memcheck()\nreturn nil\n')
    exe = str(d / ('balance' + ext))
    call(compiler + ['balance.prg', exe, '--target=' + target, '--instrument'], 'balance-build')
    own = call(execute + [exe], 'balance-run')
    assert own.stdout == oracle.stdout + b'         0', (target, own.stdout)
    rows.append(dict(target=target, mode='product-only-balance', final_hb_memcheck=0, no_oracle_memcheck_stub=True))
    (d / 'binary-shas.json').write_text(json.dumps({x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in d.iterdir() if x.name in ['official'+ext, 'plain'+ext, 'instrumented'+ext, 'balance'+ext]},indent=2)+'\n')
    for x in ['official'+ext, 'plain'+ext, 'instrumented'+ext, 'balance'+ext]:
        (d / x).unlink()
(r / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
(r / 'commands.json').write_text(json.dumps(commands, indent=2) + '\n')
print('PASS context raw pairs 4/4; separate allocation balance 2/2')

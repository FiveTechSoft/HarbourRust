#!/usr/bin/env python3
"""Oracle comparison for independent bare-TEXT implementation (Linux GTSTD)."""
import argparse
import hashlib
import json
import pathlib
import resource
import shutil
import subprocess

p = argparse.ArgumentParser()
p.add_argument('--compiler', required=True)
p.add_argument('--core', required=True)
p.add_argument('--hbmk2', required=True)
p.add_argument('--output', required=True)
p.add_argument('--rustc', default='rustc')
p.add_argument('--wrong-controls', action='store_true')
a = p.parse_args()
repo = pathlib.Path(__file__).resolve().parents[1]
core = pathlib.Path(a.core).resolve()
compiler = str(pathlib.Path(a.compiler).resolve())
hbmk2 = str(pathlib.Path(a.hbmk2).resolve())
out = pathlib.Path(a.output).resolve()
out.mkdir(parents=True, exist_ok=True)
original = core / 'tests/vec1.prg'
expected_source = '4261a61f3ef870ea3413b81f317c64b97e0308ce93373e5915579eb0daea16c9'
assert hashlib.sha256(original.read_bytes()).hexdigest() == expected_source

def limits():
    resource.setrlimit(resource.RLIMIT_CPU, (3, 3))
    resource.setrlimit(resource.RLIMIT_AS, (512 * 1024**2, 512 * 1024**2))
    resource.setrlimit(resource.RLIMIT_FSIZE, (2 * 1024**2, 2 * 1024**2))

def run(cmd, cwd, execute=False):
    return subprocess.run(list(map(str, cmd)), cwd=cwd, capture_output=True,
                          stdin=subprocess.DEVNULL, timeout=4 if execute else 120,
                          preexec_fn=limits if execute else None)

def build(cmd, cwd):
    r = run(cmd, cwd)
    assert r.returncode == 0, (cmd, r.stdout, r.stderr)

rows = []
sources = [original] + sorted((repo / 'tests').glob('t15[6789][0-9]_text_*.prg'))
sources = [s for s in sources if '_neg_' not in s.name]
for source in sources:
    work = out / source.stem
    work.mkdir(exist_ok=True)
    before = hashlib.sha256(source.read_bytes()).hexdigest()
    harbour_source = source if source == original else work / 'probe.prg'
    if source != original:
        harbour_source.write_bytes(source.read_bytes())
    build([hbmk2, harbour_source, '-gtstd', '-o./oracle'], work)
    oracle = run(['./oracle'], work, True)
    for instrument in [False, True]:
        command = [compiler, source, 'candidate.s', '-I', core / 'include']
        if instrument:
            command.append('--instrument')
        build(command, work)
        build(['as', 'candidate.s', '-o', 'candidate.o'], work)
        build(['ld', 'candidate.o', '-o', 'candidate'], work)
        result = run(['./candidate'], work, True)
        for name, r in [('oracle', oracle), ('candidate', result)]:
            (work / (name + '.stdout')).write_bytes(r.stdout)
            (work / (name + '.stderr')).write_bytes(r.stderr)
            (work / (name + '.rc')).write_text(str(r.returncode) + '\n')
        exact = (oracle.stdout, oracle.stderr, oracle.returncode) == (
            result.stdout, result.stderr, result.returncode)
        row = {'file': source.name, 'instrument': instrument, 'exact': exact,
               'source_sha256': before, 'stdout_bytes': len(oracle.stdout),
               'stdout_sha256': hashlib.sha256(oracle.stdout).hexdigest(),
               'stderr_bytes': len(oracle.stderr), 'rc': oracle.returncode}
        rows.append(row)
        assert exact, row
    assert hashlib.sha256(source.read_bytes()).hexdigest() == before

controls = []
if a.wrong_controls:
    # Rebuild two deliberately wrong private copies. Their clean exits must
    # still fail stream comparison. Never edit the reviewed source tree.
    changes = [
        ('trim-indentation', '&quote_literal(raws[li])',
         '&quote_literal(raws[li].trim_start())', original, out / original.stem),
        ('expand-literal', '&quote_literal(raws[li])',
         '&quote_literal(&expand(raws[li], &pp.defs, line)?)',
         repo / 'tests/t1571_text_macro.prg', out / 't1571_text_macro'),
    ]
    for name, old, new, source, expected_dir in changes:
        work = out / name
        work.mkdir(exist_ok=True)
        shutil.copytree(repo / 'src', work / 'src', dirs_exist_ok=True)
        pp = work / 'src/pp.rs'
        text = pp.read_text()
        assert text.count(old) == 1
        pp.write_text(text.replace(old, new))
        build([a.rustc, '--edition=2021', '-O', work / 'src/hbc.rs', '-o', work / 'hbc'], work)
        build([work / 'hbc', source, 'bad.s'], work)
        build(['as', 'bad.s', '-o', 'bad.o'], work)
        build(['ld', 'bad.o', '-o', 'bad'], work)
        result = run(['./bad'], work, True)
        caught = result.returncode == 0 and result.stdout != (expected_dir / 'oracle.stdout').read_bytes()
        controls.append({'name': name, 'caught': caught, 'rc': result.returncode,
                         'stdout_sha256': hashlib.sha256(result.stdout).hexdigest()})
        (work / 'stdout').write_bytes(result.stdout)
        assert caught, controls[-1]
(out / 'results.json').write_text(json.dumps({'cases': rows, 'controls': controls}, indent=2) + '\n')
print('PASS', len(rows), 'fresh byte comparisons;', len(controls), 'wrong compiler controls caught')

#!/usr/bin/env python3
"""Rebuild and compare the unchanged original and string-iteration probes.
No Harbour implementation code is copied into the compiler by this checker.
"""
import argparse
import hashlib
import json
import pathlib
import resource
import subprocess

p = argparse.ArgumentParser()
p.add_argument('--compiler', required=True)
p.add_argument('--core', required=True)
p.add_argument('--hbmk2', required=True)
p.add_argument('--output', required=True)
a = p.parse_args()
repo = pathlib.Path(__file__).resolve().parents[1]
core = pathlib.Path(a.core).resolve()
compiler = str(pathlib.Path(a.compiler).resolve())
hbmk2 = str(pathlib.Path(a.hbmk2).resolve())
out = pathlib.Path(a.output).resolve()
out.mkdir(parents=True, exist_ok=True)
original = core / 'tests/test.prg'
assert hashlib.sha256(original.read_bytes()).hexdigest() == 'e99e9fa8d9364a9aa805996e1f28bb12ceb36a3b5ee448198e3121c5dfc8dc7e'

def limits():
    resource.setrlimit(resource.RLIMIT_CPU, (3, 3))
    resource.setrlimit(resource.RLIMIT_AS, (512 * 1024**2, 512 * 1024**2))
    resource.setrlimit(resource.RLIMIT_FSIZE, (2 * 1024**2, 2 * 1024**2))

def run(cmd, cwd, execute=False):
    return subprocess.run(list(map(str, cmd)), cwd=cwd, capture_output=True,
                          stdin=subprocess.DEVNULL, timeout=4 if execute else 30,
                          preexec_fn=limits if execute else None)

def build(cmd, cwd):
    r = run(cmd, cwd)
    assert r.returncode == 0, (cmd, r.stdout, r.stderr)

rows = []
sources = [original] + [repo / 'tests' / name for name in [
    't1548_string_each_observe.hb', 't1549_string_each_copies.hb',
    't1550_string_each_early_return.hb', 't1551_string_each_nul_output.hb']]
for source in sources:
    work = out / source.stem
    work.mkdir(exist_ok=True)
    before = hashlib.sha256(source.read_bytes()).hexdigest()
    # hbmk2's source extension is .prg; the bytes are never edited.
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
        candidate = run(['./candidate'], work, True)
        for name, result in [('oracle', oracle), ('candidate', candidate)]:
            (work / (name + '.stdout')).write_bytes(result.stdout)
            (work / (name + '.stderr')).write_bytes(result.stderr)
            (work / (name + '.rc')).write_text(str(result.returncode) + '\n')
        equal = (oracle.stdout, oracle.stderr, oracle.returncode) == (
            candidate.stdout, candidate.stderr, candidate.returncode)
        rows.append({'file': str(source), 'instrument': instrument,
                     'source_sha256': before, 'exact': equal,
                     'stdout_bytes': len(oracle.stdout),
                     'stdout_sha256': hashlib.sha256(oracle.stdout).hexdigest(),
                     'stderr_bytes': len(oracle.stderr), 'rc': oracle.returncode})
        assert equal, rows[-1]
    assert hashlib.sha256(source.read_bytes()).hexdigest() == before

# Deliberately wrong emitted-code controls. Both must still exit normally
# but fail the byte comparison, so exit-code checks alone cannot bless them.
work = out / original.stem
assembly = (work / 'candidate.s').read_text()
mutations = {
    'raw-nul': ('    mov $46, %eax\n.Lcnull_store:',
                '    xor %eax, %eax\n.Lcnull_store:'),
    'iterator-offset': ('    add %r11, %rax\n    mov $1, %edx\n',
                        '    add %r11, %rax\n    inc %rax\n    mov $1, %edx\n'),
}
controls = []
for name, (old, new) in mutations.items():
    assert assembly.count(old) == 1, (name, assembly.count(old))
    (work / (name + '.s')).write_text(assembly.replace(old, new))
    build(['as', name + '.s', '-o', name + '.o'], work)
    build(['ld', name + '.o', '-o', name], work)
    result = run(['./' + name], work, True)
    expected = (work / 'oracle.stdout').read_bytes()
    caught = result.returncode == 0 and result.stdout != expected
    controls.append({'name': name, 'caught': caught, 'rc': result.returncode,
                     'stdout_sha256': hashlib.sha256(result.stdout).hexdigest()})
    (work / (name + '.stdout')).write_bytes(result.stdout)
    assert caught, controls[-1]
report = {'cases': rows, 'controls': controls,
          'scope': 'Linux GTSTD, byte iteration and NUL presentation only; no Windows, Unicode-codepoint, other control-character or screen-wrapping claim'}
(out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
print('PASS 10 fresh oracle comparisons (5 sources x 2 instrumentation profiles), 2 wrong-code controls caught')

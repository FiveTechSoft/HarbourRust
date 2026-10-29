"""Run existing repository regressions unchanged through both backends/targets."""
import os
import sys
import pathlib
import subprocess

root = pathlib.Path(__file__).resolve().parents[2]
os.chdir(root)
work = pathlib.Path('experiments/llvm-scalar/run')
base = pathlib.Path('experiments/llvm-scalar')
hbc = str(work / 'hbc')
env = os.environ
selected = ['t28_exit_loop.hb', 't42_for_exit_loop.hb', 't48_nested_exit.hb',
            't49_nested_loop.hb', 't129_arr_loop.hb',
            't907_original_while.hb', 't997_original_recursiv.hb']
manifest = {}
for line in pathlib.Path('tests/manifest.txt').read_text().splitlines():
    if line.startswith('pos '):
        parts = line.split(' ', 2)
        _, path = parts[:2]
        expected = parts[2] if len(parts) == 3 else ''
        manifest[path] = expected

def run(cmd):
    return subprocess.run(list(map(str, cmd)), check=True, capture_output=True)

# Optional answer-only compatibility audit: run each existing successful-output
# manifest case the LLVM emitter admits. Rejections are not language support.
scan = '--scan-supported-linux' in sys.argv
if scan:
    selected = []
    for source in manifest:
        if not source.startswith('tests/'):
            continue  # generated inputs are not part of the source audit
        trial = subprocess.run([hbc,source,str(work/'scan.ll'),'--experimental-llvm','-I','tests'],capture_output=True)
        if trial.returncode == 0:
            selected.append(source.removeprefix('tests/'))
    print('AUDIT admitted successful-output sources',len(selected),flush=True)
for case in selected:
    source = 'tests/' + case
    expected = subprocess.run(['printf','%b',manifest[source]], capture_output=True, check=True).stdout
    for target in ['linux'] + (['windows'] if not scan and env.get('M') and env.get('WINE') else []):
        for backend in ['current', 'llvm']:
            p = str(work / ('reg-' + pathlib.Path(case).stem + '-' + target + '-' + backend))
            asm = p + '.s'
            args = [hbc, source, p + '.ll' if backend == 'llvm' else asm, '--target=' + target, '-I', 'tests']
            if backend == 'llvm':
                args += ['--experimental-llvm']
            run(args)
            objects = [p + '.o']
            if backend == 'llvm':
                run(['python3', base / 'llvm_aot.py', p + '.ll', p + '.o'] + (['windows'] if target == 'windows' else []))
                asm = p + '.ll.runtime.s'
                run(['python3', base / 'link_runtime.py', asm] + (['windows'] if target == 'windows' else []))
                objects += [p + '-rt.o']
            assembler = 'as' if target == 'linux' else env['M'] + '/x86_64-w64-mingw32-as'
            linker = 'ld' if target == 'linux' else env['M'] + '/x86_64-w64-mingw32-ld'
            run([assembler, '-o', objects[-1], asm])
            exe = p + ('.exe' if target == 'windows' else '')
            run([linker, '-o', exe] + objects + (['-e', '_start', '--subsystem', 'console', '-L' + env['MLIB'], '-lkernel32'] if target == 'windows' else []))
            result = subprocess.run(([env['WINE'], exe] if target == 'windows' else [exe]), capture_output=True, timeout=20)
            assert result.returncode == 0 and result.stderr == b'', (case, target, backend, result)
            assert result.stdout == expected, (case, target, backend, result.stdout, expected)
        print('PASS existing regression', case, target)

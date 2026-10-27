#!/usr/bin/env python3
"""Bounded compile/link regression matrix. Never executes generated probes."""
from pathlib import Path
import os
import subprocess

root = Path(__file__).resolve().parent.parent
out = root / 'gen' / 'shape_matrix'
out.mkdir(parents=True, exist_ok=True)
expressions = [
    '1.5', 'x', 'x+1', '(1,x)', '(i++, x)', 'IIF(.T.,x,1)', 'f(1)',
    '"abc"', 's', 'AllTrim(" a ")', '(s)', 'IIF(.T.,s,"b")',
    '{1,2}', 'a', 'Array(2)', '{"a","b"}', '{"k"=>1}', 'h',
    '{|n|n+1}', 'b', 'NIL', 'a[1]', 'sa[1]', '++i', 'i++',
]
contexts = [
    '({e})', '? {e}', '? Len({e})', '? ValType({e})',
    '? IIF(.T.,{e},{e})', '? {e} = {e}', '? Round({e},1)', '? Eval({e},1)',
]
header = '''function f(n)
return n/2
function main()
local x := 1.5
local i := 1
local s := AllTrim(" a ")
local a := Array(2)
local sa := {"a","b"}
local h := {"k"=>1}
local b := {|n|n+1}
'''
expected = [
    '11001110', '11001110', '11001110', '11001110', '11001110',
    '11001110', '11001110', '11111100', '11111100', '11101100',
    '11111100', '11101100', '00000000', '11110000', '10000000',
    '10000000', '00000000', '11100000', '00000001', '10000001',
    '11011100', '11010100', '11011100', '11001110', '11001110',
]
accepted = rejected = 0
for i, expr in enumerate(expressions):
    for j, context in enumerate(contexts):
        source = out / f'p{i}_{j}.hb'
        source.write_text(header + context.format(e=expr) + '\nreturn\n')
        states = []
        for target in ('linux', 'windows'):
            asm, obj = out / 'probe.s', out / 'probe.o'
            result = subprocess.run(
                [str(root / 'hbc'), str(source), str(asm), '--target=' + target],
                capture_output=True, text=True, timeout=15,
            )
            if result.returncode == 1:
                if not result.stderr.startswith('error:') or 'panicked' in result.stderr:
                    raise RuntimeError(f'non-diagnostic rejection: {source} {target}: {result.stderr}')
                rejected += 1
                states.append(False)
                continue
            if result.returncode:
                raise RuntimeError(f'compiler failure: {source} {target}: {result.stderr}')
            if target == 'linux':
                commands = [['as', '-o', str(obj), str(asm)],
                            ['ld', '-o', str(out / 'probe'), str(obj)]]
            else:
                mingw = Path(os.environ['M'])
                commands = [[str(mingw / 'x86_64-w64-mingw32-as'), '-o', str(obj), str(asm)],
                            [str(mingw / 'x86_64-w64-mingw32-ld'), '-o', str(out / 'probe.exe'),
                             str(obj), '-e', '_start', '--subsystem', 'console',
                             '-L' + os.environ['MLIB'], '-lkernel32']]
            for command in commands:
                subprocess.run(command, check=True, capture_output=True, text=True, timeout=15)
            accepted += 1
            states.append(True)
        if states[0] != (expected[i][j] == '1') or states[0] != states[1]:
            raise RuntimeError(f'pinned acceptance changed: {source}')
# Pin the current boundary, rather than silently counting a newly rejected
# successful case as a passing no-panic test. Individual manifest rows own
# detailed diagnostics and runtime/Harbour behavior.
if (accepted, rejected) != (198, 202):
    raise RuntimeError(f'shape boundary changed: linked={accepted} rejected={rejected}')
print(f'COMPILE SHAPE MATRIX PASS: {accepted} linked, {rejected} named rejects, 400 target checks')

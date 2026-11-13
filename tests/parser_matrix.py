#!/usr/bin/env python3
"""Deterministic delimiter/terminator mutation checks. Never executes probes."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parent.parent
out = root / 'gen' / 'parser_matrix'
out.mkdir(parents=True, exist_ok=True)
seeds = [
    '? (1 + 2)', 'local x := {1,2}', '? IIF(.T.,1,2)', '? Len("abc")',
    '? {"x"=>1}', '? {|n|n+1}', 'for i := 1 to 2\n? i\nnext',
    'if .T.\n? 1\nendif', 'do while .F.\n? 1\nenddo',
]
cases = []
for seed in seeds:
    cases.append(seed)
    for i, char in enumerate(seed):
        if char in '()[]{},|':
            cases.extend([seed[:i] + seed[i+1:], seed[:i] + char + char + seed[i+1:]])
    for suffix in ['(', ')', '[', ']', '{', '}', ',', '|', ':=', '++', ';']:
        cases.append(seed + suffix)
cases = list(dict.fromkeys(cases))
expected = '1000000000000001001000000000000010000000000000000001000000000000000000000000000000000000000000000000100000000000100000000000100000000000'
if len(cases) != len(expected):
    raise RuntimeError('parser matrix generation changed')
accepted = rejected = 0
for i, body in enumerate(cases):
    source = out / f'p{i}.prg'
    source.write_text('function main()\nlocal i := 0\n' + body + '\nreturn\n')
    for target in ('linux', 'windows'):
        result = subprocess.run(
            [str(root / 'hbc'), str(source), str(out / 'probe.s'), '--target=' + target],
            capture_output=True, text=True, timeout=5,
        )
        if result.returncode not in (0, 1):
            raise RuntimeError(f'compiler failure p{i} {target}: {result.stderr}')
        if (result.returncode == 0) != (expected[i] == '1'):
            raise RuntimeError(f'pinned parser acceptance changed p{i} {target}: {result.stderr}')
        if result.returncode:
            if not result.stderr.startswith('error:') or 'panicked' in result.stderr:
                raise RuntimeError(f'non-diagnostic failure p{i} {target}: {result.stderr}')
            rejected += 1
        else:
            accepted += 1
print(f'PARSER MATRIX PASS: {accepted} accepted, {rejected} named rejects, {len(cases)*2} target checks')

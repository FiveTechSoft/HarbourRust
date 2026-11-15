"""Raw-byte M1 oracle gate, with same-source ELF/PE pairs and direct-AST controls.
Windows compiler and runtime PE execution use Wine, not native Windows.
Every source/command/channel/status/hash is retained. NEW output directory only.
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
env = {**os.environ, 'WINEPREFIX': a.wine_prefix, 'WINEDEBUG': '-all'}
comp = str(Path(a.compiler).resolve())
pe_comp = str(Path(a.pe_compiler).resolve())
hb = str(Path(a.hbmk2).resolve())
rows = []
commands = []


def run(cmd, d, label, cross=False):
    e = env.copy()
    if cross:
        e.update(PATH=a.mingw_bin + ':' + e['PATH'], HB_CCPATH=a.mingw_bin + '/', HB_CCPREFIX='x86_64-w64-mingw32-', HB_CCSUFFIX='-posix')
    else:
        for key in ['HB_CCPATH', 'HB_CCPREFIX', 'HB_CCSUFFIX']:
            e.pop(key, None)
    q = subprocess.run(cmd, cwd=d, env=e, capture_output=True, timeout=45)
    commands.append(dict(cwd=str(d.relative_to(r)), label=label, argv=[str(x) for x in cmd], cross=cross))
    for ext, value in [('stdout', q.stdout), ('stderr', q.stderr), ('rc', str(q.returncode).encode())]:
        (d / (label + '.' + ext)).write_bytes(value)
    return q


# All contexts emit without implicit platform line endings, including numeric
# width/provenance. This is identical PRG source on both compilers, no rewriting
# of the oracle or output normalization to obtain a PASS.
cases = [
    ('int', '&("10")', '10'),
    ('int-negative', '&("-17")', '-17'),
    ('int-zero', '&("0")', '0'),
    ('integer-add', '&("1+2")', '1+2'),
    ('precedence', '&("1+2*3")', '1+2*3'),
    ('parentheses', '&("(1+2)*3")', '(1+2)*3'),
    ('integer-sub', '&("8-13")', '8-13'),
    ('integer-product', '&("12*7")', '12*7'),
    ('exact-divide', '&("10/2")', '10/2'),
    ('mod', '&("7%3")', '7%3'),
    ('negative-mod', '&("-7%3")', '-7%3'),
    ('string', '&("\'abc\'")', "'abc'"),
    ('string-concat', '&("\'a\'+\'bc\'")', "'a'+'bc'"),
    ('empty-string', '&("\'\'")', "''"),
    ('logical', '&(".T.")', '.T.'),
    ('logical-not', '&(".NOT. .T.")', '.NOT. .T.'),
    ('logical-and', '&(".T. .AND. .F.")', '.T. .AND. .F.'),
    ('logical-or', '&(".F. .OR. .T.")', '.F. .OR. .T.'),
    ('nil', '&("NIL")', 'NIL'),
    ('compare-int', '&("3<5")', '3<5'),
    ('compare-equal', '&("3==3")', '3==3'),
    ('compare-ne', '&("3<>5")', '3<>5'),
    ('compare-bool', '&(".T.==.F.")', '.T.==.F.'),
    ('compare-string', '&("\'abc\'==\'abc\'")', "'abc'=='abc'"),
    ('contains', '&("\'b\'$\'abc\'")', "'b'$'abc'"),
    ('literal-concat-producer', '&("1"+"+2")', '1+2'),
    ('parenthesized-producer', '&(("1")+("+"+"2"))', '1+2'),
    ('case-insensitive-literal', '&("nil")', 'NIL'),
    ('integer-eq', '&("3=3")', '3=3'),
    ('integer-le', '&("3<=3")', '3<=3'),
    ('integer-ge', '&("3>=5")', '3>=5'),
    ('integer-gt', '&("5>3")', '5>3'),
    ('logical-eq', '&(".T.=.T.")', '.T.=.T.'),
    ('logical-ne', '&(".T.<>.F.")', '.T.<>.F.'),
    ('positive-unary', '&("+17")', '+17'),
    ('negative-product', '&("-12*7")', '-12*7'),
    ('max-i64', '&("9223372036854775807")', '9223372036854775807'),
    ('min-supported-i64', '&("-9223372036854775807")', '-9223372036854775807'),
    ('contains-empty', '&("\'\'$\'abc\'")', "''$'abc'"),
    ('string-trailing-space', '&("\'a \'==\'a\'")', "'a '=='a'"),
    ('nested-string-concat', '&("(\'a\'+\'b\')+\'c\'")', "('a'+'b')+'c'"),
    ('spaced-amp', '& ("1+2")', '1+2'),
    ('outside-arithmetic', '5+&("2*3")*2', '5+(2*3)*2'),
    ('outside-type', 'ValType(&("10"))', 'ValType(10)'),
    ('outside-string-call', 'Len(&("\'hello\'"))', "Len('hello')"),
]

for target in ['linux', 'windows']:
    for name, expr, direct in cases:
        d = r / target / name
        d.mkdir(parents=True)
        src = 'function Main()\n?? ' + expr + '\nreturn nil\n'
        (d / 'case.prg').write_text(src)
        q = run([hb, 'case.prg', '-gtstd', '-oofficial'] + (['-plat=win', '-comp=mingw64'] if target == 'windows' else []), d, 'oracle-build', target == 'windows')
        assert q.returncode == 0 and not q.stderr, (name, target, 'oracle-build', q.stderr)
        oracle = d / ('official.exe' if target == 'windows' else 'official')
        q = run(([a.wine] if target == 'windows' else []) + [str(oracle)], d, 'oracle-run')
        assert q.returncode == 0 and not q.stderr, (name, target, 'oracle-run')
        expected = q.stdout
        for instrument in [False, True]:
            tag = 'instrumented' if instrument else 'plain'
            own = d / ('own-' + tag + ('.exe' if target == 'windows' else ''))
            cli = [a.wine, pe_comp] if target == 'windows' else [comp]
            q = run(cli + ['case.prg', str(own), '--target=' + target] + (['--instrument'] if instrument else []), d, tag + '-build')
            assert q.returncode == 0 and not q.stderr, (name, target, tag, q.stderr)
            q = run(([a.wine] if target == 'windows' else []) + [str(own)], d, tag + '-run')
            raw = q.stdout == expected and q.returncode == 0 and not q.stderr
            secondary = q.stdout.replace(b'\r\n', b'\n') == expected.replace(b'\r\n', b'\n')
            rows.append(dict(case=name, target=target, mode=tag, raw_exact=raw, CRLF_normalized_equal=secondary, exit=q.returncode))
            assert raw, (name, target, tag, expected, q.stdout, q.stderr)
            # Exact emitted assembly controls avoid PE timestamp/checksum
            # changes across separate compiler invocations. Never mask bytes.
            macro_asm = d / (tag + '-macro.s')
            q = run(cli + ['case.prg', str(macro_asm), '--target=' + target] + (['--instrument'] if instrument else []), d, tag + '-macro-asm-build')
            assert q.returncode == 0 and not q.stderr
            (d / 'case.prg').write_text('function Main()\n?? ' + direct + '\nreturn nil\n')
            control = d / ('direct-' + tag + ('.exe' if target == 'windows' else ''))
            q = run(cli + ['case.prg', str(control), '--target=' + target] + (['--instrument'] if instrument else []), d, tag + '-direct-build')
            assert q.returncode == 0 and not q.stderr
            direct_asm = d / (tag + '-direct.s')
            q = run(cli + ['case.prg', str(direct_asm), '--target=' + target] + (['--instrument'] if instrument else []), d, tag + '-direct-asm-build')
            assert q.returncode == 0 and not q.stderr
            assert macro_asm.read_bytes() == direct_asm.read_bytes(), (name, target, tag, 'assembly-byte-identity')
            if target == 'linux':
                assert own.read_bytes() == control.read_bytes(), (name, target, tag, 'ELF-byte-identity')
            (d / 'case.prg').write_text(src)
        # Retain bytes hashes, not bulky executables for every oracle case.
        hashes = {x.name: hashlib.sha256(x.read_bytes()).hexdigest() for x in d.iterdir() if x.name.startswith(('own-', 'direct-', 'official')) and x.suffix not in ['.stdout', '.stderr', '.rc']}
        (d / 'binary-shas.json').write_text(json.dumps(hashes, indent=2) + '\n')
        for x in list(d.iterdir()):
            if x.name in hashes:
                x.unlink()
        sizes = {x.name: dict(raw_bytes=x.stat().st_size, sha256=hashlib.sha256(x.read_bytes()).hexdigest()) for x in d.glob('*.s')}
        (d / 'assembly-sizes.json').write_text(json.dumps(sizes, indent=2) + '\n')
        for x in d.glob('*.s'):
            x.unlink()
        print('PASS', target, name)

# Compile-time capacity rejections only. Since the runtime evaluator
# (docs/MACRO-M1-RUNTIME-2026-11-15.md), dynamic text, names, calls,
# invalid or deferred-error text, floats, powers, lists, nested macros and
# array/hash/block literals compile and are decided at run time like
# Harbour (tests/macro/*.prg pins those against the Harbour oracle).
negative = [
    ('lvalue', '&("hidden") := 1'),
    ('statement', '&("1+2")'),
    ('send', 'local o := nil\n? o:&("message")'),
    ('bad-producer', '? &(1)'),
    ('no-close', '? &("1"'),
]
for target in ['linux', 'windows']:
    cli = [a.wine, pe_comp] if target == 'windows' else [comp]
    for name, body in negative:
        d = r / 'negative' / target / name
        d.mkdir(parents=True)
        (d / 'case.prg').write_text('function Main()\n' + body + '\nreturn nil\n')
        own = d / 'must-not-exist'
        q = run(cli + ['case.prg', str(own), '--target=' + target], d, 'compile')
        assert q.returncode != 0 and b'macro M1 capacity limit' in q.stderr and not own.exists(), (name, target, q.stderr)
        rows.append(dict(case=name, target=target, mode='negative', capacity_rejection=True))
        print('PASS negative', target, name)
(r / 'commands.json').write_text(json.dumps(commands, indent=2) + '\n')
(r / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
print('PASS', len(rows), 'pair/mode and rejection rows')

#!/usr/bin/env python3
"""Bounded HB_ISSTRING: real Harbour oracle, Linux/Wine, negative profiles.
The implementation source of Harbour is not read or translated by this checker.
"""
import argparse
import hashlib
import json
import re
import time
import os
import tempfile
from pathlib import Path
import subprocess

CASES = {'callstatement': 'HB_ISSTRING("x")\n? "done"',
 'casefold': '? hb_isstring("a"), Hb_IsString("b"), HB_ISSTRING("c")',
 'conditions': 'local s:="abc", b:=HB_ISSTRING(s)\n'
               'if b .AND. HB_ISSTRING(s)\n'
               '? "yes"\n'
               'endif\n'
               '? b,HB_ISSTRING(s)==.T.,.NOT.HB_ISSTRING(42)',
 'date_calls': '? HB_ISSTRING(CToD("")), HB_ISSTRING(CToD(AllTrim(" 1/5/1999 ")))',
 'dyn': 'local x\n'
        '? HB_ISSTRING(x)\n'
        'x:="abc"\n'
        '? HB_ISSTRING(x),x\n'
        'x:=42\n'
        '? HB_ISSTRING(x),x\n'
        'x:=.T.\n'
        '? HB_ISSTRING(x),x\n'
        'x:=NIL\n'
        '? HB_ISSTRING(x),ValType(x)',
 'hash_cells': 'local h:={"n"=>1,"b"=>.T.,"u"=>NIL}\n'
               '? HB_ISSTRING(h), '
               'HB_ISSTRING(h["n"]),HB_ISSTRING(h["b"]),HB_ISSTRING(h["u"])\n'
               '? h["n"],Len(h)',
 'index_effect_fn': 'local a:={"abc",NIL},i:=0\n'
                    '? HB_ISSTRING(a[Bump(@i)]),i\n'
                    'return nil\n'
                    'function Bump(i)\n'
                    'i:=i+1\n'
                    'return i',
 'literals': '? HB_ISSTRING(), HB_ISSTRING(NIL), HB_ISSTRING(""), HB_ISSTRING("abc"), '
             'HB_ISSTRING(1), HB_ISSTRING(.T.), HB_ISSTRING(.F.), HB_ISSTRING(1.5)',
 'mixed_cells': 'local a:={"abc",NIL,42,.T.}, i:=0\n'
                '? '
                'HB_ISSTRING(a[++i]),i,HB_ISSTRING(a[++i]),i,HB_ISSTRING(a[++i]),i,HB_ISSTRING(a[++i]),i\n'
                '? Len(a),a[1]',
 'nested': 'local a:=Array(2,2)\n'
           'a[1][1]:=42\n'
           '? HB_ISSTRING(a[1]), HB_ISSTRING(a[1][1]), HB_ISSTRING(a[1][2])',
 'output_effects': '? HB_ISSTRING(QOut("seen")),HB_ISSTRING(OutStd("raw"))',
 'owned': 'local s := Replicate("x",3), e := Chr(0), z := ""\n'
          '? HB_ISSTRING(s), HB_ISSTRING(e), HB_ISSTRING(z)\n'
          '? Len(s), Len(e), Len(z), s',
 'string_cells': 'local a:={"abc",""}\n? HB_ISSTRING(a[1]),HB_ISSTRING(a[2]),a[1],Len(a)',
 'variables': 'local n:=1, f:=1.5, b:=.T., d:=CToD(""), a:={1,2}, h:={"k"=>1}, c:={||1}\n'
              '? HB_ISSTRING(n), HB_ISSTRING(f), HB_ISSTRING(b), HB_ISSTRING(d), '
              'HB_ISSTRING(a), HB_ISSTRING(h), HB_ISSTRING(c)\n'
              '? n,f,b,d,Len(a),h["k"]',
 'wrapper': '? Check("text"),Check(42),Check(NIL),Check(.T.)\n'
            'return nil\n'
            'function Check(x)\n'
            'return HB_ISSTRING(x)'}
CASES.update({
 'object_variable': '#include "hbclass.ch"\nCREATE CLASS Sample\nMETHOD New() CONSTRUCTOR\nENDCLASS\nMETHOD New() CLASS Sample\nreturn Self\nfunction Main()\nlocal o:=Sample():New()\n? HB_ISSTRING(o)\nreturn nil',
 'method_reads': '#include "hbclass.ch"\nCREATE CLASS Sample\nMETHOD New() CONSTRUCTOR\nMETHOD Check()\nENDCLASS\nMETHOD New() CLASS Sample\nreturn Self\nMETHOD Check() CLASS Sample\nlocal me:=Self, s:=Replicate("x",3)\n? HB_ISSTRING(me),HB_ISSTRING(s),s\nreturn HB_ISSTRING(s)\nfunction Main()\nlocal o:=Sample():New()\n? o:Check()\nreturn nil'
})

NEGATIVES = {
    'reserved-symbol': ('return nil\nfunction HB_ISSTRING()\nreturn nil', 'reserved'),
    'persistent-root': ('STATIC r\n? HB_ISSTRING(r)', 'persistent'),
    'extra-effects': ('? HB_ISSTRING("x",QOut("must not be dropped"))', 'extra-argument effects'),
    'temp-string': ('? HB_ISSTRING(Replicate("x",3))', 'measured ValType read contract'),
    'string-expression': ('? HB_ISSTRING("a"+"b")', 'measured ValType read contract'),
    'array-literal': ('? HB_ISSTRING({1,2})', 'measured ValType read contract'),
    'hash-literal': ('? HB_ISSTRING({"k"=>1})', 'measured ValType read contract'),
    'block-literal': ('? HB_ISSTRING({||1})', 'measured ValType read contract'),
    'missing-variable': ('? HB_ISSTRING(unknown)', 'unknown'),
    'byref-argument': ('local x:=1\n? HB_ISSTRING(@x)', 'measured ValType read contract'),
    'hash-temp-key': ('local h:={"k"=>1}\n? HB_ISSTRING(h[Chr(107)])', 'hash keys must be literals or variables'),
    'moved-owner': ('local x:=Replicate("x",3), y:=x\n? HB_ISSTRING(x)', 'moved'),
}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['compiler', 'hbmk2', 'output', 'mingw-bin', 'mingw-lib', 'wine']:
        p.add_argument('--' + name, required=True)
    p.add_argument("--targets", nargs="+", choices=["linux", "windows"], default=["linux", "windows"])
    p.add_argument("--wine-baseline", help="Published baseline executable for paired five-attempt environment control")
    p.add_argument("--resume", action="store_true")
    p.add_argument("--time-budget", type=int, default=0)
    a = p.parse_args()
    started = time.monotonic()
    compiler, hbmk2 = str(Path(a.compiler).resolve()), str(Path(a.hbmk2).resolve())
    out = Path(a.output).absolute()
    out.mkdir(exist_ok=a.resume)
    rows = []
    wine_attempts = []

    def sha(path):
        return hashlib.sha256(Path(path).read_bytes()).hexdigest()

    def atomic(path, data):
        tmp = path.with_name(path.name + '.tmp')
        tmp.write_text(json.dumps(data, indent=2) + '\n')
        tmp.replace(path)

    cohort = {
        'version': 2, 'compiler': sha(compiler), 'hbmk2': sha(hbmk2),
        'checker': sha(__file__), 'cases': CASES, 'negatives': NEGATIVES,
        'targets': a.targets, 'wine_baseline': sha(a.wine_baseline) if a.wine_baseline else None,
        'wine': str(Path(a.wine).resolve()), 'wine_loader_sha': sha(a.wine),
        'mingw_as_sha': sha(Path(a.mingw_bin) / 'x86_64-w64-mingw32-as'),
        'mingw_ld_sha': sha(Path(a.mingw_bin) / 'x86_64-w64-mingw32-ld'),
        'kernel32_import_sha': sha(Path(a.mingw_lib) / 'libkernel32.a'),
        'prefix': os.environ.get('WINEPREFIX'), 'wine_debug': os.environ.get('WINEDEBUG'),
        'pair_order': 'even baseline-first, odd candidate-first', 'attempts': 5,
        'timeout_seconds': 90,
    }
    manifest = out / 'cohort.json'
    if manifest.exists():
        assert a.resume and json.loads(manifest.read_text()) == json.loads(json.dumps(cohort)), 'cohort differs'
    else:
        atomic(manifest, cohort)


    def run(cmd, work, name):
        cmd = [str(x) for x in cmd]
        record = work / (name + '.record.json')
        fingerprints = {}
        outputs = set()
        if '-o' in cmd:
            outputs.add(cmd[cmd.index('-o') + 1])
        if cmd[0] == compiler and len(cmd) > 2:
            outputs.add(cmd[2])
        for value in cmd:
            if value in outputs:
                continue
            path = Path(value) if Path(value).is_absolute() else work / value
            if path.is_file():
                fingerprints[value] = sha(path)
        if a.resume and record.exists():
            saved = json.loads(record.read_text())
            assert saved['argv'] == cmd and saved['inputs'] == fingerprints, (name, 'resume input mismatch')
            if saved.get('inflight'):
                atomic(record, {**saved, 'inflight': False, 'returncode': 125, 'interrupted': True})
                (work / (name + '.stdout')).write_bytes(b'')
                (work / (name + '.stderr')).write_bytes(b'Interrupted attempt: outcome unknown; never rerun.\n')
                (work / (name + '.rc')).write_text('125\n')
                saved = json.loads(record.read_text())
            return subprocess.CompletedProcess(cmd, saved['returncode'],
                (work / (name + '.stdout')).read_bytes(), (work / (name + '.stderr')).read_bytes())
        if a.time_budget and time.monotonic() - started >= a.time_budget:
            raise SystemExit(75)
        atomic(record, {'stage': name, 'argv': cmd, 'inputs': fingerprints, 'inflight': True})
        launch = time.monotonic()
        timeout = False
        try:
            result = subprocess.run(cmd, cwd=work, stdin=subprocess.DEVNULL,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=90)
        except subprocess.TimeoutExpired as exc:
            timeout = True
            result = subprocess.CompletedProcess(cmd, 124, exc.stdout or b'', exc.stderr or b'')
        (work / (name + '.stdout')).write_bytes(result.stdout)
        (work / (name + '.stderr')).write_bytes(result.stderr)
        (work / (name + '.rc')).write_text(str(result.returncode) + '\n')
        atomic(record, {'stage': name, 'argv': cmd, 'inputs': fingerprints,
                       'returncode': result.returncode, 'timeout': timeout,
                       'elapsed_seconds': time.monotonic() - launch,
                       'stdout_sha256': hashlib.sha256(result.stdout).hexdigest(),
                       'stderr_sha256': hashlib.sha256(result.stderr).hexdigest()})
        return result

    def build(cmd, work, name):
        r = run(cmd, work, name)
        if r.returncode:
            raise RuntimeError(f'{name}: {cmd}: {r.stderr!r}')

    def body_source(body):
        if body.startswith('#include'):
            return body + '\n'
        return 'function Main()\n' + body + ('\nreturn nil\n' if '\nfunction ' not in body else '\n')

    def execute_source(source, work, label, target, instrument):
        stem = f'{label}-{target}-' + ('instrument' if instrument else 'normal')
        build([compiler, source, stem + '.s', '--target=' + target] +
              (['--instrument'] if instrument else []), work, stem + '-compile')
        if target == 'linux':
            build(['as', stem + '.s', '-o', stem + '.o'], work, stem + '-as')
            build(['ld', stem + '.o', '-o', stem], work, stem + '-ld')
            return run(['./' + stem], work, stem + '-run')
        build([Path(a.mingw_bin) / 'x86_64-w64-mingw32-as', stem + '.s', '-o', stem + '.o'], work, stem + '-as')
        build([Path(a.mingw_bin) / 'x86_64-w64-mingw32-ld', stem + '.o', '-o', stem + '.exe',
               '-e', '_start', '--subsystem', 'console', '-L' + a.mingw_lib, '-lkernel32'], work, stem + '-ld')
        if not a.wine_baseline:
            return run([a.wine, stem + '.exe'], work, stem + '-run')
        actuals = []
        pair_records = []
        pattern = rb"wine: Unhandled page fault on read access to 0000000000000008 at address 00006FFFFB6B8067 \(thread [0-9a-f]+\), starting debugger\.\.\.\n"
        for attempt in range(5):
            order = ['baseline', 'candidate'] if attempt % 2 == 0 else ['candidate', 'baseline']
            results = {}
            for who in order:
                exe = a.wine_baseline if who == 'baseline' else stem + '.exe'
                suffix = 'baseline' if who == 'baseline' else 'attempt'
                results[who] = run([a.wine, exe], work, stem + f'-{suffix}-{attempt}')
            for who in ['baseline', 'candidate']:
                result = results[who]
                if result.returncode == 125:
                    mode = 'interrupted'
                elif result.returncode == 124:
                    mode = 'timeout'
                elif result.returncode == 0 and not result.stderr:
                    mode = 'clean'
                elif result.returncode == 0 and re.fullmatch(pattern, result.stderr):
                    mode = 'known-page-fault'
                else:
                    mode = 'unexpected'
                row = {'binary': stem, 'label': who, 'attempt': attempt, 'mode': mode,
                       'environmental_fault': mode != 'clean', 'returncode': result.returncode}
                if who == 'baseline':
                    row['baseline_bytes_exact'] = result.stdout == b'\nHello from HarbourRust'
                wine_attempts.append(row)
                pair_records.append(row)
            atomic(out / 'wine-attempts.json', wine_attempts)
            actuals.append(results['candidate'])
        # Do not stop inside a five-pair block. Record every attempt before judging.
        counts = {who: sum(r['mode'] != 'clean' for r in pair_records if r['label'] == who)
                  for who in ['baseline', 'candidate']}
        modes = {who: {r['mode'] for r in pair_records if r['label'] == who and r['mode'] != 'clean'}
                 for who in ['baseline', 'candidate']}
        passed = (counts['candidate'] <= counts['baseline'] and
                  modes['candidate'].issubset(modes['baseline']) and
                  'unexpected' not in modes['candidate'] and
                  all(r.get('baseline_bytes_exact', True) for r in pair_records))
        clean_results = [x for x in actuals if x.returncode == 0 and not x.stderr]
        passed = passed and bool(clean_results) and len({x.stdout for x in actuals}) == 1
        atomic(work / (stem + '-wine-verdict.json'), {'counts': counts, 'passed': passed,
               'modes': {k: sorted(v) for k,v in modes.items()}})
        # Keep collecting the full cohort even if one executable fails its rule.
        return clean_results[0] if clean_results else actuals[-1]

    for name, body in CASES.items():
        work = out / name
        work.mkdir(exist_ok=a.resume)
        source = body_source(body)
        (work / 'probe.prg').write_text(source)
        (work / 'probe.prg').write_text(source)
        build([hbmk2, 'probe.prg', '-gtstd', '-ooracle'], work, 'oracle-build')
        oracle = run(['./oracle'], work, 'oracle-run')
        assert oracle.returncode == 0 and not oracle.stderr, name
        for target in a.targets:
            if target == 'windows' and name in ['object_variable', 'method_reads']:
                rejection = run([compiler, 'probe.prg', 'class-must-not-exist.s', '--target=windows'], work, 'class-windows-rejection')
                exact = (rejection.returncode == 1 and rejection.stderr == b'error: classes are Linux-only in this increment (the Windows runtime blob is pending)\n' and not (work / 'class-must-not-exist.s').exists())
                rows.append({'case': name, 'target': target, 'class_limit': True, 'exact': exact})
                assert exact, (name, rejection.returncode, rejection.stderr)
                continue
            for instrument in [False, True]:
                actual = execute_source('probe.prg', work, 'candidate', target, instrument)
                equal = (actual.returncode, actual.stdout, actual.stderr) == (oracle.returncode, oracle.stdout, oracle.stderr)
                rows.append({'case': name, 'target': target, 'instrument': instrument, 'exact': equal,
                             'sha256': hashlib.sha256(source.encode()).hexdigest()})
                assert equal, (name, target, instrument, actual.stdout, actual.stderr)

    for name, (body, diagnostic) in NEGATIVES.items():
        work = out / ('negative-' + name)
        work.mkdir(exist_ok=a.resume)
        (work / 'probe.prg').write_text(body_source(body))
        for target in a.targets:
            r = run([compiler, 'probe.prg', 'must-not-exist.s', '--target=' + target], work, target)
            safe = r.returncode == 1 and diagnostic.encode() in r.stderr and not (work / 'must-not-exist.s').exists()
            rows.append({'case': name, 'target': target, 'negative': True, 'exact': safe})
            assert safe, (name, target, r.returncode, r.stderr)

    work = out / 'llvm-rejection'
    work.mkdir(exist_ok=a.resume)
    (work / 'probe.prg').write_text(body_source('? HB_ISSTRING("x")'))
    for target in a.targets:
        for mode in ['--experimental-llvm', '--experimental-llvm-no-trace']:
            r = run([compiler, 'probe.prg', 'must-not-exist.ll', '--target=' + target, mode], work, target + mode)
            safe = r.returncode == 1 and b'LLVM scalar: expression unsupported' in r.stderr and not (work / 'must-not-exist.ll').exists()
            rows.append({'case': 'llvm', 'target': target, 'mode': mode, 'exact': safe})
            assert safe, (target, mode, r.stderr)

    # Instrumentation-only resource check, not a Harbour builtin oracle.
    work = out / 'balance'
    work.mkdir(exist_ok=a.resume)
    (work / 'probe.prg').write_text(body_source('''local s:=Replicate("x",3), a:={"a",NIL}, h:={"k"=>1}, i:=0, n:=hb_memcheck()
for i:=1 to 500
HB_ISSTRING(s)
HB_ISSTRING(a[1])
HB_ISSTRING(a[2])
HB_ISSTRING(h["k"])
HB_ISSTRING(CToD(AllTrim(" 1/5/1999 ")))
next
? hb_memcheck()==n'''))
    for target in a.targets:
        r = execute_source('probe.prg', work, 'balance', target, True)
        safe = r.returncode == 0 and r.stdout == b'\n.T.' and not r.stderr
        rows.append({'case': 'balance', 'target': target, 'exact': safe})
        assert safe, (target, r.stdout, r.stderr)

    if 'linux' in a.targets:
        # Power control: a wrong tag test must exit normally but differ in bytes.
        work = out / 'dyn'
        assembly = (work / 'candidate-linux-instrument.s').read_text()
        assert '    cmpb $67, (%rax)' in assembly
        (work / 'mutant.s').write_text(assembly.replace('    cmpb $67, (%rax)', '    cmpb $78, (%rax)'))
        build(['as', 'mutant.s', '-o', 'mutant.o'], work, 'mutant-as')
        build(['ld', 'mutant.o', '-o', 'mutant'], work, 'mutant-ld')
        r = run(['./mutant'], work, 'mutant-run')
        caught = r.returncode == 0 and r.stdout != (work / 'oracle-run.stdout').read_bytes()
        rows.append({'case': 'wrong-tag-control', 'exact': caught})
        assert caught
    if wine_attempts:
        (out / 'wine-attempts.json').write_text(json.dumps(wine_attempts, indent=2) + '\n')
        counts = {label: sum(x['environmental_fault'] for x in wine_attempts if x['label'] == label)
                  for label in ['baseline', 'candidate']}
        print('WINE environmental faults, equal attempt counts:', counts)
        verdicts = [json.loads(p.read_text()) for p in out.rglob('*-wine-verdict.json')]
        assert counts['candidate'] <= counts['baseline'] and all(v['passed'] for v in verdicts), counts
    (out / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
    print(f"PASS {len(rows)} checks across {a.targets}: oracle comparisons, negative target checks, LLVM rejections, balance checks, wrong-code control")


if __name__ == '__main__':
    main()

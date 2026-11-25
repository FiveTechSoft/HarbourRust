#!/usr/bin/env python3
"""Parser probes for the strict two-state memdelta classifier
(reviewer CATCH v3): unexpected rc, missing DELTA and extra stderr
garbage must all be REJECTED; only the two exact states pass.
Section A feeds synthetic run records through classify_memdelta.
Section B runs the real harness end-to-end on a program that errors
BEFORE the balance guard and requires rejection.
Usage: python3 selftest_emit_delta.py [--e2e /path/to/hbc]"""
import os, pathlib, sys, tempfile
P = pathlib.Path
sys.path.insert(0, str(P(__file__).resolve().parent))
from memdelta_guard import classify_memdelta, emit_delta

EXP = b'\ndone'
CASES = [
    ('accept balanced',            (0, b'', EXP, EXP),                  (0, True)),
    ('accept measured delta',      (99, b'DELTA=2\n', EXP, EXP),        (2, True)),
    ('reject rc unexpected',       (1, b'', EXP, EXP),                  (None, False)),
    ('reject rc0 with DELTA',      (0, b'DELTA=2\n', EXP, EXP),         (None, False)),
    ('reject DELTA absent',        (99, b'', EXP, EXP),                 (None, False)),
    ('reject garbage before',      (99, b'junk\nDELTA=2\n', EXP, EXP),  (None, False)),
    ('reject garbage after',       (99, b'DELTA=2\nextra\n', EXP, EXP), (None, False)),
    ('reject DELTA no newline',    (99, b'DELTA=2', EXP, EXP),          (None, False)),
    ('reject stdout mismatch 99',  (99, b'DELTA=2\n', b'\nxxx', EXP),   (None, False)),
    ('reject stdout mismatch 0',   (0, b'', b'\nxxx', EXP),             (None, False)),
    ('reject segfault rc139',      (139, b'', b'', EXP),                (None, False)),
]
fails = 0
for name, (rc, err, out, exp), (wd, wok) in CASES:
    got = classify_memdelta(rc, err, out, exp)
    ok = got['delta'] == wd and got['state_ok'] == wok
    print(('PASS' if ok else 'FAIL'), name, '->', got['delta'], got['state_ok'])
    fails += 0 if ok else 1

if '--e2e' in sys.argv:
    compiler = sys.argv[sys.argv.index('--e2e') + 1]
    env = os.environ.copy(); env['LC_ALL'] = 'C.UTF-8'
    with tempfile.TemporaryDirectory() as td:
        td = P(td)
        src = td / 'early_fail.prg'
        # x := a[9] + 1 on a 1-element array: our runtime raises
        # "NIL used as a number" and exits rc 1 BEFORE the epilogue,
        # so the guard never runs: no DELTA line at all.
        # runtime bound error via a non-foldable index: the process dies
        # BEFORE the epilogue, so the guard never runs (no DELTA line)
        src.write_text('function boom(i)\n   local a := {1}\n   return a[i] + 1\n'
                       'function main()\n   ? boom(9)\nreturn nil\n')
        try:
            rec = emit_delta(compiler, env, str(src), td, b'')
            ok = rec['state_ok'] is False and rec['delta'] is None
            print(('PASS' if ok else 'FAIL'), 'e2e early-failure rejected ->',
                  'rc=%s' % rec['rc'], 'stderr=%r' % rec['stderr'][:50], 'state_ok=%s' % rec['state_ok'])
            fails += 0 if ok else 1
        except AssertionError as e:
            # Infrastructure refusal is not evidence of executing the early
            # runtime error. The safety behavior may be fail-closed, but the
            # end-to-end control itself failed and must not print PASS.
            print('FAIL e2e harness did not reach runtime control ->', str(e)[:70])
            fails += 1
sys.exit(1 if fails else 0)

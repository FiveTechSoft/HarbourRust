#!/usr/bin/env python3
"""Unit tests for native runner triage and real sleep duration windows.

A row named in EXPECTED_REJ counts as REJ only when the compiler exits
normally (rc 1, never a signal) with the row's registered diagnostic
substring. These probes use fake compiler scripts to distinguish an
exact rejection from a crash, an abnormal rc, a different error and a
successful compile (which must leave the named row to the stale-REJ
guard). With HBC=<path to a real hbc> the five idlesleep rows are
checked to compile for both Mach-O targets.
"""
import importlib.util, os, subprocess, tempfile, unittest
from unittest.mock import patch

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('run_macho_arm64', os.path.join(HERE, 'run_macho_arm64.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
ROW = 'tests/synthetic_named_limit.prg'
DIAGNOSTIC = 'synthetic diagnostic'


def run_fake(script):
    d = tempfile.mkdtemp()
    p = os.path.join(d, 'hbc')
    with open(p, 'w') as fh:
        fh.write(script)
    os.chmod(p, 0o755)
    c = subprocess.run([p, 'x.prg', 'x', '--target=macho-arm64'], capture_output=True)
    return c.returncode, c.stderr.decode('latin-1')


class ClassifyCompileFailureTests(unittest.TestCase):
    def setUp(self):
        self.scope = patch.dict(m.EXPECTED_REJ, {ROW: DIAGNOSTIC}, clear=True)
        self.scope.start()
        self.addCleanup(self.scope.stop)

    def test_exact_rejection_is_rej(self):
        rc, err = run_fake("#!/bin/sh\necho 'synthetic diagnostic' >&2\nexit 1\n")
        self.assertEqual(rc, 1)
        self.assertEqual(m.classify_compile_failure(ROW, rc, err)[0], 'REJ')

    def test_crash_is_fail(self):
        rc, err = run_fake('#!/bin/sh\nkill -SEGV $$\n')
        self.assertLess(rc, 0)  # terminated by a signal, not an exit code
        kind, msg = m.classify_compile_failure(ROW, rc, err)
        self.assertEqual(kind, 'FAIL')
        self.assertIn('signal', msg)

    def test_abnormal_rc_is_fail(self):
        rc, err = run_fake('#!/bin/sh\necho "thread panicked" >&2\nexit 101\n')
        self.assertEqual(rc, 101)
        kind, msg = m.classify_compile_failure(ROW, rc, err)
        self.assertEqual(kind, 'FAIL')
        self.assertIn('rc=101', msg)

    def test_wrong_message_is_fail(self):
        rc, err = run_fake('#!/bin/sh\necho "error: line 2: some other named limit" >&2\nexit 1\n')
        kind, msg = m.classify_compile_failure(ROW, rc, err)
        self.assertEqual(kind, 'FAIL')
        self.assertIn('wrong diagnostic', msg)

    def test_unnamed_row_stays_rej(self):
        rc, err = run_fake('#!/bin/sh\necho "error: line 1: anything" >&2\nexit 1\n')
        kind, _ = m.classify_compile_failure('tests/other.prg', rc, err)
        self.assertEqual(kind, 'REJ')  # unexpected REJ: main() fails the battery on it

    def test_success_leaves_row_to_stale_guard(self):
        rc, _ = run_fake('#!/bin/sh\nexit 0\n')
        self.assertEqual(rc, 0)  # classify_compile_failure is never called on rc 0
        res = [('PASS', ROW, '')]  # the named row ran instead of rejecting
        self.assertIn(ROW, m.stale_named_rejections(res))  # main() fails the battery on it

    def test_stale_guard_end_to_end_with_real_dict(self):
        # The exact main() path over the real EXPECTED_REJ dict
        # (run 44039075657 crashed here with TypeError: dict - set).
        rows = sorted(m.EXPECTED_REJ)
        all_rej = [('REJ', f, 'error: line 2: named limit') for f in rows]
        self.assertEqual(m.stale_named_rejections(all_rej), [])
        one_pass = [('REJ', f, 'x') for f in rows[1:]] + [('PASS', rows[0], '')]
        self.assertEqual(m.stale_named_rejections(one_pass), [rows[0]])
        crash_row = [('FAIL', rows[0], 'named-limit row killed by signal 11: ?')] + [('REJ', f, 'x') for f in rows[1:]]
        self.assertEqual(m.stale_named_rejections(crash_row), [rows[0]])
        self.assertEqual(m.stale_named_rejections([]), rows)


@unittest.skipUnless(os.environ.get('HBC'), 'set HBC to a real hbc to classify its actual rejection')
class RealCompilerTest(unittest.TestCase):
    def test_real_idlesleep_compile(self):
        d = tempfile.mkdtemp()
        prg = os.path.join(d, 'idl.prg')
        with open(prg, 'w') as fh:
            fh.write('function main()\n   hb_idleSleep(0.1)\nreturn nil\n')
        c = subprocess.run([os.environ['HBC'], prg, os.path.join(d, 'idl'), '--target=macho-arm64'],
                           capture_output=True)
        self.assertEqual(c.returncode, 0, c.stderr)

    def test_real_both_targets_compile_all_five(self):
        for target in ('--target=macho-arm64', '--target=macho'):
            for row in m.IDLESLEEP_WINDOWS:
                with tempfile.TemporaryDirectory() as d:
                    c = subprocess.run([os.environ['HBC'], row, os.path.join(d, 'probe'), target], capture_output=True)
                    self.assertEqual(c.returncode, 0, (target, row, c.stderr))


class TimingTests(unittest.TestCase):
    def test_no_named_rejections_on_either_target(self):
        try:
            for target in ('macho', 'macho-arm64'):
                m.configure_target(target)
                self.assertEqual(m.EXPECTED_REJ, {})
                self.assertEqual(m.TARGET, '--target=' + target)
        finally:
            m.configure_target('macho-arm64')

    def test_empty_map_has_no_stale_names(self):
        self.assertEqual(m.EXPECTED_REJ, {})
        self.assertEqual(m.stale_named_rejections([]), [])

    def test_all_native_windows_and_noop_guard(self):
        for row, window in m.IDLESLEEP_WINDOWS.items():
            line = next(l.strip() for l in open(os.path.join(HERE,'manifest.txt')) if l.startswith('pos2 '+row+' '))
            want = open(line.split()[2],'rb').read()
            compiled = subprocess.CompletedProcess([],0,b'',b'')
            ran = subprocess.CompletedProcess([],0,want,b'')
            for elapsed, status in [(sum(window)/2,'PASS'), (window[1]+0.01,'FAIL')]:
                with self.subTest(row=row,elapsed=elapsed), patch.object(m.subprocess,'run',side_effect=[compiled,ran]), patch.object(m.time,'monotonic',side_effect=[100,100+elapsed]):
                    self.assertEqual(m.run_case(line,'fake','/tmp')[0],status)
            if window[0] > 0:
                with self.subTest(row=row,noop=True), patch.object(m.subprocess,'run',side_effect=[compiled,ran]), patch.object(m.time,'monotonic',side_effect=[100,100.001]):
                    self.assertEqual(m.run_case(line,'fake','/tmp')[0],'FAIL')



if __name__ == '__main__':
    unittest.main()

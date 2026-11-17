#!/usr/bin/env python3
"""Unit tests for tests/run_macho_arm64.py's named-rejection triage.

A row named in EXPECTED_REJ counts as REJ only when the compiler exits
normally (rc 1, never a signal) with the row's registered diagnostic
substring. These probes use fake compiler scripts to distinguish an
exact rejection from a crash, an abnormal rc, a different error and a
successful compile (which must leave the named row to the stale-REJ
guard). With HBC=<path to a real hbc> the real compiler's idlesleep
rejection is classified end to end.
"""
import importlib.util, os, subprocess, tempfile, unittest

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('run_macho_arm64', os.path.join(HERE, 'run_macho_arm64.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
ROW = next(iter(m.EXPECTED_REJ))


def run_fake(script):
    d = tempfile.mkdtemp()
    p = os.path.join(d, 'hbc')
    with open(p, 'w') as fh:
        fh.write(script)
    os.chmod(p, 0o755)
    c = subprocess.run([p, 'x.prg', 'x', '--target=macho-arm64'], capture_output=True)
    return c.returncode, c.stderr.decode('latin-1')


class ClassifyCompileFailureTests(unittest.TestCase):
    def test_exact_rejection_is_rej(self):
        rc, err = run_fake("#!/bin/sh\necho 'error: line 2: `hb_idleSleep` is not implemented by the Mach-O ARM64 backend in this increment (no nanosleep lowering; registered limit, no silent no-op)' >&2\nexit 1\n")
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
        stale = sorted(m.EXPECTED_REJ.keys() - {r[1] for r in res if r[0] == 'REJ'})
        self.assertIn(ROW, stale)  # main() fails the battery on a stale named REJ


@unittest.skipUnless(os.environ.get('HBC'), 'set HBC to a real hbc to classify its actual rejection')
class RealCompilerTest(unittest.TestCase):
    def test_real_idlesleep_rejection(self):
        d = tempfile.mkdtemp()
        prg = os.path.join(d, 'idl.prg')
        with open(prg, 'w') as fh:
            fh.write('function main()\n   hb_idleSleep(0.1)\nreturn nil\n')
        c = subprocess.run([os.environ['HBC'], prg, os.path.join(d, 'idl'), '--target=macho-arm64'],
                           capture_output=True)
        self.assertEqual(c.returncode, 1)
        kind, _ = m.classify_compile_failure(ROW, c.returncode, c.stderr.decode('latin-1'))
        self.assertEqual(kind, 'REJ')


if __name__ == '__main__':
    unittest.main()

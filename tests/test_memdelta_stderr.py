"""Intentional stderr is an exact program prefix, never arbitrary noise."""
from pathlib import Path
import importlib.util,unittest
p=Path(__file__).parent/'trycatch-linux/memdelta_guard.py'
spec=importlib.util.spec_from_file_location('memdelta_stderr',p)
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)

class StderrContract(unittest.TestCase):
    def check(self,rc,stderr,delta,state,expected=b'program\x00err\n',stdout=b'ok'):
        row=m.classify_memdelta(rc,stderr,stdout,b'ok',expected_stderr=expected)
        self.assertEqual((row['delta'],row['state_ok']),(delta,state))
    def test_exact_zero(self):self.check(0,b'program\x00err\n',0,True)
    def test_exact_nonzero(self):self.check(99,b'program\x00err\nDELTA=2\n',2,True)
    def test_missing_program_stderr(self):self.check(0,b'',None,False)
    def test_mismatched_prefix(self):self.check(99,b'wrong\nDELTA=2\n',None,False)
    def test_extra_after_program_stderr(self):self.check(0,b'program\x00err\nx',None,False)
    def test_extra_before_marker(self):self.check(99,b'program\x00err\nxDELTA=2\n',None,False)
    def test_extra_after_marker(self):self.check(99,b'program\x00err\nDELTA=2\nx',None,False)
    def test_wrong_status(self):self.check(1,b'program\x00err\n',None,False)
    def test_zero_status_with_marker(self):self.check(0,b'program\x00err\nDELTA=2\n',None,False)
    def test_wrong_stdout(self):self.check(0,b'program\x00err\n',None,False,stdout=b'wrong')
    def test_marker_in_program_stderr_stays_program_data(self):self.check(0,b'DELTA=2\n',0,True,expected=b'DELTA=2\n')
    def test_marker_program_data_does_not_hide_runtime_failure(self):self.check(99,b'DELTA=2\n',None,False,expected=b'DELTA=2\n')
    def test_empty_default_remains_strict(self):
        self.assertFalse(m.classify_memdelta(0,b'program\x00err\n',b'ok',b'ok')['state_ok'])

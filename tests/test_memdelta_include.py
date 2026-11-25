"""The shared strict guard forwards includes without changing its old call."""
from pathlib import Path
import importlib.util,tempfile,unittest
from types import SimpleNamespace
from unittest.mock import patch
p=Path(__file__).parent/'trycatch-linux/memdelta_guard.py'
spec=importlib.util.spec_from_file_location('memdelta_guard_include',p)
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)

class IncludeContract(unittest.TestCase):
    def exercise(self,include_dirs):
        calls=[]
        with tempfile.TemporaryDirectory() as td:
            w=Path(td)
            def run(cmd,**kwargs):
                calls.append(cmd)
                if len(calls)==1:
                    (w/'checked.s').write_text('    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n')
                return SimpleNamespace(returncode=0,stdout=b'\nok' if len(calls)==4 else b'',stderr=b'')
            with patch.object(m.subprocess,'run',side_effect=run):
                result=m.emit_delta('/compiler',{},w/'input.prg',w,b'\nok',**include_dirs)
            self.assertEqual(result['delta'],0)
            self.assertTrue(result['state_ok'])
            self.assertEqual(len(calls),4)
            self.assertEqual(calls[0][3:6],['--target=linux','--instrument','--no-prune'])
            return calls[0][6:]
    def test_original_call_has_no_extra_flags(self):
        self.assertEqual(self.exercise({}),[])
    def test_include_directories_are_distinct_arguments(self):
        self.assertEqual(self.exercise({'include_dirs':[Path('/a directory'),'/other']}),['-I','/a directory','-I','/other'])

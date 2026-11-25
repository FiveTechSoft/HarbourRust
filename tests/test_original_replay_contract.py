"""Mandatory wrapper rejects missing, duplicate, and misclassified results."""
from pathlib import Path
import importlib.util,tempfile,unittest,hashlib,copy
p=Path(__file__).parent/'original-current-replay/result_contract.py'
spec=importlib.util.spec_from_file_location('original_result_contract',p)
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)

class ResultContract(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name);(self.root/'tests').mkdir()
        (self.root/'tests/example.prg').write_text('return nil\n')
        self.digest=hashlib.sha256((self.root/'tests/example.prg').read_bytes()).hexdigest()
        self.rows=[dict(name='example',kind='exact-Harbour',mode=k)for k in m.MODES]
        self.rows.append(dict(name='example',kind='strict-final-balance',source_sha256=self.digest,delta=0,state_ok=True,stdout_match=True,rc=0,stderr=''))
    def check_bad(self,rows):
        with self.assertRaises(AssertionError):m.validate(rows,self.root)
    def test_complete(self):
        self.assertEqual(m.validate(self.rows,self.root),dict(sources=1,exact=5,strict_zero=1,known_debt=0,names=['example']))
    def test_missing_mode(self):self.check_bad(self.rows[1:])
    def test_duplicate_mode(self):self.check_bad(self.rows+[self.rows[0]])
    def test_missing_balance(self):self.check_bad(self.rows[:-1])
    def test_duplicate_balance(self):self.check_bad(self.rows+[self.rows[-1]])
    def test_unknown_kind(self):
        rows=copy.deepcopy(self.rows);rows[0]['kind']='unknown';self.check_bad(rows)
    def test_nonzero_is_not_zero(self):
        rows=copy.deepcopy(self.rows);rows[-1]['delta']=2;self.check_bad(rows)
    def test_missing_source_hash(self):
        rows=copy.deepcopy(self.rows);del rows[-1]['source_sha256'];self.check_bad(rows)
    def test_source_mismatch(self):
        rows=copy.deepcopy(self.rows);rows[-1]['source_sha256']='wrong';self.check_bad(rows)
    def test_missing_state(self):
        rows=copy.deepcopy(self.rows);rows[-1]['state_ok']=False;self.check_bad(rows)

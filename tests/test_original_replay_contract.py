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
    def source_rows(self,name):
        (self.root/'tests'/(name+'.prg')).write_text('return nil\n')
        rows=copy.deepcopy(self.rows)
        for row in rows:row['name']=name
        return rows
    def test_both_known_debts_are_valid(self):
        for name in ['inhprob','classch']:
            with self.subTest(name=name):
                rows=self.source_rows(name);rows[-1].update(kind='known-nonzero-balance',delta=2,expected_delta=2,rc=99,stderr='DELTA=2\n')
                self.assertEqual(m.validate(rows,self.root)['known_debt'],1)
    def test_known_debt_cannot_be_reported_as_zero(self):
        for name in ['inhprob','classch']:
            with self.subTest(name=name):self.check_bad(self.source_rows(name))
    def test_debt_record_requires_exact_state(self):
        for field,value in [('delta',0),('expected_delta',3),('rc',0),('stderr','DELTA=2'),('state_ok',False),('stdout_match',False),('kind','strict-final-balance')]:
            with self.subTest(field=field):
                rows=self.source_rows('inhprob');rows[-1].update(kind='known-nonzero-balance',delta=2,expected_delta=2,rc=99,stderr='DELTA=2\n');rows[-1][field]=value;self.check_bad(rows)
    def test_unknown_source_cannot_be_known_debt(self):
        rows=copy.deepcopy(self.rows);rows[-1].update(kind='known-nonzero-balance',delta=2,expected_delta=2,rc=99,stderr='DELTA=2\n');self.check_bad(rows)
    def legacy_rows(self,name,kind,rc):
        rows=self.source_rows(name);rows[-1]=dict(name=name,kind=kind,source_sha256=self.digest,delta=0,rc=rc,marker='DELTA=0');return rows
    def test_all_legacy_sources_require_their_exact_gate_shape(self):
        for gate,(names,kind,rc)in m.LEGACY.items():
            for name in names:
                with self.subTest(gate=gate,name=name):
                    rows=self.legacy_rows(name,kind,rc)
                    self.assertEqual(m.validate(rows,self.root,gate=gate)['strict_zero'],1)
                    for bad_gate in [None,'other']:
                        with self.assertRaises(AssertionError):m.validate(rows,self.root,gate=bad_gate)
                    for field,value in [('rc',99 if rc==0 else 0),('marker','DELTA=1'),('kind','strict-final-balance' if kind.endswith('effects')else 'strict-final-balance-and-effects')]:
                        bad=copy.deepcopy(rows);bad[-1][field]=value
                        with self.assertRaises(AssertionError):m.validate(bad,self.root,gate=gate)
    def test_legacy_gate_cannot_accept_other_source(self):
        rows=self.legacy_rows('example','strict-final-balance',99)
        with self.assertRaises(AssertionError):m.validate(rows,self.root,gate='original-input-control')

"""Own MIT fail-closed accounting for mandatory intact-original subgates."""
from collections import Counter
from pathlib import Path
import hashlib

MODES = {'native','external','flat','noescape','noprune'}
EXACT = {'exact-Harbour','original-exact-Harbour','original-exact-output-and-effects'}
ZERO = {'strict-final-balance','strict-final-balance-and-effects'}
DEBTS = {'inhprob':2,'classch':2}

def validate(rows,spec_root):
    names={}
    for row in rows:
        name=Path(row['name']).stem
        kind=row['kind']
        assert kind in EXACT|ZERO|{'known-nonzero-balance'},(name,kind)
        record=names.setdefault(name,dict(modes=[],balance=[]))
        source=Path(spec_root)/'tests'/(name+'.prg')
        digest=hashlib.sha256(source.read_bytes()).hexdigest()
        if 'source_sha256' in row:assert row['source_sha256']==digest,(name,'source hash')
        if kind in EXACT:
            record['modes'].append(row['mode'])
        else:
            assert row.get('source_sha256')==digest,(name,'balance source hash')
            expected=DEBTS.get(name,0)
            assert row['delta']==expected,(name,'delta')
            if expected:
                assert kind=='known-nonzero-balance' and row['expected_delta']==expected,(name,'debt class')
                assert row['state_ok'] and row['stdout_match'] and row['rc']==99,(name,'debt state')
                assert row['stderr']==f'DELTA={expected}\n',(name,'debt marker')
            else:
                assert kind in ZERO,(name,'zero class')
                if 'state_ok' in row:
                    assert row['state_ok'] and row['stdout_match'] and row['rc']==0 and row['stderr']=='',(name,'strict zero state')
                else:
                    # Existing input/effects gates have their own exact-stdout
                    # control and explicit DELTA=0 marker, not shared guard.
                    assert row['marker']=='DELTA=0' and row['rc'] in [0,99],(name,'legacy zero marker')
            record['balance'].append(expected)
    for name,record in names.items():
        assert Counter(record['modes'])==Counter(MODES),(name,'missing/duplicate mode')
        assert len(record['balance'])==1,(name,'missing/duplicate balance')
    return dict(sources=len(names),exact=sum(len(v['modes'])for v in names.values()),
                strict_zero=sum(v['balance']==[0]for v in names.values()),
                known_debt=sum(v['balance']!=[0]for v in names.values()),names=sorted(names))

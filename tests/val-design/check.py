#!/usr/bin/env python3
"""Build fresh Harbour oracle and compare an abstract literal-parser model.

No compiler change, folding/codegen or I64 ABI modification. This gate does
NOT make Val usable. A model success does not authorize lowering its result.
"""
import argparse,hashlib,json,random,subprocess
from pathlib import Path
from literal_model import parse_literal, lower_literal
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--hbmk2',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.hbmk2=a.hbmk2.resolve();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
root=Path(__file__).resolve().parent
cases=[b'',b' ',b'   ',b'0',b'1',b'01',b'+1',b'-1',b'-0',b' 1',b'1 ',b'         1',b'1.20',b' 1.20',b'1.2xyz',b'abc.def',b'1e3',b'0x10',b'.',b'+.5',b'-.5',b'12abc',b'12.3.4',b'9007199254740993',b'9223372036854775807',b'9223372036854775808',b'-9223372036854775808',b'999999999999999999999',b'0.00000000000000001',b'\t12',b'\r\n-2.50  ',b'\v12',b'\f12',b'12\x0034',b'1\xff.23',b'\xff12',b'0000000000000000000001',b'1.',b'-0.0',b'-.0']
r=random.Random(694428)
for _ in range(240):
    cases.append((''.join(r.choice('  +-0123456789.abceX') for _ in range(r.randrange(0,18)))).encode())
# Keep decimal metadata in the explicitly bounded model's admitted range.
cases=[x for x in cases if len(x)<=17 or x in cases[:40]]
def expr(data):
    return '"'+data.decode()+'"' if all(32<=c<127 and c!=34 for c in data) else '+'.join('Chr('+str(c)+')' for c in data) if data else '""'
lines=['procedure Main()','local cases:={'+','.join(expr(s) for s in cases)+'}','local s,v','for each s in cases','v:=Val(s)','OutStd(hb_jsonEncode(NumMeta(v)),Chr(10))','next','return']
src=a.output/'literal-cases.prg';src.write_text('\n'.join(lines)+'\n')
exe=a.output/'literal-oracle'
q=subprocess.run([str(a.hbmk2),str(src),str(root/'meta.c'),'-quiet','-gtstd','-o'+str(exe)],capture_output=True,timeout=60)
(a.output/'build.log').write_bytes(q.stdout+q.stderr);assert q.returncode==0,q.stderr
q=subprocess.run([str(exe)],capture_output=True,timeout=30);exe.unlink();assert(q.returncode,q.stderr)==(0,b''),q.stderr
(a.output/'oracle.jsonl').write_bytes(q.stdout)
expected=[json.loads(x) for x in q.stdout.splitlines() if x.strip()];assert len(expected)==len(cases)
rows=[]
for s,want in zip(cases,expected):
    got=parse_literal(s);assert got==want,(s,got,want)
    try:lower_literal(s)
    except ValueError as e:assert 'Val lowering is parked' in str(e)
    else:raise AssertionError('abstract tuple incorrectly admitted to codegen')
    rows.append(dict(input_hex=s.hex(),metadata=got,exact=True,lowering_rejected=True))
# Explicit test-only parser boundaries, never compiler admission claims.
for value in [None,1,'1',b'1'*4097,b'0.'+b'1'*18,b'1.'+b'0'*18]:
    try:parse_literal(value)
    except ValueError:pass
    else:raise AssertionError(('missing model rejection',str(value)[:80]))
# Separate observational program checks default formatting and consumers.
exe=a.output/'consumer-oracle'
q=subprocess.run([str(a.hbmk2),str(root/'observe.prg'),str(root/'meta.c'),'-quiet','-gtstd','-o'+str(exe)],capture_output=True,timeout=60)
(a.output/'consumer-build.log').write_bytes(q.stdout+q.stderr);assert q.returncode==0,q.stderr
q=subprocess.run([str(exe)],capture_output=True,timeout=30);exe.unlink();assert(q.returncode,q.stderr)==(0,b''),q.stderr
(a.output/'consumers.jsonl').write_bytes(q.stdout)
summary=dict(parser_cases=len(rows),parser_rows=rows,model_rejections=6,lowering_rejections=len(rows),
             consumers=len(q.stdout.splitlines()),codegen=False,compiler_changed=False,
             limits='Val not usable; abstract metadata only; byte length<=4096, decimal metadata<=17, finite F64',
             model_sha256=hashlib.sha256((root/'literal_model.py').read_bytes()).hexdigest())
(a.output/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print('PASS',len(rows),'abstract parser tuples;',len(q.stdout.splitlines()),'consumer observations;6 model rejections. NO compiler admission.')

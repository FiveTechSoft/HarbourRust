"""Compare BASE and candidate compilation across the complete manifest.
Exact assembly bytes or exact error bytes/status; only t828 diagnostic change
is allowed. Does not turn missing fixtures or runtime failures into passes.
"""
import argparse
import base64
import concurrent.futures
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

p = argparse.ArgumentParser()
for arg in ['baseline', 'compiler', 'root', 'output']:
    p.add_argument('--' + arg, required=True)
p.add_argument('--jobs', type=int, default=8)
p.add_argument('--manifest',default='tests/manifest.txt')
a = p.parse_args()
root = Path(a.root).resolve()
out = Path(a.output).resolve()
out.mkdir(parents=True, exist_ok=False)
compilers = [str(Path(a.baseline).resolve()), str(Path(a.compiler).resolve())]
lines = [(i, x) for i,x in enumerate((root/a.manifest).read_text().splitlines()) if x and not x.startswith('#')]


def one(item):
    target, index, line = item
    kind, source, *_ = line.split(' ',2)
    row = dict(target=target,index=index,source=source,kind=kind)
    with tempfile.TemporaryDirectory(dir=out) as tmp:
        path = Path(tmp) / 'output.s'
        data = []
        for comp in compilers:
            path.unlink(missing_ok=True)
            cmd = [comp, source, str(path), '--target='+target, '--instrument'] + ([] if kind == 'neg' else ['-I','tests'])
            q = subprocess.run(cmd,cwd=root,capture_output=True,timeout=30)
            asm = path.read_bytes() if path.exists() else None
            data.append((q.returncode,q.stderr,asm))
        row['base_rc'], row['candidate_rc'] = data[0][0],data[1][0]
        row['exact'] = data[0] == data[1]
        row['expected_diagnostic_change'] = source == 'tests/t828_macro_named_rejection_neg.prg' and all(x[0]!=0 and x[2] is None for x in data) and b'macro M1 capacity limit' in data[1][1]
        row['pass'] = row['exact'] or row['expected_diagnostic_change']
        for label, values in zip(['base','candidate'], data):
            row[label+'_stderr_b64']=base64.b64encode(values[1]).decode()
            row[label+'_assembly_sha256']=hashlib.sha256(values[2]).hexdigest() if values[2] is not None else None
    return row


rows=[]
with (out/'results.jsonl').open('w') as log:
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        for row in pool.map(one,[(t,i,x) for t in ['linux','windows'] for i,x in lines]):
            rows.append(row);log.write(json.dumps(row)+'\n');log.flush()
summary={t:dict(total=sum(x['target']==t for x in rows),exact=sum(x['target']==t and x['exact'] for x in rows),expected_diagnostic_changes=sum(x['target']==t and x['expected_diagnostic_change'] for x in rows),unexpected=[x for x in rows if x['target']==t and not x['pass']]) for t in ['linux','windows']}
(out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
assert all(x['pass'] for x in rows)

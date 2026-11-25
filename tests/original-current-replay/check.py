#!/usr/bin/env python3
"""Own MIT mandatory current-compiler replay of five intact-original gates."""
from pathlib import Path
import argparse,subprocess,json,hashlib,sys
from result_contract import validate
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','spec-root','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[];cc=str(Path(a.compiler).resolve())
for name in ['original-array-control','original-scalar-control','original-calls-control','original-input-control','original-filesystem-control','original-loop-byref-control','original-console-extra','original-encoding-date-control','original-current-date-control','original-fib-calendar-control','original-os-datetime-control']:
 d=out/name;cmd=[sys.executable,str(root/'tests'/name/'check.py'),'--compiler',cc,'--hbmk2',str(Path(a.hbmk2).resolve()),'--spec-root',str(Path(a.spec_root).resolve()),'--output',str(d)];z=subprocess.run(cmd,cwd=root,capture_output=True,timeout=120,stdin=subprocess.DEVNULL)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(out/(name+'.'+k)).write_bytes(b)
 (out/(name+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(root)),indent=2)+'\n');assert z.returncode==0,(name,z.stdout,z.stderr);j=json.loads((d/'results.json').read_text());assert j['compiler_sha256']==hashlib.sha256(Path(cc).read_bytes()).hexdigest();counts=validate(j['rows'],a.spec_root,gate=name);debt=[x for x in j['rows'] if x.get('kind')=='known-nonzero-balance'];clean=len(j['rows'])-len(debt);rows.append(dict(name=name,counts=counts,exact_or_zero=clean,known_debts=debt,compiler_sha256=j['compiler_sha256']));print(name,'exact/balance',clean,'known debts',len(debt),flush=True)
all_names=[n for row in rows for n in row['counts']['names']];assert len(all_names)==len(set(all_names)), 'duplicate source across subgates'
counts={k:sum(row['counts'][k]for row in rows)for k in ['sources','exact','strict_zero','known_debt']}
assert counts==dict(sources=55,exact=275,strict_zero=53,known_debt=2),counts
(out/'results.json').write_text(json.dumps(dict(counts=counts,compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),hbmk2_sha256=hashlib.sha256(Path(a.hbmk2).read_bytes()).hexdigest(),oracle_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=a.spec_root,text=True).strip(),rows=rows),indent=2)+'\n');print('PASS exact/balance',sum(x['exact_or_zero']for x in rows),'known debts',sum(len(x['known_debts'])for x in rows))

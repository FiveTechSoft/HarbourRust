#!/usr/bin/env python3
"""Verify the distinct Linux and PE INIT STATIC negative contracts."""
import argparse,hashlib,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();R=Path(__file__).resolve().parents[2];D=Path(a.output).resolve();D.mkdir(parents=True,exist_ok=False);rows=[]
cases=[('pe-logical-retag','tests/t1613_startup_neg_static.prg','windows','INIT STATIC platform guard'),('linux-value-return','tests/ci/fixtures/init-value-return-linux.prg','linux','INIT procedures require bare/NIL returns'),('linux-logical','tests/t1613_startup_neg_static.prg','linux','type mismatch in assignment'),('pe-integer','tests/ci/fixtures/init-static-windows.prg','windows','INIT procedures require bare/NIL returns')]
for name,source,target,needle in cases:
 w=D/name;w.mkdir();cmd=[str(Path(a.compiler).resolve()),source,str(w/'out.s'),'--target='+target,'--instrument','-I','tests'];z=subprocess.run(cmd,cwd=R,capture_output=True,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/k).write_bytes(b)
 (w/'command.json').write_text(json.dumps(dict(argv=cmd,cwd=str(R))));ok=z.returncode==1 and z.stderr.startswith(b'error:') and needle.encode()in z.stderr;rows.append(dict(name=name,source=source,source_sha256=hashlib.sha256((R/source).read_bytes()).hexdigest(),rc=z.returncode,ok=ok));assert ok,(name,z.returncode,z.stderr)
(D/'result.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),rows=rows),indent=2));print('PASS Linux logical guard and separate Linux/PE integer value-return contracts')

from pathlib import Path
import subprocess,sys,json,hashlib,os
import argparse
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(exist_ok=False);rows=[]
for fault in ['program-build-reject','program-build-timeout','program-run-timeout','same-runtime-output']:
 w=out/fault;w.mkdir();wrapper=w/'rustc-proxy';compiler='''#!/usr/bin/env python3
from pathlib import Path
import sys,shutil
fault=FAULT
if fault=='program-build-reject':sys.exit(1)
if fault=='program-build-timeout':sys.exit(124)
p=Path(sys.argv[2])
if fault=='same-runtime-output':shutil.copyfile(p.with_name('control'),p)
else:p.write_text('#!/usr/bin/env python3\\nimport sys\\nsys.exit(124)\\n')
p.chmod(0o755)
'''.replace('FAULT',repr(fault))
 wrapper.write_text('#!/usr/bin/env python3\nfrom pathlib import Path\nimport sys\np=Path(sys.argv[sys.argv.index("-o")+1])\np.write_text('+repr(compiler)+')\np.chmod(0o755)\n');wrapper.chmod(0o755)
 cmd=['python3','tests/mixed-return/mutants.py','--compiler',a.compiler,'--rustc',str(wrapper),'--hbmk2',a.hbmk2,'--output',str(w/'capture')]
 q=subprocess.run(cmd,cwd=repo,capture_output=True,env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']),timeout=40)
 for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/('gate.'+e)).write_bytes(b)
 j=json.load(open(w/'capture/results.json'));assert len(j['rows'])==3 and all(not x['caught'] for x in j['rows']);assert q.returncode==1
 rows.append(dict(fault=fault,gate_rc=q.returncode,mutant_rows=len(j['rows']),caught=[x['caught'] for x in j['rows']],ok=True));print(rows[-1])
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),gate_sha256=hashlib.sha256((repo/'tests/mixed-return/mutants.py').read_bytes()).hexdigest(),scope='Four explicit proxy simulations prove gate fails closed. Fake rustc output is not a Rust-valid mutant and never counts toward three product mutants.',rows=rows),indent=2))

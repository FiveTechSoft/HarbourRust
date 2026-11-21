#!/usr/bin/env python3
"""Proxy failures are gate self-tests, never product mutants."""
from pathlib import Path
import argparse,hashlib,json,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--baseline',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
for fault in ['build-reject','missing-output','run124','wrong-stdout']:
 w=out/fault;w.mkdir();p=w/'proxy';p.write_text('#!/usr/bin/env python3\nfrom pathlib import Path\nimport sys\nfault='+repr(fault)+'\nif fault=="build-reject":sys.exit(1)\nif fault=="missing-output":sys.exit(0)\np=Path(sys.argv[2]);p.write_text("#!/usr/bin/env python3\\nimport sys\\nsys.exit(124)\\n" if fault=="run124" else "#!/usr/bin/env python3\\nprint(9,7)\\n");p.chmod(0o755)\n');p.chmod(0o755)
 q=subprocess.run(['python3',str(Path(__file__).with_name('check.py')),'--compiler',p,'--hbmk2',a.hbmk2,'--baseline',a.baseline,'--output',w/'capture'],capture_output=True,timeout=30)
 for k,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/k).write_bytes(b)
 rows.append(dict(fault=fault,gate_rc=q.returncode,caught=q.returncode!=0));assert q.returncode!=0
h=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),runner_sha256=h(__file__),scope='Four simulation proxies of gate failure handling, not functional compiler mutants.',rows=rows),indent=2));print('PASS',len(rows))

from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser()
for n in ['compiler','baseline','output']:p.add_argument('--'+n,type=Path,required=True)
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);rows=[]
for fault in ['build-reject','missing-output','run124','wrong-stdout']:
 w=a.output/fault;w.mkdir();proxy=w/'proxy';proxy.write_text('#!/usr/bin/env python3\nfrom pathlib import Path\nimport sys\nfault='+repr(fault)+'\nif fault=="build-reject":sys.exit(1)\nif fault=="missing-output":sys.exit(0)\np=Path(sys.argv[2]);p.write_text("#!/usr/bin/env python3\\nimport sys\\nsys.exit(124)\\n" if fault=="run124" else "#!/usr/bin/env python3\\nprint(113,7)\\n");p.chmod(0o755)\n');proxy.chmod(0o755)
 q=subprocess.run(['python3',str(Path(__file__).with_name('check.py')),'--compiler',str(proxy),'--baseline',str(a.baseline),'--output',str(w/'capture')],capture_output=True,timeout=30)
 for ext,data in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(ext)).write_bytes(data)
 assert q.returncode!=0 and not(w/'capture/results.json').exists();rows.append(dict(fault=fault,gate_rc=q.returncode,caught=True))
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
(a.output/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),runner_sha256=h(Path(__file__)),scope='4simulationproxies only,notfunctionalproductmutants',rows=rows),indent=2));print('PASS4')

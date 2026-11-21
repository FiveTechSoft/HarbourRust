from common import *
a=setup(True);rows=[];gate=Path(__file__).with_name('check.py')
for fault in ['build-reject','build-success-no-file','run-124','wrong-stdout']:
 w=a.output/fault;w.mkdir();proxy=w/'compiler-proxy';code='#!/usr/bin/env python3\nfrom pathlib import Path\nimport sys\nfault='+repr(fault)+'\nif fault=="build-reject":sys.exit(1)\nif fault=="build-success-no-file":sys.exit(0)\np=Path(sys.argv[2])\np.write_text("#!/usr/bin/env python3\\nimport sys\\nsys.exit(124)\\n" if fault=="run-124" else "#!/usr/bin/env python3\\nprint(99999)\\n")\np.chmod(0o755)\n';proxy.write_text(code);proxy.chmod(0o755)
 q=run(['python3',gate,'--compiler',proxy,'--baseline',a.baseline,'--hbmk2',a.hbmk2,'--output',w/'capture'],w,'gate');assert q.returncode!=0 and not(w/'capture/results.json').exists(),(fault,q);rows.append(dict(fault=fault,gate_rc=q.returncode,ok=True));print(fault,'fail-closed',flush=True)
finish(a,rows,'4explicit proxy simulations,not Rust/product mutants: gate must reject build1,missing output,simulated run124,wrong stdout. None counted as product correctness evidence.')

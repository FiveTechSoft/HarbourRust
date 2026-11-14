from pathlib import Path
import subprocess,random,importlib.util,json
r=Path(__file__).resolve().parent;rng=random.Random(34364)
vs=[0,1,-1,9223372036854775807,-9223372036854775808]
for n in range(1,19):
 for off in [-1,0,1]:vs.extend([10**n+off,-10**n+off])
vs.extend(rng.randrange(-2**63,2**63)for _ in range(150));vs=[v for v in vs if -2**63<=v<2**63]
p=r/'integer-oracle.prg';p.write_text('FUNCTION Main()\n'+'\n'.join('? '+str(v).replace('-9223372036854775808','(-9223372036854775807-1)')for v in vs)+'\nRETURN\n')
a=subprocess.run([str(r/'hbc-baseline'),str(p),str(r/'integer-oracle')],capture_output=True);assert a.returncode==0,a.stderr
(r/'integer-oracle').chmod(0o755)
a=subprocess.run([str(r/'integer-oracle')],capture_output=True);assert a.returncode==0 and a.stderr==b''
s=importlib.util.spec_from_file_location('emu',r/'test-emulator.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
got=bytes.fromhex(m.execute(r/'runtime-probe')['stdout_hex'])
assert a.stdout==b'\n'+got[:-len(b'\n.F..T.')]
p=r/'runtime-emulator-results.json';d=json.loads(p.read_text());d['linux_baseline_integer_outputs_exact']=len(vs);p.write_text(json.dumps(d,indent=2)+'\n')
print(len(vs),'runtime integer formats exact against untouched Linux backend')

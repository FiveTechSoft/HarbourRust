from pathlib import Path
import subprocess,os,json,struct,hashlib
R=Path(__file__).resolve().parents[3];E=R/'evidence/pe-final-controls';E.mkdir(exist_ok=True)
# Host adaptation (2026-11-24): HB_M2_COMPILER overrides the recorded /tmp
# compiler; on a Windows host the PE products run directly (no Wine). The
# recorded Linux+Wine environment stays the default elsewhere.
cc=os.environ.get('HB_M2_COMPILER','/tmp/hr-m2-hbc');native=os.name=='nt'
env=os.environ.copy()
if not native:env.update(WINEPREFIX='/tmp/hr-m2-wine11-prefix',WINEDEBUG='-all');wine='/tmp/hr-wine11/opt/wine-stable/bin/wine'
def spawn(exe):
 if native:return subprocess.run([str(exe)],capture_output=True,timeout=45)
 return subprocess.run([wine,str(exe.resolve())],env=env,capture_output=True,timeout=45)
rows=[]
for name in ['arity64','arity65','literal65','round15','roundminus15','round16','roundminus16','unknown']:
 src=R/'evidence/limits'/name/'case.prg';d=E/name;d.mkdir(exist_ok=True);exe=d/'product.exe';q=subprocess.run([cc,str(src),str(exe),'--target=windows','--instrument'],capture_output=True);assert not q.returncode,q.stderr;p=spawn(exe)
 for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode()+b'\n')]: (d/('run.'+k)).write_bytes(v)
 expected=0 if name in ['arity64','round15','roundminus15'] else 1;ok=p.returncode==expected
 if expected:ok=ok and b'(M2)'in p.stderr
 else:ok=ok and p.stdout==(R/'evidence/limits'/name/'product.stdout').read_bytes()and not p.stderr
 rows.append(dict(name=name,raw_pass=ok,binary_sha256=hashlib.sha256(exe.read_bytes()).hexdigest()));exe.unlink();print(name,ok)
exe=E/'mixed.exe';subprocess.run([cc,str(R/'tests/macro/m2/mixed.prg'),str(exe),'--target=windows','--instrument'],check=True,capture_output=True);b=bytearray(exe.read_bytes());o=struct.unpack_from('<I',b,60)[0]+24;assert struct.unpack_from('<H',b,o+70)[0]==0x100;struct.pack_into('<Q',b,o+24,0x180000000);exe.write_bytes(b);p=spawn(exe)
for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode()+b'\n')]: (E/('changed-imagebase.'+k)).write_bytes(v)
rows.append(dict(name='changed-imagebase',raw_pass=p.returncode==0 and not p.stderr and p.stdout==(R/'evidence/positive/mixed/windows/product.stdout').read_bytes(),imagebase='0x180000000',scope='diagnostic header mutation, not output-format ASLR claim'));exe.unlink();(E/'results.json').write_text(json.dumps(rows,indent=2)+'\n');assert all(x['raw_pass']for x in rows)

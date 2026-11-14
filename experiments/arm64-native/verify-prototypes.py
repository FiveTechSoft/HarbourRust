"""Run isolated foundation checks. Not hbc tests or Mac hardware execution."""
from pathlib import Path
import argparse,subprocess,hashlib,struct,random,json,sys
p=argparse.ArgumentParser();p.add_argument('--rustc',default='rustc');a=p.parse_args()
r=Path(__file__).resolve().parent
for name in ['encoder-prototype','sha256-prototype','own-macho-prototype']:
 subprocess.run([a.rustc,'--edition=2021','-O','-C','strip=symbols',str(r/(name+'.rs')),'-o',str(r/name)],check=True)
subprocess.run([str(r/'encoder-prototype'),str(r/'own-instructions.bin')],check=True)
subprocess.run([sys.executable,str(r/'own_macho_prototype.py')],check=True)
subprocess.run([str(r/'own-macho-prototype'),str(r/'own-arm64-rust')],check=True)
assert (r/'own-arm64-rust').read_bytes()==(r/'own-arm64-macho').read_bytes()
subprocess.run([sys.executable,str(r/'check_reference.py'),str(r/'own-arm64-rust')],check=True)
subprocess.run([sys.executable,str(r/'signature-mutation-check.py')],check=True)
rng=random.Random(312643)
vectors=[b'',b'abc',b'a'*1000000]+[bytes(rng.randrange(256)for _ in range(n))for n in list(range(140))+[255,256,511,512,1023,1024,4095,4096,4097,16383,16384,16385]]
vectors.extend((b'HarbourRust ARM64 boundary '+bytes([i]))*(i*17+1)for i in range(13))
for name in ['own-arm64-macho']:
 if (r/name).exists():
  b=(r/name).read_bytes();vectors.extend(b[i:i+4096]for i in range(0,len(b),4096))
data=b''.join(struct.pack('<I',len(v))+v for v in vectors)
out=subprocess.run([str(r/'sha256-prototype')],input=data,capture_output=True,check=True).stdout
assert len(out)==len(vectors)*32
for i,v in enumerate(vectors):assert out[i*32:(i+1)*32]==hashlib.sha256(v).digest()
print('Own writer Python/Rust exact; signature hashes and mutations pass; SHA256 vectors:',len(vectors))
print('No hbc source admission, Mac execution or loader acceptance follows.')

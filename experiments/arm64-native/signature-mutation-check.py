from pathlib import Path
import subprocess,json
r=Path(__file__).resolve().parent
original=(r/'own-arm64-rust').read_bytes();tests=[]
# One bit flip in each of the nine signed pages must fail the hash check.
for page in range(9):
 b=bytearray(original);offset=page*4096+(2048 if page==0 else 7);b[offset]^=1
 p=r/'mutation';p.write_bytes(b)
 result=subprocess.run(['python3',str(r/'check_reference.py'),str(p)],capture_output=True)
 assert result.returncode!=0,page
 tests.append(dict(page=page,offset=offset,rejected=True))
(r/'signature-mutations.json').write_text(json.dumps(tests,indent=2)+'\n')
(r/'mutation').unlink();(r/'mutation-structure.json').unlink(missing_ok=True)
print('All nine signed-page bit flips rejected')

#!/usr/bin/env python3
"""Original MIT: own C core vs independent Python libraries and published vectors."""
from pathlib import Path
import argparse,ctypes,hashlib,hmac,json,random,subprocess
ap=argparse.ArgumentParser();ap.add_argument('--output',required=True);ap.add_argument('--cc',default='gcc');a=ap.parse_args();repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);source=repo/'runtime/hrsha1.c';binary=out/'core.so'
cmd=[a.cc,'-std=c99','-O2','-Wall','-Wextra','-Werror','-fsanitize=undefined','-fno-sanitize-recover=all','-shared','-fPIC',str(source),'-o',str(binary)];q=subprocess.run(cmd,capture_output=True);(out/'build.stdout').write_bytes(q.stdout);(out/'build.stderr').write_bytes(q.stderr);assert not q.returncode,q.stderr
lib=ctypes.CDLL(str(binary));lib.hbc_sha1_digest.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_void_p];lib.hbc_hmac_sha1_digest.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_void_p,ctypes.c_size_t,ctypes.c_void_p];lib.hbc_sha1_hex.argtypes=[ctypes.c_void_p,ctypes.c_void_p];rng=random.Random(1234);rows=[]
def check(m,k=None,want=None,name='independent'):
 raw=ctypes.create_string_buffer(20);hexbuf=ctypes.create_string_buffer(40)
 if k is None:lib.hbc_sha1_digest(m,len(m),raw);expected=hashlib.sha1(m).digest()
 else:lib.hbc_hmac_sha1_digest(m,len(m),k,len(k),raw);expected=hmac.digest(k,m,'sha1')
 assert raw.raw==expected,(name,len(m),len(k) if k else 0)
 lib.hbc_sha1_hex(raw,hexbuf);assert hexbuf.raw==expected.hex().encode()
 if want:assert hexbuf.raw.decode()==want
 rows.append(dict(name=name,bytes=len(m),key_bytes=len(k) if k is not None else None,raw_exact=True,hex_exact=True))
for n in list(range(150))+[255,256,511,512,513,1000,1000000]:
 m=bytes(rng.randrange(256) for _ in range(n));check(m)
 for kn in [0,1,20,63,64,65,100,1000]:check(m,bytes(rng.randrange(256) for _ in range(kn)))
check(b'abc',want='a9993e364706816aba3e25717850c26c9cd0d89d',name='published SHA-1 abc')
for i,(key,m,want) in enumerate([(bytes([11])*20,b'Hi There','b617318655057264e28bc0b6fb378c8ef146be00'),(b'Jefe',b'what do ya want for nothing?','effcdf6ae5eb2fa2d27416d5f184df9c259a7c79'),(bytes([170])*20,bytes([221])*50,'125d7342b9ac11cd91a39af48aa17b4f63f175d3')],1):check(m,key,want,'RFC2202 case '+str(i))
(out/'results.json').write_text(json.dumps(dict(source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),commands=[cmd],rows=rows),indent=2));print(len(rows),'core vectors raw and hex exact; UBSan active')

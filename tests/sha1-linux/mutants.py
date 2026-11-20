#!/usr/bin/env python3
"""Original MIT. Algorithm helper mutants, independent hashlib/hmac expected bytes."""
from pathlib import Path
import argparse,subprocess,ctypes,hashlib,hmac,json
ap=argparse.ArgumentParser();ap.add_argument('--output',required=True);a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);src=Path(__file__).resolve().parents[2]/'runtime/hrsha1.c';text=src.read_text();rows=[]
mutants={'candidate':None,'rotate-5-to-4':('turn(a,5)','turn(a,4)'),'padding-55':('s->fill<56?56-s->fill:120-s->fill','s->fill<55?55-s->fill:119-s->fill'),'length-bits':('s->bytes*8u','s->bytes*4u'),'key-boundary':('if(keyn>64)','if(keyn>=64)'),'ipad':('k[i]^0x36','k[i]^0x37'),'opad':('k[i]^0x5c','k[i]^0x5d')}
for name,edit in mutants.items():
 d=out/name;d.mkdir();source=d/'core.c';s=text
 if edit:assert edit[0] in s;s=s.replace(*edit)
 source.write_text(s);so=d/'core.so';cmd=['gcc','-std=c99','-O2','-Wall','-Wextra','-Werror','-shared','-fPIC',str(source),'-o',str(so)];b=subprocess.run(cmd,capture_output=True);(d/'build.stderr').write_bytes(b.stderr);assert b.returncode==0,b.stderr;lib=ctypes.CDLL(str(so));lib.hbc_sha1_digest.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_void_p];lib.hbc_hmac_sha1_digest.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_void_p,ctypes.c_size_t,ctypes.c_void_p];cases=[]
 for n in [0,1,55,56,63,64,65,1000]:
  msg=bytes((i*37+11)%256 for i in range(n));raw=ctypes.create_string_buffer(20);lib.hbc_sha1_digest(msg,len(msg),raw);cases.append(dict(bytes=n,key_bytes=None,exact=raw.raw==hashlib.sha1(msg).digest(),got_hex=raw.raw.hex(),expected_hex=hashlib.sha1(msg).hexdigest()))
  for kn in [0,20,63,64,65,1000]:
   key=bytes((i*17+3)%256 for i in range(kn));lib.hbc_hmac_sha1_digest(msg,len(msg),key,len(key),raw);expected=hmac.digest(key,msg,'sha1');cases.append(dict(bytes=n,key_bytes=kn,exact=raw.raw==expected,got_hex=raw.raw.hex(),expected_hex=expected.hex()))
 row=dict(name=name,build_rc=b.returncode,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),binary_sha256=hashlib.sha256(so.read_bytes()).hexdigest(),rows=cases);rows.append(row);print(name,sum(r['exact'] for r in cases),'/',len(cases));assert all(r['exact'] for r in cases) if name=='candidate' else any(not r['exact'] for r in cases)
(out/'results.json').write_text(json.dumps(dict(scope='Own algorithm C helper mutants built/run natively, not Rust compiler mutants. hashlib/hmac independent expected bytes.',source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),rows=rows),indent=2))

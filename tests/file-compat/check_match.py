#!/usr/bin/env python3
"""Extra Linux/C-locale differential gate for own wildcard matcher.
The Harbour byte-exact executable probes remain the primary gate.
"""
import ctypes,hashlib,json,pathlib,random,subprocess,tempfile
root=pathlib.Path(__file__).resolve().parents[2]
with tempfile.TemporaryDirectory(prefix='filematch-')as d:
 p=pathlib.Path(d);(p/'match.c').write_text('#include "'+str(root/'runtime/hrfile.c')+'"\nint test_match(const char*p,const char*s){return hrfile_match((const unsigned char*)p,(const unsigned char*)s);}\n')
 subprocess.run(['gcc','-shared','-O2','-fPIC',p/'match.c','-o',p/'match.so'],check=True)
 own=ctypes.CDLL(str(p/'match.so'));libc=ctypes.CDLL(None)
 names=[bytes([c])for c in range(1,256)if c!=47]+[b'',b'aa',b'ab',b'a*',b'foo.txt',b'.hidden']
 tokens=[b'a',b'b',b'!',b'[',b']',b'-',b'^',b'\\',b':',b'*',b'?',b'[[.a.]]',b'[[=b=]]',b'[[:lower:]]',b'[![:upper:]]',b'[[:bad:]]',b'[![:bad:]]',b'[[.bad.]]',b'[![[.bad.]]',b'[[:digit:]-z]',b'[a-[:digit:]]',b'[z-a]',b'[^z-a]',b'[a-b-c]']
 rng=random.Random(25);patterns=set(tokens);patterns.update(b''.join(rng.choice(tokens)for _ in range(rng.randrange(1,4)))for _ in range(30000));count=0
 for pattern in sorted(patterns):
  for name in names:
   count+=1;assert bool(own.test_match(pattern,name))==(libc.fnmatch(pattern,name,1)==0),(pattern,name)
 print(json.dumps({'pass':True,'comparisons':count,'patterns':len(patterns),'locale':'C libc default','runtime_sha256':hashlib.sha256((root/'runtime/hrfile.c').read_bytes()).hexdigest()}))

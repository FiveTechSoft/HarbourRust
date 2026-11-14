"""Independent high-precision derivation, no imported constant table."""
from decimal import Decimal, localcontext
from pathlib import Path
import re
primes=[];n=2
while len(primes)<64:
 if all(n%p for p in primes if p*p<=n):primes.append(n)
 n+=1
with localcontext()as c:
 c.prec=100
 iv=[int((Decimal(p).sqrt()%1)*(1<<32))for p in primes[:8]]
 constants=[int((((Decimal(p).ln()/3).exp())%1)*(1<<32))for p in primes]
s=(Path(__file__).resolve().parent/'sha256-prototype.rs').read_text()
k=re.search(r'const K:\s*\[u32;\s*64\]\s*=\s*\[(.*?)\];',s,re.S).group(1)
h=re.search(r'let mut h:\s*\[u32;\s*8\]\s*=\s*\[(.*?)\];',s,re.S).group(1)
assert [int(t,16)for t in re.findall(r'0x[0-9a-f]+',k)]==constants
assert [int(t,16)for t in re.findall(r'0x[0-9a-f]+',h)]==iv
print('SHA256 64 round constants and 8 initial words independently derived at 100-digit precision')

from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
cases=json.loads(Path(__file__).with_name('cases.json').read_text())
for name,text in cases.items():
 w=out/name;w.mkdir();src=w/'p.prg';canonical=text.replace('hb_BChar','Chr').replace('hb_BCode','Asc')
 for target in ['linux','windows','macho','macho-arm64']:
  result={}
  for label,cc,body in [('base',a.baseline,canonical),('candidate',a.compiler,text)]:
   src.write_text(body)
   for ext in ['s','bin']:
    dest=w/(label+'-'+target+'.'+ext);q=subprocess.run([cc,src,dest,'--target='+target],capture_output=True,env=env,timeout=30)
    for e,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(label+'-'+target+'-'+ext+'.'+e)).write_bytes(b)
    assert q.returncode in (0,1),(name,target,label,ext,q.stderr);result[label+'.'+ext+'.rc']=q.returncode;result[label+'.'+ext+'.stderr']=hashlib.sha256(q.stderr).hexdigest();result[label+'.'+ext]=h(dest) if q.returncode==0 else None
  exact=all(result['base.'+ext+suffix]==result['candidate.'+ext+suffix] for ext in ['s','bin'] for suffix in ['', '.rc','.stderr']);same=exact;pe_control=None
  if target=='windows' and result['base.bin.rc']==0 and result['candidate.bin.rc']==0:
   import struct
   aa=(w/('base-'+target+'.bin')).read_bytes();bb=(w/('candidate-'+target+'.bin')).read_bytes();off=struct.unpack_from('<I',aa,0x3c)[0];assert off==struct.unpack_from('<I',bb,0x3c)[0];changed=[i for i,(x,y) in enumerate(zip(aa,bb)) if x!=y];allowed=list(range(off+8,off+12))+list(range(off+88,off+92));assert len(aa)==len(bb) and all(i in allowed for i in changed)
   def canon_pe(data):
    d=bytearray(data);d[off+8:off+12]=bytes(4);d[off+88:off+92]=bytes(4);return hashlib.sha256(d).hexdigest()
   ca,cb=canon_pe(aa),canon_pe(bb);pe_control=dict(changed_offsets=changed,allowed_timestamp_offsets=list(range(off+8,off+12)),allowed_checksum_offsets=list(range(off+88,off+92)),base_canonical_sha256=ca,candidate_canonical_sha256=cb);same=result['base.s']==result['candidate.s'] and ca==cb
  rows.append(dict(name=name,target=target,source_sha256=hashlib.sha256(text.encode()).hexdigest(),canonical_source_sha256=hashlib.sha256(canonical.encode()).hexdigest(),hashes=result,raw_identical=exact,equivalent=same,pe_timestamp_checksum_control=pe_control));assert same,(name,target,result)
  for label in ['base','candidate']:
   p=w/(label+'-'+target+'.bin')
   if p.exists():p.unlink()
 src.write_text(text);print(name,'4targets checked, shared profile rejections retained',flush=True)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='23 own sources x4targets, shared profile rejections recorded separately,ASM exact and Linux/MachO binary exact identity; PE raw hashes and allowed timestamp/checksum-only control against base Chr/Asc canonical source compiled at same path. Source replaced only for controlled canonical comparison. No code bytes normalized. Not cross-target runtime oracle equality.',rows=rows),indent=2));assert len(rows)==92

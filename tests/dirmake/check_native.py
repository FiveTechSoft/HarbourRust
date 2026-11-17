#!/usr/bin/env python3
"""Native DIRMAKE execution gate. OS reference, not a Harbour oracle."""
import argparse,hashlib,json,os,pathlib,subprocess
P=pathlib.Path
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--target',choices=['linux','macho','macho-arm64'],required=True);p.add_argument('--tree',required=True);p.add_argument('--output',required=True);a=p.parse_args();compiler=str(P(a.compiler).resolve());out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[]
cases={
 'paths': [('"fresh"',b'fresh'),('"fresh"',b'fresh'),('"missing/leaf"',b'missing/leaf'),('""',b''),('"."',b'.'),('"plainfile/leaf"',b'plainfile/leaf'),('"parent/child"',b'parent/child'),('"nul"+Chr(0)+"tail"',b'nul\0tail'),('"nul"',b'nul')],
 'owned': [('Lower("FRESH")',b'fresh'),('Lower("FRESH")',b'fresh'),('Space(2)',b'  '),('"café"','café'.encode()),('"back\\slash"',b'back\\slash')],
 'scalar': [('NIL',None),('1.5',None),('.t.',None),('7',None),('',None)],
}
for name,items in cases.items():
 for mask in [0o022,0o077]:
  d=out/(name+'-'+oct(mask));d.mkdir();w=d/'work';w.mkdir();ref=d/'reference';ref.mkdir();expected=[]
  for root in [w,ref]:(root/'plainfile').touch();(root/'parent').mkdir()
  for expr,path in items:
   if path is None:expected.append(-2);continue
   path=path.split(b'\0')[0]
   if not path:expected.append(-2);continue
   prior=os.umask(mask)
   try:
    try:os.mkdir(os.fsencode(ref)+b'/'+path,0o777);expected.append(0)
    except OSError as e:expected.append(-e.errno)
   finally:os.umask(prior)
  src=d/'probe.prg';src.write_text('function main()\n? '+','.join('DIRMAKE('+expr+')'for expr,_ in items)+'\nreturn nil\n');exe=d/'program';r=subprocess.run([compiler,str(src),str(exe),'--target='+a.target,'--instrument'],capture_output=True)
  (d/'build.stdout').write_bytes(r.stdout);(d/'build.stderr').write_bytes(r.stderr);assert r.returncode==0,(name,r.stderr)
  prior=os.umask(mask)
  try:r=subprocess.run([str(exe)],cwd=w,capture_output=True,timeout=30)
  finally:os.umask(prior)
  for ext,data in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(d/('run.'+ext)).write_bytes(data)
  pin=b'\n'+b' '.join(f'{v:10d}'.encode()for v in expected);assert(r.returncode,r.stdout,r.stderr)==(0,pin,b''),(name,r.returncode,r.stdout,pin,r.stderr)
  def snapshot(root):return sorted([str(x.relative_to(root)),oct(x.stat().st_mode&0o777)]for x in root.rglob('*'))
  actual=snapshot(w);reference=snapshot(ref);assert actual==reference,(name,actual,reference)
  rows.append(dict(name=name,umask=oct(mask),expected=expected,filesystem=actual,passed=True))
report=dict(compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),compiler_tree=a.tree,target=a.target,scope='native execution against OS reference; NOT Harbour oracle',records=rows,count=len(rows));(out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print('PASS',len(rows),'native DIRMAKE OS-reference checks')

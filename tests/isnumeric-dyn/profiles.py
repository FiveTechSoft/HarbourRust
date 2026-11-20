from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();cc=Path(a.compiler);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for name,s in json.loads(Path(__file__).with_name('local-cases.json').read_text()).items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(s)
 for tg in ['linux','windows','macho','macho-arm64']:
  p=w/(tg+'.s');q=subprocess.run([cc,src,p,'--target='+tg],capture_output=True,env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']));row=dict(name=name,target=tg,build_rc=q.returncode,source_sha256=h(src),diagnostic=q.stderr.decode());(w/(tg+'.stderr')).write_bytes(q.stderr)
  if q.returncode==0:row['assembly_sha256']=h(p)
  rows.append(row)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='6direct-local sources x4targets assembly-only positive gate,not execution nor binary ABI validation.',rows=rows),indent=2));print('PASS',sum(x['build_rc']==0 for x in rows),'/',len(rows));assert len(rows)==24 and all(x['build_rc']==0 for x in rows)

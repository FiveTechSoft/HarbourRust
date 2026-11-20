from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();cc=Path(a.compiler);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for name,s in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=out/name;w.mkdir();src=w/'p.prg';src.write_text(s)
 for tg in ['linux','windows','macho','macho-arm64']:
  p=w/(tg+'.s');q=subprocess.run([cc,src,p,'--target='+tg],capture_output=True,env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']));row=dict(name=name,target=tg,ok=(q.returncode==1 and (b'Dyn bit index requires ordinary Linux' in q.stderr or (name=='dyn-parameter' and b'never returns a value' in q.stderr)) and b'panicked' not in q.stderr) if name.startswith('dyn-') and tg!='linux' else q.returncode==0,build_rc=q.returncode,source_sha256=h(src),diagnostic=q.stderr.decode());(w/(tg+'.stderr')).write_bytes(q.stderr)
  if q.returncode==0:row['assembly_sha256']=h(p)
  rows.append(row)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(cc),runner_sha256=h(Path(__file__)),scope='16I64 plus10Dyn sources x4targets,positive/rejection separated assembly-only positive gate,not execution nor binary ABI validation.',rows=rows),indent=2));print('PASS',sum(x['ok'] for x in rows),'/',len(rows));assert len(rows)==104 and all(x['ok'] for x in rows)

from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output);out.mkdir();repo=Path(__file__).resolve().parents[2];rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for target in ['linux','windows','macho','macho-arm64']:
 w=out/target;w.mkdir();src=repo/'tests/t1076_bitindex_values.prg';row=dict(target=target,source_sha256=h(src))
 for label,cc in [('base',a.baseline),('candidate',a.compiler)]:
  p=w/(label+'.s');q=subprocess.run([cc,src,p,'--target='+target],capture_output=True,env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']));row[label+'_build_rc']=q.returncode;(w/(label+'.stderr')).write_bytes(q.stderr);assert q.returncode==0;row[label+'_assembly_sha256']=h(p)
 row['exact']=(w/'base.s').read_bytes()==(w/'candidate.s').read_bytes();rows.append(row)
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=h(Path(a.compiler)),baseline_sha256=h(Path(a.baseline)),runner_sha256=h(Path(__file__)),scope='Existing t1076 literal0..63 emit identity4targets ASM only,same original source path,no normalization.',rows=rows),indent=2));print('PASS',sum(x['exact'] for x in rows),'/',len(rows));assert len(rows)==4 and all(x['exact'] for x in rows)

#!/usr/bin/env python3
"""PCOUNT B: direct Linux and Windows calls, exact outputs; on Linux also
the final alloc/free guard."""
import argparse,json,os,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2];here=Path(__file__).resolve().parent
cc=str(Path(a.compiler).resolve());out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
win=os.name=='nt';host='windows' if win else 'linux'
if not win:sys.path.insert(0,str(root/'tests/trycatch-linux'));from memdelta_guard import emit_delta
rows=[]
def run(cmd,label):
 r=subprocess.run(list(map(str,cmd)),cwd=root,capture_output=True,timeout=60)
 for ext,data in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(out/(label+'.'+ext)).write_bytes(data)
 return r
for name,want in [('basic',b'\n         0\n         0\n         1\n         1\n         2\n         2'),('recursive',b'\n       404\n       505'),('nested',b'\n         2'),('byref',b'\n         1\n         5'),('memory',b'\ndone'),('user_pcount',b'\n         7')]:
 src=here/(name+'.prg');exe=out/(name+('.exe' if win else ''))
 r=run([cc,src,exe,'--target='+host]+([] if win else ['--instrument']),name+'-build');assert r.returncode==0,r.stderr
 r=run([exe],name+'-run');got=r.stdout.replace(b'\r\n',b'\n');assert (r.returncode,got,r.stderr)==(0,want,b''),(name,r.returncode,r.stdout,r.stderr)
 if win:rows.append(dict(name=name,kind='execution'));continue
 d=out/(name+'-delta');d.mkdir();row=emit_delta(cc,os.environ,src,d,want);assert row['state_ok'] and row['delta']==0,(name,row)
 rows.append(dict(name=name,kind='execution-and-final-balance',**row))
for name,needle in [('method_limit',b'PCount in a method'),('block_limit',b'PCount inside a codeblock'),('extra_limit',b'takes 1 argument(s), got 2'),('thread_limit',b'PCount requires ordinary Linux'),('macro_limit',b'PCount requires ordinary Linux')]:
 r=run([cc,here/(name+'.prg'),out/name,'--target='+host],name);assert r.returncode==1 and needle in r.stderr,(name,r.stderr)
 rows.append(dict(name=name,kind='named-rejection',rc=r.returncode))
for target in ['macho','macho-arm64']:
 r=run([cc,here/'basic.prg',out/'rejected','--target='+target],'target-'+target);assert r.returncode==1 and b'PCount requires ordinary Linux' in r.stderr,(target,r.stderr)
 r=run([cc,here/'user_pcount.prg',out/('override-'+target+'.s'),'--target='+target],'override-'+target);assert r.returncode==0,r.stderr
 rows.append(dict(name=target,kind='profile-rejected-user-override-emitted'))
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS pcount (%s): 6 exact executions%s; 5 named limits; 2 profile rejections and user override emissions'%(host,'' if win else ' and final delta=0'))

#!/usr/bin/env python3
"""Original MIT. Controlled cold terminal route boundary testing."""
from pathlib import Path
import subprocess,re,hashlib,json,argparse
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
out=Path(a.output).resolve();out.mkdir(exist_ok=False);src=out/'p.prg';src.write_text('function Main()\n? ""\nreturn nil\n');cc=a.compiler;asm=out/'runtime.s';q=subprocess.run([cc,src,asm,'--target=linux','--instrument','--no-prune'],capture_output=True);assert not q.returncode,q.stderr;text=asm.read_text();parts=re.split(r'(?m)^(hbc_[A-Za-z0-9_]+):\n',text);blocks={parts[i]:parts[i+1] for i in range(1,len(parts),2)};routes=[k for k,v in blocks.items() if ('jmp hbc_panic_exit' in v or re.search(r'mov[lq]?\s+\$60,\s*%eax',v)) and k not in ['hbc_panic_exit','hbc_gtstd_close']];rows=[]
for name in routes:
 # Only no-argument diagnostic entry routes. seq_uncaught consumes the
 # initialized zero exception depth; overflow uses a fixed message.
 if name in ['hbc_seq_unwind']:continue
 d=out/name;d.mkdir();base=text.replace('    call hbc_persistent_cleanup\n','    jmp '+name+'\n    call hbc_persistent_cleanup\n',1);block=blocks[name];bad=block.replace('    call hbc_gtstd_before_fatal\n','');assert bad!=block,name;mut=base.replace(name+':\n'+block,name+':\n'+bad,1);expected=None
 for label,s in [('candidate',base),('no-early-close',mut)]:
  f=d/(label+'.s');f.write_text(s);b=subprocess.run(['as',f,'-o',d/(label+'.o')],capture_output=True);assert not b.returncode,b.stderr;b=subprocess.run(['ld',d/(label+'.o'),'-o',d/label],capture_output=True);assert not b.returncode,b.stderr
  try:r=subprocess.run([d/label],input=b'',stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=2)
  except subprocess.TimeoutExpired as e:r=subprocess.CompletedProcess([],124,e.stdout or b'')
  (d/(label+'.merged')).write_bytes(r.stdout);(d/(label+'.rc')).write_text(str(r.returncode));row=dict(route=name,variant=label,run_rc=r.returncode,binary_sha256=hashlib.sha256((d/label).read_bytes()).hexdigest(),asm_sha256=hashlib.sha256(f.read_bytes()).hexdigest());(d/label).unlink();(d/(label+'.o')).unlink()
  if label=='candidate':expected=(r.returncode,r.stdout);row['prefix_before_diagnostic']=r.stdout.startswith(b'\n');row['exit_one']=r.returncode==1
  else:row['mutant_caught']=(r.returncode,r.stdout)!=expected
  rows.append(row)
result=dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),scope='Cold no-argument terminal-entry injection into final unpruned emitted ASM after Main returns with pending empty QOut. This is boundary testing, not source-level reachability. Candidate must exit1 with LF before diagnostic, mutant removes route-local early closes but leaves panic/final safeguards. Late macro/StrDyn/DBF have separate real-source tests.',rows=rows);(out/'results.json').write_text(json.dumps(result,indent=2));bad=[r for r in rows if (r['variant']=='candidate' and (not r['prefix_before_diagnostic'] or not r['exit_one'])) or (r['variant']!='candidate' and not r['mutant_caught'])];print('routes',len(routes),'executions',len(rows),'bad',bad)

raise SystemExit(bool(bad))

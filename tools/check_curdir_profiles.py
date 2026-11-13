#!/usr/bin/env python3
"""CurDir platform/mode rejections and conservative argument boundaries."""
import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--core',required=True);p.add_argument('--output',required=True);a=p.parse_args()
repo=pathlib.Path(__file__).resolve().parents[1];compiler=str(pathlib.Path(a.compiler).resolve());out=pathlib.Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
profile_error=b'CurDir is measured only on the ordinary Linux backend'
sources=[pathlib.Path(a.core).resolve()/'tests/curdirt.prg']+sorted((repo/'tests').glob('t16*_curdir_*.hb'))
for source in sources:
 if '_spacing_' in source.name:continue
 for target,flag in [('windows',None),('windows','--experimental-llvm'),('windows','--experimental-llvm-no-trace'),('linux','--experimental-llvm'),('linux','--experimental-llvm-no-trace')]:
  cmd=[compiler,source,out/'rejected.s','--target='+target]
  if flag:cmd.append(flag)
  r=subprocess.run(list(map(str,cmd)),cwd=repo,capture_output=True,timeout=30)
  # The wrapper-return fixture can surface the dependent call's missing
  # return proof before the CurDir target diagnostic during inference.
  wrapper = source.name == 't1625_curdir_return.hb' and b'`place` never returns a value' in r.stderr
  ok=r.returncode!=0 and (profile_error in r.stderr or wrapper);assert ok,(source,target,flag,r.stderr)
  rows.append({'source':source.name,'target':target,'mode':flag or 'ordinary','rejected':ok,'diagnostic':r.stderr.decode()})
for source in sorted((repo/'tests').glob('t16*_curdir_neg_*.hb')):
 r=subprocess.run([compiler,str(source),str(out/'negative.s')],cwd=repo,capture_output=True,timeout=30)
 ok=r.returncode!=0 and b'CurDir supports no argument or one literal string/NIL' in r.stderr;assert ok,(source,r.stderr)
 rows.append({'source':source.name,'target':'linux','mode':'ordinary','argument_rejected':True,'diagnostic':r.stderr.decode()})
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',len(rows),'mode/platform/argument rejection checks')

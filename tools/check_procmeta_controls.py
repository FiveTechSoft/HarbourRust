#!/usr/bin/env python3
"""Fail-closed metadata-store proof and LLVM boundaries."""
from pathlib import Path
import subprocess,json,os,hashlib,argparse
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();compiler=Path(a.compiler).resolve();repo=Path(__file__).resolve().parents[1];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
fixtures={
 'safe':('procedure main()\n? 1\nreturn\n',False),
 'direct':('procedure main()\n? ProcName()\nreturn\n',True),
 'ancestor_callee':('procedure main()\nfoo()\nreturn\nfunction foo()\n? ProcLine(1)\nreturn nil\n',True),
 'dead':('procedure main()\nif .F.\n? ProcLine()\nendif\nreturn\n',True),
 'eval':('procedure main()\nlocal b := {|| 1}\n? Eval(b)\nreturn\n',True),
 'unknownsafe':('procedure main()\n? Date()\nreturn\n',True),
}
for name,(text,want)in fixtures.items():
 src=out/(name+'.prg');src.write_text(text);p=subprocess.run([str(compiler),str(src),str(out/'probe.s')],cwd=repo,capture_output=True,env=dict(os.environ,HBC_META_DUMP='1'));assert not p.returncode,p.stderr;exact=('metadata-lines='+str(want).lower()).encode()in p.stderr;assert exact,(name,p.stderr);rows.append(dict(control=name,expected=want,pass_=exact,stderr=p.stderr.hex()))
for src in ['tests/t1019_procline_ancestor_neg.prg','tests/t1020_procline_dynamic_neg.prg','tests/t1022_procline_effect_arg_neg.prg','tests/t1053_procname_ancestor_neg.prg','tests/t1054_procname_effect_arg_neg.prg']:
 for flag in ['--experimental-llvm','--experimental-llvm-no-trace']:
  p=subprocess.run([str(compiler),src,str(out/'probe.ll'),flag],cwd=repo,capture_output=True);exact=p.returncode==1 and b'ancestor or dynamic level is not supported'in p.stderr;assert exact,(src,flag,p.stderr);rows.append(dict(control='LLVM',source=src,flag=flag,pass_=exact,rc=p.returncode,stderr=p.stderr.hex()))
(out/'results.json').write_text(json.dumps({'compiler_sha256':hashlib.sha256(compiler.read_bytes()).hexdigest(),'rows':rows},indent=2)+'\n');print('CONTROLS',len(rows),'PASS')
for n in ['probe.s','probe.ll']:(out/n).unlink(missing_ok=True)

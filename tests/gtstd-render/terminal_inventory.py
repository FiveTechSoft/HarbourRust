#!/usr/bin/env python3
"""Original MIT. Audit final emitted assembly, after late helper generation."""
from pathlib import Path
import argparse,subprocess,re,json,hashlib
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
programs={'macro':'function Main()\nlocal c:="1 +"\n? ""\n? &(c)\nreturn nil\n','strdyn':'function V(x)\nreturn x\nfunction Main()\nlocal a:=V(7)\na:=V("oops")\n? ""\n? Str(a)\nreturn nil\n','dbf':'function Main()\n? ""\ndbUseArea(.T.,"DBFNTX","missing.dbf","A",.F.,.T.)\n? FieldGet(1)\nFieldPut(1,1)\nreturn nil\n','arithmetic':'function Main()\nlocal n:=0,a:={1,2}\n? ""\n? a[n]\n? 1/n\nBreak("end")\nreturn nil\n'};rows=[];problems=[]
for name,s in programs.items():
 w=out/name;w.mkdir();p=w/'p.prg';p.write_text(s)
 for target in ['linux','windows']:
  asm=w/(target+'.s');q=subprocess.run([a.compiler,p,asm,'--target='+target,'--instrument','--no-prune'],capture_output=True);(w/(target+'.build.stderr')).write_bytes(q.stderr)
  if q.returncode:problems.append(dict(case=name,target=target,build_rc=q.returncode));continue
  lines=asm.read_text().splitlines();owner='';prev='';sites=[]
  for i,l in enumerate(lines):
   t=l.strip()
   if re.match(r'^[A-Za-z_][A-Za-z0-9_.]*:',t):owner=t.split(':')[0]
   compact=''.join(t.split());kind=None;ok=True
   if re.match(r'mov[lq]?\$60,%eax$',compact):
    kind='exit60';ok=target!='linux' or prev=='call hbc_gtstd_before_fatal'
   elif 'call ExitProcess' in t:kind='ExitProcess-PE-no-new-renderer'
   elif 'jmp hbc_panic_exit' in t:kind='panic-edge'
   elif target=='linux' and t=='syscall' and owner.startswith('hrdbf_'):
    kind='DBF-syscall';ok=prev=='call hbc_gtstd_before_dbf_system'
   elif target=='linux' and t in ['hrm_fail:','hbc_sdf_fail:']:
    kind='late-diagnostic-entry';ok=lines[i+1].strip()=='call hbc_gtstd_before_fatal'
   if kind:
    row=dict(case=name,target=target,line=i+1,owner=owner,kind=kind,guarded=ok,context=lines[max(0,i-3):i+4]);sites.append(row)
    if not ok:problems.append(row)
   if t and not t.startswith('#'):prev=t
  rows.append(dict(case=name,target=target,asm_sha256=hashlib.sha256(asm.read_bytes()).hexdigest(),sites=sites))
result=dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),scope='Final --no-prune assembly from four representative producers, Linux and PE. Static route guards, not execution proof. PE remains old renderer and is a control, no new close inserted. All helper appenders included. External library process exits outside emitted assembly are not a claim.',rows=rows,failures=problems);(out/'results.json').write_text(json.dumps(result,indent=2));print('sites',sum(len(r['sites']) for r in rows),'failures',len(problems));raise SystemExit(bool(problems))

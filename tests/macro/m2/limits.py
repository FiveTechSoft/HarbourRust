from pathlib import Path
import subprocess,json,os,hashlib
R=Path(__file__).resolve().parents[3];E=R/'evidence'/'limits';E.mkdir(exist_ok=True);core='/tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185';rows=[]
cases=[('arity64','Upper(s,'+','.join(['1']*63)+')',None),('arity65','Upper(s,'+','.join(['1']*64)+')','Error: macro call arity exceeds 64 (M2)'),('literal65','Upper("abc",'+','.join(['1']*64)+')','Error: macro call arity exceeds 64 (M2)'),('round15','Round(n,15)',None),('roundminus15','Round(n,-15)',None),('round16','Round(n,16)','Error: macro ROUND decimals outside -15..15 (M2)'),('roundminus16','Round(n,-16)','Error: macro ROUND decimals outside -15..15 (M2)'),('unknown','NoSuchM2(s)','Error: macro function not supported (M2): NOSUCHM2')]
for name,expr,want in cases:
 d=E/name;d.mkdir(exist_ok=True);src='function Main()\nprivate s:=\'abc\',n:=3.555\nOutStd(StrValue(&('+repr(expr)+')),Chr(10))\nreturn nil\nfunction StrValue(v)\nreturn iif(ValType(v)==\'N\',Str(v),v)\n'
 # Keep product output statically typed: Str for numeric cases, raw for strings.
 out='Str(&('+repr(expr)+'))'if name.startswith('round')else'&('+repr(expr)+')';src='function Main()\nprivate s:=\'abc\',n:=3.555\nOutStd('+out+',Chr(10))\nreturn nil\n';(d/'case.prg').write_text(src)
 q=subprocess.run(['/tmp/hr-m2-hbc',str(d/'case.prg'),str(d/'product'),'--instrument'],capture_output=True,cwd=R);assert not q.returncode,q.stderr;p=subprocess.run([str(d/'product')],capture_output=True);(d/'product').unlink()
 q=subprocess.run([core+'/bin/linux/gcc/hbmk2','case.prg','-ooracle','-gtstd'],capture_output=True,cwd=d);assert not q.returncode,q.stderr
 # Unknown oracle would display UI. No output is compared for that unsupported name.
 if name!='unknown':
  o=subprocess.run([str(d/'oracle')],capture_output=True,timeout=10)
  for k,v in [('stdout',o.stdout),('stderr',o.stderr),('rc',str(o.returncode).encode()+b'\n')]: (d/('oracle.'+k)).write_bytes(v)
 else:o=None
 (d/'oracle').unlink()
 for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode()+b'\n')]: (d/('product.'+k)).write_bytes(v)
 ok=p.returncode==1 and want.encode()in p.stderr if want else (p.returncode,p.stdout,p.stderr)==(o.returncode,o.stdout,o.stderr)
 rows.append(dict(name=name,expr=expr,named_stage_limit=want,pass_gate=ok,oracle_exit=o.returncode if o else'not run: unknown terminal UI not needed for named stage limit'));print(name,ok,repr(p.stdout),flush=True)
(E/'results.json').write_text(json.dumps(rows,indent=2)+'\n');assert all(x['pass_gate']for x in rows)

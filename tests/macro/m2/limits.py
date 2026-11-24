from pathlib import Path
import subprocess,json,os,hashlib,sys
R=Path(__file__).resolve().parents[3];E=R/'evidence'/'limits';E.mkdir(exist_ok=True)
# Host adaptation (2026-11-24): HB_M2_COMPILER/HB_ORACLE_CORE override the
# recorded /tmp paths; on a Windows host the oracle is the native mingw64
# hbmk2 and runs directly. The recorded Linux environment stays the default.
cc=os.environ.get('HB_M2_COMPILER','/tmp/hr-m2-hbc');core=os.environ.get('HB_ORACLE_CORE','/tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185')
native=os.name=='nt'
if native:
 hbm=core+'/bin/win/mingw64/hbmk2.exe'
 if not Path(hbm).exists():sys.exit('HB_ORACLE_CORE must point at the native Harbour mingw64 install (bin/win/mingw64/hbmk2.exe) on a Windows host')
else:hbm=core+'/bin/linux/gcc/hbmk2'
rows=[]
cases=[('arity64','Upper(s,'+','.join(['1']*63)+')',None),('arity65','Upper(s,'+','.join(['1']*64)+')','Error: macro call arity exceeds 64 (M2)'),('literal65','Upper("abc",'+','.join(['1']*64)+')','Error: macro call arity exceeds 64 (M2)'),('round15','Round(n,15)',None),('roundminus15','Round(n,-15)',None),('round16','Round(n,16)','Error: macro ROUND decimals outside -15..15 (M2)'),('roundminus16','Round(n,-16)','Error: macro ROUND decimals outside -15..15 (M2)'),('unknown','NoSuchM2(s)','Error: macro function not supported (M2): NOSUCHM2')]
for name,expr,want in cases:
 d=E/name;d.mkdir(exist_ok=True)
 # Keep product output statically typed: Str for numeric cases, raw for strings.
 out='Str(&('+repr(expr)+'))'if name.startswith('round')else'&('+repr(expr)+')';src='function Main()\nprivate s:=\'abc\',n:=3.555\nOutStd('+out+',Chr(10))\nreturn nil\n';(d/'case.prg').write_text(src)
 q=subprocess.run([cc,str(d/'case.prg'),str(d/'product'),'--instrument'],capture_output=True,cwd=R);assert not q.returncode,q.stderr;p=subprocess.run([str(d/'product')],capture_output=True);(d/'product').unlink()
 q=subprocess.run([hbm,'case.prg','-ooracle','-gtstd']+(['-comp=mingw64']if native else[]),capture_output=True,cwd=d);assert not q.returncode,q.stderr
 # Unknown oracle would display UI. No output is compared for that unsupported name.
 if name!='unknown':
  o=subprocess.run([str(d/'oracle.exe' if native else d/'oracle')],capture_output=True,timeout=10)
  for k,v in [('stdout',o.stdout),('stderr',o.stderr),('rc',str(o.returncode).encode()+b'\n')]: (d/('oracle.'+k)).write_bytes(v)
  (d/('oracle.exe' if native else 'oracle')).unlink()
 else:o=None
 for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode()+b'\n')]: (d/('product.'+k)).write_bytes(v)
 ok=p.returncode==1 and want.encode()in p.stderr if want else (p.returncode,p.stdout,p.stderr)==(o.returncode,o.stdout,o.stderr)
 rows.append(dict(name=name,expr=expr,named_stage_limit=want,pass_gate=ok,oracle_exit=o.returncode if o else'not run: unknown terminal UI not needed for named stage limit'));print(name,ok,repr(p.stdout),flush=True)
(E/'results.json').write_text(json.dumps(rows,indent=2)+'\n');assert all(x['pass_gate']for x in rows)

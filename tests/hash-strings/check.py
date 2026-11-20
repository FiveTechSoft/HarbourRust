#!/usr/bin/env python3
"""Own MIT hash-string ownership probes. Harbour is an external executable oracle only."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--baseline');ap.add_argument('--hbmk2',required=True);ap.add_argument('--output',required=True);ap.add_argument('--contributed-p07');a=ap.parse_args();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False);env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def source(body,defs=''):return defs+'\nfunction Main()\n'+body+'\nreturn nil\n'
def src(body,defs=''):return defs+'\nfunction Main()\n'+body+'\nreturn nil\n'
base='local h:={=>},d,z\nd:=Upper("old-value")\nh["k"]:=d\nd:=Upper("new-value")\nz:=Upper("bad-value")\n'
programs={
'literal-write':src('local h:={=>}\nh["host"]:="local"\nh["port"]:=3306\n? h["host"],h["port"]'),
'literal-init':src('local h:={"a"=>"literal","b"=>""}\n? h["a"],Len(h),h["b"]'),
'literal-reassign':src('local h:={"a"=>1}\nh:={"b"=>"literal"}\n? h["b"],Len(h)'),
'hset-literal':src('local h:={=>}\nhb_HSet(h,"k","literal")\n? h["k"]'),
'bad-value-cache-reuse':src(base+'? h["k"],z'),
'same-cell':src(base+'h["k"]:=h["k"]\n? h["k"]'),
'overwrite':src(base+'h["k"]:="replacement"\n? h["k"]'),
'clone':src(base+'local b:=hb_HClone(h)\nhb_HClear(h)\n? b["k"]'),
'copy':src(base+'local b:={=>}\nhb_HCopy(h,b)\nhb_HClear(h)\n? b["k"]'),
'merge':src(base+'local b:={=>}\nhb_HMerge(b,h)\nhb_HClear(h)\n? b["k"]'),
'delete':src(base+'hb_HDel(h,"k")\n? Len(h)'),
'delete-at':src(base+'hb_HDelAt(h,1)\n? Len(h)'),
'fill':src(base+'hb_HFill(h,7)\n? h["k"]'),
'clear':src(base+'hb_HClear(h)\n? Len(h)'),
'get-owned':src(base+'local y:=hb_HGet(h,"k")\nhb_HClear(h)\n? y'),
'getdef-owned':src(base+'local y:=hb_HGetDef(h,"k")\nhb_HClear(h)\n? y'),
'valueat-owned':src(base+'local y:=hb_HValueAt(h,1)\nhb_HClear(h)\n? y'),
'borrowed-array-source':src('local a:={1,"canary"},h:={"k"=>a[2]}\na:={1,"changed"}\n? h["k"]'),
'empty-string':src('local h:={"k"=>""}\n? Len(h),h["k"]\nhb_HClear(h)'),
'numeric-hvalues':src('local h:={"k"=>1},a:=hb_HValues(h),x\na[1]:=2\nfor each x in a\n? x\nnext'),
}
# Harbour requires every local declaration before executable statements.
# Move declarations introduced in the body to the start without changing
# either compiler's input; initialization that reads h still stays in order.
for name,text in list(programs.items()):
 lines=text.splitlines();decl=[];body=[]
 for line in lines:
  if line.startswith('local b:=') or line.startswith('local y:='):
   nm,expr=line[6:].split(':=',1);decl.append(nm);body.append(nm+':='+expr)
  else:body.append(line)
 if decl:
  i=body.index('function Main()');body.insert(i+1,'local '+','.join(n+':={=>}' if n=='b' else n for n in decl))
 programs[name]='\n'.join(body)+'\n'
if a.contributed_p07:programs['external-p07-unmodified']=Path(a.contributed_p07).read_text()
def run(cmd,w,label):
 p=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=20)
 for k,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return p
for n,s in programs.items():
 w=out/n;w.mkdir();src=w/'p.prg';src.write_text(s);oracle=w/'oracle';ob=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(oracle)],w,'oracle-build');assert ob.returncode==0,(n,ob.stderr);o=run([oracle],w,'oracle-run');osh=h(oracle);oracle.unlink()
 for mode,flags in [('int',[]),('ext',['--external-as'])]:
  e=w/mode;b=run([a.compiler,src,e,'--target=linux','--instrument',*flags],w,mode+'-build');row=dict(name=n,mode=mode,source_sha256=h(src),oracle_binary_sha256=osh,build_rc=b.returncode)
  if b.returncode==0:
   row['binary_sha256']=h(e);p=run([e],w,mode+'-run');row.update(run_rc=p.returncode,exact=(p.returncode,p.stdout,p.stderr)==(o.returncode,o.stdout,o.stderr));e.unlink()
  else:row['exact']=False
  rows.append(row);print(n,mode,row['exact'],flush=True)
 if a.baseline:
  b=run([a.baseline,src,w/'baseline','--target=linux'],w,'baseline-build');(w/'baseline').unlink(missing_ok=True);rows.append(dict(name=n,mode='baseline-compile',source_sha256=h(src),build_rc=b.returncode,baseline_reject=b.returncode!=0))
report=dict(compiler_sha256=h(Path(a.compiler)),runner_sha256=h(Path(__file__)),scope='Unmodified sources compared against external Harbour, rc/stdout/stderr exact, no normalization; baseline compile is not runtime comparison',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));assert all(x.get('exact',True) for x in rows);print('PASS',sum('exact'in x for x in rows))

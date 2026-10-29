import pathlib,subprocess,os,json,hashlib,argparse
p=argparse.ArgumentParser();p.add_argument('--core',required=True);p.add_argument('--compiler',required=True);p.add_argument('--compiler-sha',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output-dir',required=True);p.add_argument('--default-only',action='store_true');p.add_argument('--allowlist',default='corpus/reviewed-console-originals.json');a=p.parse_args()
repo=pathlib.Path(__file__).resolve().parents[1];core=pathlib.Path(a.core).resolve();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
review=json.loads((repo/a.allowlist).read_text());names=[pathlib.PurePosixPath(x['file']).stem for x in review['files']];hashes={pathlib.PurePosixPath(x['file']).stem:x['sha256'] for x in review['files']}

for n in names:
 p=core/'tests'/(n+'.prg');base=out/n
 assert hashlib.sha256(p.read_bytes()).hexdigest()==hashes[n],f'unreviewed source hash: {p}'
 row={'file':'tests/'+n+'.prg','sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'target':'linux','source':'unchanged','review':'manually inspected: deterministic console output only; no files,network,GUI,interactive input or data mutation','outputs':{}}
 cmd=[a.hbmk2,str(p),'-gtstd','-q','-i'+str(core/'include'),'-o'+str(base)+'-harbour'];r=subprocess.run(cmd,capture_output=True,text=True);row['reference_compile_exit']=r.returncode
 if r.returncode:row['diagnostic']=r.stderr+r.stdout;rows.append(row);print(n,'REFERENCE COMPILE FAIL');continue
 for m,args in ([('default',[])] if a.default_only else [('default',[]),('llvm',['--experimental-llvm'])]):
  dest=str(base)+('.s'if m=='default'else'.ll');subprocess.run([str(pathlib.Path(a.compiler).resolve()),str(p),dest,'-I',str(core/'include')]+args,check=True,capture_output=True)
  obj=str(base)+'-'+m+'.o';exe=str(base)+'-'+m
  if m=='default':subprocess.run(['as','-o',obj,dest],check=True);objects=[obj]
  else:
   subprocess.run(['python3',str(repo/'experiments/llvm-scalar/llvm_aot.py'),dest,obj],check=True);subprocess.run(['python3',str(repo/'experiments/llvm-scalar/link_runtime.py'),dest+'.runtime.s'],check=True);rt=str(base)+'-runtime.o';subprocess.run(['as','-o',rt,dest+'.runtime.s'],check=True);objects=[obj,rt]
  subprocess.run(['ld','-o',exe]+objects,check=True)
 results={}
 for m in (['harbour','default'] if a.default_only else ['harbour','default','llvm']):
  r=subprocess.run([str(base)+'-'+m],capture_output=True,timeout=10);results[m]=(r.returncode,r.stdout,r.stderr);(out/(n+'-'+m+'.stdout')).write_bytes(r.stdout);(out/(n+'-'+m+'.stderr')).write_bytes(r.stderr);row['outputs'][m]={'exit':r.returncode,'stdout_bytes':len(r.stdout),'stdout_sha256':hashlib.sha256(r.stdout).hexdigest(),'stderr_bytes':len(r.stderr)}
 row['exact']=len(set(results.values()))==1;rows.append(row);print(n,'EXACT'if row['exact']else'DIFFER',[(k,v[0],len(v[1]))for k,v in results.items()])
d={'reference':'694428e1c12f726675b19324d62167fa77d68185','compiler':a.compiler_sha,'scope':('Reviewed Linux originals, default versus Harbour only; no LLVM execution claim.' if a.default_only else '14 manually reviewed Linux console originals accepted by LLVM. No adaptations, no whitespace normalization. Default versus LLVM versus freshly rebuilt Harbour pcode/GTSTD. No speed claim.'),'rows':rows};(out/'results.json').write_text(json.dumps(d,indent=2)+'\n')

assert all(r.get('exact') for r in rows),'one or more exact reference checks failed'

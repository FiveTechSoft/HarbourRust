#!/usr/bin/env python3
"""Black-box CurDir Linux oracle comparisons; no compiler implementation imported."""
import argparse,pathlib,subprocess,hashlib,json,resource,os,shutil
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--core',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);p.add_argument('--rustc',default='rustc');p.add_argument('--wrong-controls',action='store_true');a=p.parse_args()
repo=pathlib.Path(__file__).resolve().parents[1];out=pathlib.Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True);core=pathlib.Path(a.core).resolve();compiler=str(pathlib.Path(a.compiler).resolve());hbmk2=str(pathlib.Path(a.hbmk2).resolve())
original=core/'tests/curdirt.prg';assert hashlib.sha256(original.read_bytes()).hexdigest()=='eb45e59b5a57d26657d606809e51dc1273980956a7b1cf62a12e1e36d19d8e57'
# Keep the comparison directories short: full terminal wrapping is not a
# claim of this increment. Raw returned-byte checks cover long path boundaries.
short=out/'cwd';short.mkdir(exist_ok=True);spaces=out/'with space';spaces.mkdir(exist_ok=True);unicode=out/'año';unicode.mkdir(exist_ok=True);trailing=out/'tail  ';trailing.mkdir(exist_ok=True)
symlink=out/'alias'
if not symlink.exists():symlink.symlink_to(short,target_is_directory=True)
contexts=[pathlib.Path('/'),short,spaces,unicode,trailing,symlink]
assert all(len(os.fsencode(p.resolve()))<70 for p in contexts),'use a shorter --output path for terminal comparison'
rows=[];controls=[]
def limits():
 resource.setrlimit(resource.RLIMIT_CPU,(3,3));resource.setrlimit(resource.RLIMIT_AS,(512*1024**2,512*1024**2));resource.setrlimit(resource.RLIMIT_FSIZE,(2*1024**2,2*1024**2))
def run(cmd,cwd,execute=False,preexec=None):return subprocess.run(list(map(str,cmd)),cwd=cwd,capture_output=True,stdin=subprocess.DEVNULL,timeout=4 if execute else 120,preexec_fn=preexec or (limits if execute else None))
def build(cmd,cwd):
 r=run(cmd,cwd);assert r.returncode==0,(cmd,r.stdout,r.stderr)
def compare(oracle,candidate,cwd,key,preexec=None):
 o=run([oracle],cwd,True,preexec);r=run([candidate],cwd,True,preexec)
 exact=(o.stdout,o.stderr,o.returncode)==(r.stdout,r.stderr,r.returncode)
 path=out/'streams'/key;path.mkdir(parents=True,exist_ok=True)
 for name,x in [('oracle',o),('candidate',r)]:
  (path/(name+'.stdout')).write_bytes(x.stdout);(path/(name+'.stderr')).write_bytes(x.stderr);(path/(name+'.rc')).write_text(str(x.returncode)+'\n')
 rows.append({'key':key,'cwd':str(cwd),'exact':exact,'stdout_bytes':len(o.stdout),'stdout_sha256':hashlib.sha256(o.stdout).hexdigest(),'stderr_bytes':len(o.stderr),'rc':o.returncode});assert exact,rows[-1]
 return o
sources=[original]+sorted((repo/'tests').glob('t16*_curdir_*.hb'));sources=[s for s in sources if '_neg_' not in s.name and 'balance' not in s.name]
for source in sources:
 work=out/source.stem;work.mkdir(exist_ok=True);before=hashlib.sha256(source.read_bytes()).hexdigest();prg=source if source==original else work/'probe.prg'
 if source!=original:prg.write_bytes(source.read_bytes())
 build([hbmk2,prg,'-gtstd','-o./oracle'],work)
 for instr in [False,True]:
  cmd=[compiler,source,'candidate.s']+(['--instrument'] if instr else []);build(cmd,work);build(['as','candidate.s','-o','candidate.o'],work);build(['ld','candidate.o','-o','candidate'],work)
  for n,cwd in enumerate(contexts):compare(work/'oracle',work/'candidate',cwd,f'{source.stem}/{int(instr)}-{n}')
 assert hashlib.sha256(source.read_bytes()).hexdigest()==before
# Raw return bytes independently exercise physical cwd, Linux error behavior,
# long path boundary and a deleted cwd, without GTSTD presentation wrapping.
raw=out/'raw';raw.mkdir(exist_ok=True);(raw/'probe.prg').write_text('PROCEDURE Main()\nOutStd(CurDir())\nRETURN\n');build([hbmk2,raw/'probe.prg','-gtstd','-o./oracle'],raw)
longs=[]
parent=out/'long';parent.mkdir(exist_ok=True)
for n in [250,262,263,264,265,300]:
 # Split components so no filesystem component exceeds255 bytes.
 base=parent
 while n-len(os.fsencode(base))-1>240:
  base=base/('a'*100);base.mkdir(exist_ok=True)
 folder=base/('b'*(n-len(os.fsencode(base))-1));folder.mkdir(exist_ok=True);assert len(os.fsencode(folder))==n;longs.append(folder)
for instr in [False,True]:
 build([compiler,raw/'probe.prg','candidate.s']+(['--instrument'] if instr else []),raw);build(['as','candidate.s','-o','candidate.o'],raw);build(['ld','candidate.o','-o','candidate'],raw)
 for n,cwd in enumerate(contexts+longs):compare(raw/'oracle',raw/'candidate',cwd,f'raw/{int(instr)}-{n}')
 # One new deleted directory per child process, so both start in equivalent
 # deleted cwd states and the parent never changes its own directory.
 o=[]
 for name in ['oracle','candidate']:
  d=out/('deleted-'+name+'-'+str(instr));d.mkdir(exist_ok=True)
  def deleted():limits();os.chdir(d);os.rmdir(d)
  r=run([raw/name],out,True,deleted);o.append((r.stdout,r.stderr,r.returncode));assert o[-1]==(b'',b'',0)
 rows.append({'key':'deleted-'+str(instr),'exact':o[0]==o[1],'stdout_bytes':0,'stderr_bytes':0,'rc':0})
if a.wrong_controls:
 changes=[('last-only-hold','let hold_string = !stderr && !raw;','let hold_string = !stderr && !raw && is_last;',repo/'tests/t1644_curdir_spacing_review_space_empty.hb',short,out/'t1644_curdir_spacing_review_space_empty/oracle'),('immediate-separator','    addq $1, hbc_pending(%rip)','    call hbc_pflush\n    call hbc_print_sep',repo/'tests/t1629_curdir_spacing_empty.hb',short,out/'t1629_curdir_spacing_empty/oracle'),('keep-slash','    lea 1(%rsp), %rdi\n    lea -2(%rax), %rsi','    mov %rsp, %rdi\n    lea -1(%rax), %rsi',raw/'probe.prg',short,raw/'oracle'),('short-buffer','    mov $264, %esi','    mov $263, %esi',raw/'probe.prg',longs[2],raw/'oracle')]
 for name,old,new,source,cwd,oracle in changes:
  work=out/name;work.mkdir(exist_ok=True);shutil.copytree(repo/'src',work/'src',dirs_exist_ok=True);f=work/'src/hbc.rs';s=f.read_text();assert s.count(old)==1;f.write_text(s.replace(old,new));build([a.rustc,'--edition=2021','-O',f,'-o',work/'hbc'],work);build([work/'hbc',source,'bad.s'],work);build(['as','bad.s','-o','bad.o'],work);build(['ld','bad.o','-o','bad'],work);bad=run([work/'bad'],cwd,True);good=run([oracle],cwd,True);caught=bad.returncode==0 and (bad.stdout,bad.stderr,bad.returncode)!=(good.stdout,good.stderr,good.returncode);controls.append({'name':name,'caught':caught,'rc':bad.returncode});assert caught
(out/'results.json').write_text(json.dumps({'comparisons':rows,'controls':controls},indent=2)+'\n');print('PASS',len(rows),'exact environment comparisons;',len(controls),'wrong compiler controls caught')

from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser()
for n in ['compiler','baseline','rustc','output']:p.add_argument('--'+n,type=Path,required=True)
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);repo=Path(__file__).resolve().parents[2];text=(repo/'src/hbc.rs').read_text();env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH']);rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,tag):
 q=subprocess.run(list(map(str,cmd)),env=env,capture_output=True,timeout=90)
 for ext,data in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(w/(tag+'.'+ext)).write_bytes(data)
 return q
# Own direct probe must first build and run correctly against the tested compiler.
source='function F(x)\nlocal copy,result\ncopy:=x\nresult:=copy*2\nreturn result\nfunction Main()\nlocal i,result,n:=0,b\nTRY\nresult:=F("warm"+Str(0))\nCATCH\nEND\nb:=hb_memcheck()\nfor i:=1 to 37\nTRY\nresult:=F("abc"+Str(i))\nCATCH\nn++\nEND\nnext\n? n,hb_memcheck()-b\nreturn nil\n'
for name,mutated in [('disabled',text.replace('FRAME_UNWIND.with(|v|v.set(recoverable &&','FRAME_UNWIND.with(|v|v.set(false && recoverable &&')),('skip-owner-cleanup',text.replace('.Lfucatch_{lbl}:\\n    movq $2, -{}(%rbp)', '.Lfucatch_{lbl}:\\n    jmp hbc_seq_unwind\\n    movq $2, -{}(%rbp)'))]:
 assert mutated!=text;w=a.output/name;w.mkdir();src=w/'p.prg';src.write_text(source);values={}
 for label,cc in [('control',a.compiler)]:
  e=w/label;q=run([cc,src,e,'--target=linux','--instrument'],w,label+'-build');assert q.returncode==0;q=run([e],w,label+'-run');assert q.returncode==0 and not q.stderr and list(map(int,q.stdout.split()))==[37,0];values[label]=dict(build_rc=0,run_rc=0,binary_sha256=h(e));e.unlink()
 rs=repo/'src/hbc_frame_mutant.rs';rs.write_text(mutated)
 try:q=run([a.rustc,'--edition','2021','-C','link-arg=-s',rs,'-o',w/'compiler'],w,'compiler-build')
 finally:rs.unlink()
 assert q.returncode==0;mh=h(w/'compiler');q=run([w/'compiler',src,w/'mutant','--target=linux','--instrument'],w,'program-build');assert q.returncode==0;q=run([w/'mutant'],w,'program-run');assert q.returncode==0 and not q.stderr;vv=list(map(int,q.stdout.split()));assert vv==[37,74],vv;rows.append(dict(name=name,mutated_source_sha256=hashlib.sha256(mutated.encode()).hexdigest(),mutant_compiler_sha256=mh,compiler_build_rc=0,program_build_rc=0,run_rc=0,caught=vv[0],pending=vv[1],binary_sha256=h(w/'mutant'),control=values,caught_by_gate=True));(w/'compiler').unlink();(w/'mutant').unlink();print(name,'functional caught',flush=True)
(a.output/'results.json').write_text(json.dumps(dict(compiler_sha256=h(a.compiler),baseline_sha256=h(a.baseline),runner_sha256=h(Path(__file__)),scope='2own functional reversion variants buildcompiler/program0,run0,37catches/74pending vsfreshcontrol0. No build rejection,signal or timeout counts as detection.',rows=rows),indent=2))

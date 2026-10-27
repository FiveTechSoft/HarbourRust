"""CPU-pinned, trace-equivalent scalar layout study. Run run.sh first.

STUDY_LAYOUT=0/1/2 selects a 0/32/64-byte retained text prefix before
LLVM's existing object. STUDY_REPEATS defaults1. This does not change IR.
The identical object and checked symbol offsets distinguish layout from code.
"""
import subprocess,pathlib,os,json,csv,statistics,hashlib,time
os.chdir(pathlib.Path(__file__).resolve().parent)
rustc=os.environ.get('RUSTC','rustc');out=pathlib.Path('run/layout-study');out.mkdir(parents=True,exist_ok=True)
layout=int(os.environ.get('STUDY_LAYOUT','0'));repeats=int(os.environ.get('STUDY_REPEATS','1'))
if layout not in [0,1,2] or not 1<=repeats<=10:raise SystemExit('layout must be0..2, repeats1..10')
base=pathlib.Path('run/bench-traced-rust.rs').read_text()
base=base.replace('(\"sumloop\",n,10),(\"branchloop\",n,10)','(\"sumloop\",n,3),(\"branchloop\",n,3)').replace('(\"recurrence\",n,10)','(\"recurrence\",n,3)')
source=out/'harness.rs';source.write_text(base)
meta={'date':time.strftime('%Y-%m-%dT%H:%M:%S%z'),'layout':layout,'padding_bytes':layout*32,'cpus':sorted(os.sched_getaffinity(0)),'uname':list(os.uname()),'rustc':subprocess.check_output([rustc,'-Vv'],text=True),'method':'All three paths trace-enabled,10M dynamic iterations;31 rotating samples after3warmups;3calls per sample;factorial10x10000 excluded from headline','hashes':{},'runs':[]}
for p in ['corpus.o','bench_current.o','run/bench-traced-rust.rs']:
 meta['hashes'][p]=hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
ap=out/f'padding{layout}.s';ap.write_text('.text\n.globl study_padding\nstudy_padding:\n.fill '+str(layout*32)+',1,0x90\n')
obj=out/f'padding{layout}.o';subprocess.run(['as','-o',str(obj),str(ap)],check=True)
exe=out/f'bench-layout{layout}'
cmd=[rustc,'-O','-C','target-cpu=x86-64','-C','overflow-checks=off','-C','link-arg=bench_current.o','-C','link-arg='+str(obj),'-C','link-arg=-Wl,-u,study_padding','-C','link-arg=corpus.o','-C','relocation-model=static',str(source),'-o',str(exe)]
subprocess.run(cmd,check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
lines=subprocess.check_output(['nm','-n',str(exe)],text=True).splitlines()
symbols={l.split()[-1]:int(l.split()[0],16)for l in lines if len(l.split())==3}
meta['symbols']={n:v for n,v in symbols.items()if n.startswith(('ll_','cur_','study_padding'))or any(k in n for k in ['rust_sumloop','rust_branchloop','rust_recurrence'])}
if not symbols.get('study_padding') or symbols['ll_sumloop'] != (symbols['study_padding']+layout*32+15)//16*16:raise RuntimeError('Linker did not retain the intended LLVM prefix; reject layout claim')
for cpu in meta['cpus']:
 for repeat in range(repeats):
  f=out/f'layout{layout}-cpu{cpu}-r{repeat}.csv';start=time.monotonic()
  with f.open('w')as h:subprocess.run(['taskset','-c',str(cpu),str(exe),'10000000'],stdout=h,check=True)
  rows=list(csv.reader(f.open()));assert len(rows)==372
  summary={}
  for name in ['sumloop','branchloop','fact','recurrence']:
   vals=[statistics.median(int(r[5])/int(r[4])for r in rows if r[0]==name and int(r[1])==w)for w in range(3)]
   summary[name]={'current_ns':vals[0],'llvm_ns':vals[1],'rust_traced_ns':vals[2],'llvm_over_rust':vals[1]/vals[2]}
  meta['runs'].append({'cpu':cpu,'repeat':repeat,'elapsed_s':time.monotonic()-start,'csv':f.name,'summary':summary})
(out/f'layout{layout}.json').write_text(json.dumps(meta,indent=2))
print(json.dumps(meta,indent=2))

#!/usr/bin/env python3
"""Opt-in paired trace/no-trace diagnostic, never used as routine test timing."""
import argparse,pathlib,subprocess,json,os,hashlib,csv,statistics,shutil
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--compiler-sha',required=True);p.add_argument('--output-dir',required=True);p.add_argument('--series',type=int,default=3);p.add_argument('--cpu',type=int,default=0);a=p.parse_args();assert 1<=a.series<=10;assert a.cpu in os.sched_getaffinity(0);base=pathlib.Path(__file__).resolve().parent;experiment=base.parent;out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);compiler=str(pathlib.Path(a.compiler).resolve());result={'compiler':a.compiler_sha,'compiler_sha256':hashlib.sha256(pathlib.Path(compiler).read_bytes()).hexdigest(),'rustc':subprocess.check_output(['rustc','-Vv'],text=True),'uname':list(os.uname()),'cpu':a.cpu,'method':'Two modes, LLVM and Rust both traced or both analysis-only untraced. n1M;100calls/sample;31 rotating samples after3warmups;1013 correctness inputs and null trace restoration. Ratios are medians LLVM/Rust. No cause attribution or production parity claim.','modes':{}}
def run(cmd,**kw):return subprocess.run(cmd,check=True,timeout=120,**kw)
for mode in ['traced','analysis-untraced']:
 d=out/mode;d.mkdir(exist_ok=True);shutil.copy(experiment/'perfextra.hb',d/'perfextra.hb');flag='--experimental-llvm' if mode=='traced' else '--experimental-llvm-no-trace';ir=d/'probe.ll';obj=d/'probe.o';run([compiler,'perfextra.hb',str(ir),flag],cwd=d);run(['python3',str(experiment/'llvm_aot.py'),str(ir),str(obj)]);runtime=pathlib.Path(str(ir)+'.runtime.s');run(['python3',str(experiment/'link_runtime.py'),str(runtime)]);text=runtime.read_text();assert '_start:' in text and '# hbc_print_str:' in text;text='    .text\n'+text[text.index('# hbc_print_str:'):];runtime.write_text(text);run(['as','-o',str(d/'runtime.o'),str(runtime)])
 s=(base/'reverse.rs').read_text()
 if mode!='traced':
  start=s.index('impl Frame {');end=s.index('\n#[inline(never)]',start);s=s[:start]+'''impl Frame {
 #[inline(always)] fn enter(&mut self){}
 #[inline(always)] fn at(&mut self,_s:&'static str){}
 #[inline(always)] fn leave(&mut self){}
}'''+s[end:]
 source=d/'reverse.rs';source.write_text(s);exe=d/'reverse';run(['rustc','--edition=2021','-O','-C','target-cpu=x86-64','-C','overflow-checks=off','-C','relocation-model=static','-C','link-arg='+str(obj),'-C','link-arg='+str(d/'runtime.o'),str(source),'-o',str(exe)],stderr=(d/'build.log').open('w'));series=[]
 for n in range(a.series):
  f=d/f'series-{n+1}.csv';log=d/f'correctness-{n+1}.log';run(['taskset','-c',str(a.cpu),str(exe)],stdout=f.open('w'),stderr=log.open('w'));r=list(csv.reader(f.open()));assert len(r)==62;assert len(set(x[3]for x in r))==1;med=[statistics.median(int(x[2])for x in r if int(x[1])==i)for i in [0,1]];series.append({'csv':f.name,'llvm_median_ns_per100calls':med[0],'rust_median_ns_per100calls':med[1],'ratio':med[0]/med[1]})
 result['modes'][mode]={'series':series,'binary_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'llvm_object_sha256':hashlib.sha256(obj.read_bytes()).hexdigest(),'ir_sha256':hashlib.sha256(ir.read_bytes()).hexdigest()};print(mode,[round(s['ratio'],6)for s in series],flush=True)
(out/'results.json').write_text(json.dumps(result,indent=2)+'\n')

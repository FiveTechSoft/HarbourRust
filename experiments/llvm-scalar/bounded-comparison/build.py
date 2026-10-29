from pathlib import Path
import subprocess,os,json
root=Path(__file__).resolve().parent/'run';root.mkdir(exist_ok=True);repo=Path(__file__).resolve().parents[3];hb=Path(os.environ['HBMK2'])
for k,update in [('sum','x += i\nif x > 1000003\nx -= 1000003\nendif\nif x > 1000003\nx := 0\nendif'),('bits','x := hb_bitAnd(hb_bitXor(x*3+i,i-7),65535)'),('reverse','x := hb_bitAnd(x*3+i,65535)')]:
 source='function main()\nlocal i := 0\nlocal x := 1\nfor i := '+('2000000 to 1 step -1'if k=='reverse'else'1 to 2000000')+'\n'+update+'\nnext\n? x\nreturn\n';(root/(k+'.prg')).write_text(source)
 for mode,args in [('pcode',[]),('gc3',['-gc3'])]:
  subprocess.run([str(hb),str(root/(k+'.prg')),'-gtstd','-q','-o'+str(root/(k+'-'+mode))]+args,check=True,capture_output=True)
 subprocess.run([str(repo/'hbc'),str(root/(k+'.prg')),str(root/(k+'.s'))],check=True,capture_output=True);subprocess.run(['as','-o',str(root/(k+'-default.o')),str(root/(k+'.s'))],check=True);subprocess.run(['ld','-o',str(root/(k+'-default')),str(root/(k+'-default.o'))],check=True)
 subprocess.run([str(repo/'hbc'),str(root/(k+'.prg')),str(root/(k+'.ll')),'--experimental-llvm'],check=True,capture_output=True)
 subprocess.run(['python3',str(repo/'experiments/llvm-scalar/llvm_aot.py'),str(root/(k+'.ll')),str(root/(k+'-llvm.o'))],check=True)
 subprocess.run(['python3',str(repo/'experiments/llvm-scalar/link_runtime.py'),str(root/(k+'.ll.runtime.s'))],check=True);subprocess.run(['as','-o',str(root/(k+'-rt.o')),str(root/(k+'.ll.runtime.s'))],check=True);subprocess.run(['ld','-o',str(root/(k+'-llvm')),str(root/(k+'-llvm.o')),str(root/(k+'-rt.o'))],check=True)
 # Rust equivalent wrapping arithmetic, but values are proven bounded <6,000,001.
 up={'sum':'x=x.wrapping_add(i);if x>1000003{x-=1000003;}if x>1000003{x=0;}','bits':'x=((x*3+i)^(i-7))&65535;','reverse':'x=(x*3+i)&65535;'}[k]
 loop='let mut i=2000000i64;while i>=1 {'+up+'i-=1;}'if k=='reverse'else'let mut i=1i64;while i<=2000000 {'+up+'i+=1;}'
 rust='fn main(){let mut x=std::hint::black_box(1i64);'+loop+'print!("\\n{:>10}",x);}'
 (root/(k+'.rs')).write_text(rust);subprocess.run(['rustc','-O','-C','target-cpu=x86-64','-C','overflow-checks=off','-C','relocation-model=static',str(root/(k+'.rs')),'-o',str(root/(k+'-rust'))],check=True)
 outputs={m:subprocess.check_output([str(root/(k+'-'+m))])for m in ['pcode','gc3','default','llvm','rust']};assert len(set(outputs.values()))==1,(k,outputs)
 print(k,repr(outputs['rust']))
(root/'method.txt').write_text('Whole process: same immutable source for Harbour pcode/gc3 and HarbourRust default/LLVM; Rust equivalent bounded arithmetic. 2M iterations. Normal product configs: Harbour diagnostics, HarbourRust native traces enabled, Rust plain optimized. Not matched diagnostic overhead; not a pure kernel comparison. Values bounded under 6000001, no i64 wrap/double conversion required. Output stdout byte-exact before timing. Linux only.\n')

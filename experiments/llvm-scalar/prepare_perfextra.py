"""Build extra same-semantics controls; no production lowering changes."""
import pathlib
s=pathlib.Path('run/perfextra-current.s').read_text();a=s.index('_start:');b=s.index('hbc_fn_bitmix:');s=(s[:a]+s[b:]).replace('    .globl _start','')
s+='\n.globl hbc_trace_top\n'
for name in ['bitmix','minmaxloop','callloop','reverse','whileflow']:
 s+='\n.text\n.globl cur_'+name+'\ncur_'+name+':\n'
 for r in ['rbx','rbp','r12','r13','r14','r15']:s+='    push %'+r+'\n'
 s+='    sub $24, %rsp\n    mov %rdi, (%rsp)\n    call hbc_fn_'+name+'\n    add $24, %rsp\n'
 for r in ['r15','r14','r13','r12','rbp','rbx']:s+='    pop %'+r+'\n'
 s+='    ret\n'
r=pathlib.Path('run/perfextra.ll.runtime.s').read_text();s+=r[r.index('\n.text\n.globl rt_nl'):]
pathlib.Path('run/perfextra-wrappers.s').write_text(s)
s='use std::{hint::black_box,time::Instant};\nunsafe extern "C" {\n'
for name in ['bitmix','minmaxloop','callloop','reverse','whileflow']:
 for p in ['cur_','ll_']:s+=f'fn {p}{name}(n:i64)->i64;\n'
s+='}\n'
base=pathlib.Path('run/bench-traced-rust.rs').read_text();s+=base[base.index('unsafe extern "C" {static mut'):base.index('#[inline(never)] fn rust_sumloop')]
# Literal line origins match perfextra.prg. Preserve every dynamic trace update.
def at(f,n):return f'f.at("  at {f} (perfextra.prg:{n})\\n");'
def head(f):return '#[inline(never)] fn rust_'+f+'(n:i64)->i64 {let mut f=frame();f.enter();'
def traces(f,ns):return ''.join(at(f,n)for n in ns)
s+=head('bitmix')+traces('bitmix',[3,3])+'let mut i=0i64;'+at('bitmix',4)+'let mut x=1i64;'+at('bitmix',5)+'i=1;while i<=n {'+at('bitmix',6)+'x=(x.wrapping_mul(3)|i)^(x&255);if let Some(v)=i.checked_add(1){i=v}else{break}}'+at('bitmix',8)+'f.leave();x}\n'
s+=head('minmaxloop')+traces('minmaxloop',[10,10])+'let mut i=0i64;'+at('minmaxloop',11)+'let mut x=n;'+at('minmaxloop',12)+'i=1;while i<=n {'+at('minmaxloop',13)+'x=x.wrapping_add(i).min(1000003).max(i.wrapping_sub(3));if let Some(v)=i.checked_add(1){i=v}else{break}}'+at('minmaxloop',15)+'let r=x.wrapping_add(i);f.leave();r}\n'
s+='fn rust_mixstep(x:i64,i:i64)->i64 {let mut f=frame();f.enter();'+traces('mixstep',[17,17])+'let r=x.wrapping_mul(3).wrapping_add(i)^i.wrapping_sub(7);f.leave();r}\n'
s+=head('callloop')+traces('callloop',[19,19])+'let mut i=0i64;'+at('callloop',20)+'let mut x=1i64;'+at('callloop',21)+'i=1;while i<=n {'+at('callloop',22)+'x=rust_mixstep(x,i);if let Some(v)=i.checked_add(1){i=v}else{break}}'+at('callloop',24)+'f.leave();x}\n'
s+=head('reverse')+traces('reverse',[26,26])+'let mut i=0i64;'+at('reverse',27)+'let mut x=0i64;'+at('reverse',28)+'i=n;while i>=1 {'+at('reverse',29)+'x=x.wrapping_mul(3).wrapping_add(i);if let Some(v)=i.checked_add(-1){i=v}else{break}}'+at('reverse',31)+'let r=x.wrapping_add(i);f.leave();r}\n'
s+=head('whileflow')+traces('whileflow',[33,33])+'let mut i=0i64;'+at('whileflow',34)+'let mut x=1i64;'+at('whileflow',35)+'loop {'+at('whileflow',35)+'if i>=n {break}'+at('whileflow',36)+'i=i.wrapping_add(1);'+at('whileflow',37)+'if i&7==0 {'+at('whileflow',38)+'continue}'+at('whileflow',40)+'x=x.wrapping_mul(3).wrapping_add(i);'+at('whileflow',41)+'if x==0 {'+at('whileflow',42)+'break}}'+at('whileflow',45)+'let r=x.wrapping_add(i);f.leave();r}\n'
s+='''fn main(){
 let kernels:[(&str,[unsafe extern "C" fn(i64)->i64;2],fn(i64)->i64);5]=[
'''
for n in ['bitmix','minmaxloop','callloop','reverse','whileflow']:s+=f'("{n}",[cur_{n},ll_{n}],rust_{n}),\n'
s+=''' ];
 let mut count=0;
 for (_,fs,rust) in kernels {for n in -12..=1000 {let e=rust(n);for f in fs {assert_eq!(unsafe{f(n)},e);count+=1;}unsafe{assert!(hbc_trace_top.is_null());}}}
 println!("{count} extra backend/Rust comparisons PASS");
 let Some(n)=std::env::args().nth(1) else{return};let n=n.parse::<i64>().unwrap();
 for (name,fs,rust) in kernels {let e=rust(n);for round in 0..34 {for j in 0..3 {let w=(j+round)%3;let t=Instant::now();let mut result=0;for _ in 0..10 {result=black_box(if w<2{unsafe{fs[w](black_box(n))}}else{rust(black_box(n))});}let ns=t.elapsed().as_nanos();assert_eq!(result,e);if round>=3{println!("{name},{w},{round},{n},10,{ns},{result}");}}}}
}
'''
pathlib.Path('run/perfextra-rust.rs').write_text(s)

"""Create a correctness-only Rust control from the equivalent traced kernels."""
import pathlib
s=pathlib.Path('run/bench-traced-rust.rs').read_text()
s=s[:s.index('fn main()')].replace('use std::{hint::black_box,time::Instant};','')
s+=r'''fn main(){
 let mut calls=0;
 for n in -12..=1000 {unsafe {
  for (a,b,c) in [(cur_sumloop(n),ll_sumloop(n),rust_sumloop(n)),(cur_branchloop(n),ll_branchloop(n),rust_branchloop(n)),(cur_recurrence(n),ll_recurrence(n),rust_recurrence(n)),(cur_arraywalk(n),ll_arraywalk(n),rust_arraywalk(n)),(cur_arraywalk2(n),ll_arraywalk2(n),rust_arraywalk2(n))] {assert_eq!((a,b),(c,c),"n={n}");calls+=2;}
  assert!(hbc_trace_top.is_null(),"trace link leaked for n={n}");
 }}
 for n in -3..=40 {unsafe {let c=rust_fact(n);assert_eq!(cur_fact(n),c);assert_eq!(ll_fact(n),c);assert!(hbc_trace_top.is_null());calls+=2;}}
 println!("{} backend/Rust comparisons PASS; trace chain null after every batch",calls);
}
'''
pathlib.Path('run/validate-traced-rust.rs').write_text(s)

use std::{hint::black_box,time::Instant};
unsafe extern "C" {fn cur_sumloop(n:i64)->i64;fn cur_branchloop(n:i64)->i64;fn cur_fact(n:i64)->i64;fn cur_recurrence(n:i64)->i64;fn ll_sumloop(n:i64)->i64;fn ll_branchloop(n:i64)->i64;fn ll_fact(n:i64)->i64;fn ll_recurrence(n:i64)->i64;}
#[inline(never)] fn rust_sumloop(n:i64)->i64 {let(mut i,mut s)=(1i64,0i64);while i<=n{s=s.wrapping_add(5);if let Some(v)=i.checked_add(1){i=v}else{break}}s.wrapping_add(i)}
#[inline(never)] fn rust_branchloop(n:i64)->i64 {let(mut i,mut s)=(1i64,0i64);while i<=n{s=s.wrapping_add(if i<n.wrapping_sub(7){3}else{1});if let Some(v)=i.checked_add(1){i=v}else{break}}s.wrapping_add(i)}
#[inline(never)] fn rust_fact(n:i64)->i64 {if n<2{1}else{n.wrapping_mul(rust_fact(n-1))}}
#[inline(never)] fn rust_recurrence(n:i64)->i64 {let(mut i,mut s)=(1i64,1i64);while i<=n{s=s.wrapping_mul(3).wrapping_add(i);if let Some(v)=i.checked_add(1){i=v}else{break}}s}
fn main(){let n=std::env::args().nth(1).unwrap_or("1000000".into()).parse::<i64>().unwrap();
 for (name,input,reps) in [("sumloop",n,10),("branchloop",n,10),("fact",10,10000),("recurrence",n,10)] {
 let run=|which:usize|->i64{unsafe{match(name,which){("sumloop",0)=>cur_sumloop(input),("sumloop",1)=>ll_sumloop(input),("sumloop",_)=>rust_sumloop(input),("branchloop",0)=>cur_branchloop(input),("branchloop",1)=>ll_branchloop(input),("branchloop",_)=>rust_branchloop(input),("fact",0)=>cur_fact(input),("fact",1)=>ll_fact(input),("fact",_)=>rust_fact(input),("recurrence",0)=>cur_recurrence(input),("recurrence",1)=>ll_recurrence(input),_=>rust_recurrence(input)}}};
 let expected=run(2);for w in 0..3{assert_eq!(run(w),expected);}
 for round in 0..34 {for j in 0..3 {let w=(j+round)%3;let t=Instant::now();let mut result=0;for _ in 0..reps{result=black_box(run(black_box(w)));}let ns=t.elapsed().as_nanos();assert_eq!(result,expected);if round>=3{println!("{name},{w},{round},{input},{reps},{ns},{result}");}}}
 }
}

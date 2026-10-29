use std::{hint::black_box,time::Instant};
unsafe extern "C" {fn ll_reverse(n:i64)->i64;static mut hbc_trace_top:*mut Frame;}
#[repr(C)] struct Frame {prev:*mut Frame,text:*const u8,len:usize}
impl Frame {
 #[inline(always)] fn enter(&mut self){unsafe{self.prev=std::ptr::read_volatile(&raw const hbc_trace_top);std::ptr::write_volatile(&raw mut hbc_trace_top,self);}}
 #[inline(always)] fn at(&mut self,s:&'static str){unsafe{std::ptr::write_volatile(&raw mut self.text,s.as_ptr());std::ptr::write_volatile(&raw mut self.len,s.len());}}
 #[inline(always)] fn leave(&mut self){unsafe{std::ptr::write_volatile(&raw mut hbc_trace_top,self.prev);}}
}
#[inline(never)] fn rust_reverse(n:i64)->i64 {
 let mut f=Frame{prev:std::ptr::null_mut(),text:std::ptr::null(),len:0};f.enter();
 f.at("  at reverse (perfextra.hb:26)\n");f.at("  at reverse (perfextra.hb:26)\n");
 let mut i=0i64;f.at("  at reverse (perfextra.hb:27)\n");let mut x=0i64;
 f.at("  at reverse (perfextra.hb:28)\n");i=n;
 while i>=1 {f.at("  at reverse (perfextra.hb:29)\n");x=x.wrapping_mul(3).wrapping_add(i);if let Some(v)=i.checked_add(-1){i=v}else{break}}
 f.at("  at reverse (perfextra.hb:31)\n");let r=x.wrapping_add(i);f.leave();r
}
fn main(){
 let mut count=0;for n in -12..=1000{assert_eq!(unsafe{ll_reverse(n)},rust_reverse(n));unsafe{assert!(hbc_trace_top.is_null());}count+=1;}
 eprintln!("{count} reverse values and trace restoration PASS");
 let n=black_box(1000000i64);let expected=rust_reverse(n);
 for round in 0..34 {for j in 0..2 {let which=(round+j)%2;let t=Instant::now();let mut r=0;
  for _ in 0..100{r=black_box(if which==0{unsafe{ll_reverse(black_box(n))}}else{rust_reverse(black_box(n))});}
  let ns=t.elapsed().as_nanos();assert_eq!(r,expected);unsafe{assert!(hbc_trace_top.is_null());}
  if round>=3{println!("{round},{which},{ns},{r}");}
 }}
}

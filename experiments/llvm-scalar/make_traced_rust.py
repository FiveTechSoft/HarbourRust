import pathlib
s=pathlib.Path('bench.rs').read_text()
a=s.index('#[inline(never)] fn rust_sumloop');b=s.index('fn main()',a)
new='''
unsafe extern "C" {static mut hbc_trace_top: *mut Frame;}
#[repr(C)] struct Frame {prev:*mut Frame,text:*const u8,len:usize}
impl Frame {
 #[inline(always)] fn enter(&mut self) {unsafe {self.prev=std::ptr::read_volatile(&raw const hbc_trace_top);std::ptr::write_volatile(&raw mut hbc_trace_top,self);}}
 #[inline(always)] fn at(&mut self,s:&'static str) {unsafe{std::ptr::write_volatile(&raw mut self.text,s.as_ptr());std::ptr::write_volatile(&raw mut self.len,s.len());}}
 #[inline(always)] fn leave(&mut self) {unsafe {std::ptr::write_volatile(&raw mut hbc_trace_top,self.prev);}}
}
fn frame()->Frame {Frame{prev:std::ptr::null_mut(),text:std::ptr::null(),len:0}}
#[inline(never)] fn rust_sumloop(n:i64)->i64 {
 let mut f=frame();f.enter();f.at("  at sumloop (corpus.hb:2)\\n");f.at("  at sumloop (corpus.hb:2)\\n");let mut i=0i64;
 f.at("  at sumloop (corpus.hb:3)\\n");let mut s=0i64;
 f.at("  at sumloop (corpus.hb:4)\\n");i=1;
 while i<=n {f.at("  at sumloop (corpus.hb:5)\\n");s=s.wrapping_add(5);if let Some(v)=i.checked_add(1){i=v}else{break}}
 f.at("  at sumloop (corpus.hb:7)\\n");let r=s.wrapping_add(i);f.leave();r
}
#[inline(never)] fn rust_branchloop(n:i64)->i64 {
 let mut f=frame();f.enter();f.at("  at branchloop (corpus.hb:9)\\n");f.at("  at branchloop (corpus.hb:9)\\n");let mut i=0i64;
 f.at("  at branchloop (corpus.hb:10)\\n");let mut s=0i64;
 f.at("  at branchloop (corpus.hb:11)\\n");i=1;
 while i<=n {f.at("  at branchloop (corpus.hb:12)\\n");if i<n.wrapping_sub(7){f.at("  at branchloop (corpus.hb:13)\\n");s=s.wrapping_add(3)}else{f.at("  at branchloop (corpus.hb:15)\\n");s=s.wrapping_add(1)}if let Some(v)=i.checked_add(1){i=v}else{break}}
 f.at("  at branchloop (corpus.hb:18)\\n");let r=s.wrapping_add(i);f.leave();r
}
#[inline(never)] fn rust_fact(n:i64)->i64 {
 let mut f=frame();f.enter();f.at("  at fact (corpus.hb:20)\\n");f.at("  at fact (corpus.hb:20)\\n");let r=if n<2{1}else{n.wrapping_mul(rust_fact(n-1))};f.leave();r
}
#[inline(never)] fn rust_recurrence(n:i64)->i64 {
 let mut f=frame();f.enter();f.at("  at recurrence (corpus.hb:22)\\n");f.at("  at recurrence (corpus.hb:22)\\n");let mut i=0i64;
 f.at("  at recurrence (corpus.hb:23)\\n");let mut s=1i64;
 f.at("  at recurrence (corpus.hb:24)\\n");i=1;
 while i<=n{f.at("  at recurrence (corpus.hb:25)\\n");s=s.wrapping_mul(3).wrapping_add(i);if let Some(v)=i.checked_add(1){i=v}else{break}}
 f.at("  at recurrence (corpus.hb:27)\\n");f.leave();s
}
#[inline(never)] fn rust_arraywalk(n:i64)->i64 {
 let mut f=frame();f.enter();f.at("  at arraywalk (arraywork.hb:2)\\n");f.at("  at arraywalk (arraywork.hb:2)\\n");let mut a=[1i64,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
 f.at("  at arraywalk (arraywork.hb:3)\\n");let mut i=0i64;
 f.at("  at arraywalk (arraywork.hb:4)\\n");let mut j=1i64;
 f.at("  at arraywalk (arraywork.hb:5)\\n");let mut s=0i64;
 f.at("  at arraywalk (arraywork.hb:6)\\n");i=1;
 while i<=n {f.at("  at arraywalk (arraywork.hb:7)\\n");let ji=(j-1) as usize;a[ji]=a[ji].wrapping_add(i);f.at("  at arraywalk (arraywork.hb:8)\\n");j=j.wrapping_add(1);f.at("  at arraywalk (arraywork.hb:9)\\n");if j>16{f.at("  at arraywalk (arraywork.hb:10)\\n");j=1}if let Some(v)=i.checked_add(1){i=v}else{break}}
 f.at("  at arraywalk (arraywork.hb:13)\\n");i=1;
 while i<=16{f.at("  at arraywalk (arraywork.hb:14)\\n");s=s.wrapping_add(a[(i-1) as usize]);if let Some(v)=i.checked_add(1){i=v}else{break}}
 f.at("  at arraywalk (arraywork.hb:16)\\n");f.leave();s
}
#[inline(never)] fn rust_arraywalk2(n:i64)->i64 {
 let mut f=frame();f.enter();f.at("  at arraywalk2 (arraywork.hb:18)\\n");f.at("  at arraywalk2 (arraywork.hb:18)\\n");let mut a:[i64;256]=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256];
 f.at("  at arraywalk2 (arraywork.hb:19)\\n");let mut i=0i64;
 f.at("  at arraywalk2 (arraywork.hb:20)\\n");let mut j=1i64;
 f.at("  at arraywalk2 (arraywork.hb:21)\\n");let mut s=0i64;
 f.at("  at arraywalk2 (arraywork.hb:22)\\n");i=1;
 while i<=n {f.at("  at arraywalk2 (arraywork.hb:23)\\n");let ji=(j-1) as usize;a[ji]=a[ji].wrapping_add(i);f.at("  at arraywalk2 (arraywork.hb:24)\\n");j=j.wrapping_add(17);f.at("  at arraywalk2 (arraywork.hb:25)\\n");if j>256{f.at("  at arraywalk2 (arraywork.hb:26)\\n");j=j.wrapping_sub(256)}if let Some(v)=i.checked_add(1){i=v}else{break}}
 f.at("  at arraywalk2 (arraywork.hb:29)\\n");i=1;
 while i<=256 {f.at("  at arraywalk2 (arraywork.hb:30)\\n");s=s.wrapping_add(a[(i-1) as usize]);if let Some(v)=i.checked_add(1){i=v}else{break}}
 f.at("  at arraywalk2 (arraywork.hb:32)\\n");f.leave();s
}
'''
pathlib.Path('run/bench-traced-rust.rs').write_text(s[:a]+new+s[b:])

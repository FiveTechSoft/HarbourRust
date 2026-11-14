#[path = "arm64-code.rs"]
mod code;
#[path = "arm64-runtime.rs"]
mod runtime;
#[path = "arm64-writer.rs"]
mod writer;
use code::Code;
fn main() {
    let args: Vec<String> = std::env::args().collect();
    let mut c = Code::default();
    c.prologue(0).unwrap();
    for value in args[2..].iter() {
        let n = value.parse::<i64>().unwrap();
        c.mov(0, n as u64).unwrap();
        c.b("rt_i64", true);
        c.adr(0, "rt_nl").unwrap();
        c.mov(1, 1).unwrap();
        c.b("rt_write", true);
    }
    for n in [false, true] {
        c.mov(0, n as u64).unwrap();
        c.b("rt_bool", true);
    }
    c.mov(0, 0).unwrap();
    c.epilogue().unwrap();
    runtime::emit(&mut c).unwrap();
    let (b, d) = c.finish().unwrap();
    std::fs::write(
        &args[1],
        writer::from_code(&b, &d, 0, "hbc-arm64-runtime-experiment").unwrap(),
    )
    .unwrap();
}

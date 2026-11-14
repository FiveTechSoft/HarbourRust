#[path = "arm64-code.rs"]
mod code;
#[path = "arm64-runtime.rs"]
mod runtime;
#[path = "arm64-trace.rs"]
mod trace;
#[path = "arm64-writer.rs"]
mod writer;
use code::Code;
fn main() {
    let args: Vec<String> = std::env::args().collect();
    let root = std::path::Path::new(&args[1]);
    std::fs::create_dir_all(root).unwrap();
    for depth in [0u16, 1, 4, 5, 17, 65, 257] {
        for action in ["trace", "panic", "zero"] {
            let mut c = Code::default();
            c.prologue(32).unwrap();
            c.ldst(19, 31, 0, false).unwrap();
            c.mov(19, 0).unwrap();
            if depth == 0 {
                c.b(
                    match action {
                        "trace" => "rt_trace",
                        "panic" => "rt_panic",
                        _ => "rt_zero_uncaught",
                    },
                    true,
                );
            } else {
                c.b("frame0", true);
            }
            c.ldst(19, 31, 0, true).unwrap();
            c.mov(0, 0).unwrap();
            c.epilogue().unwrap();
            for i in 0..depth {
                c.label(&format!("frame{i}")).unwrap();
                c.prologue(32).unwrap();
                trace::link(&mut c, 24).unwrap();
                // Zero-length record in the middle must be skipped, not end the traversal.
                if i != 2 {
                    let text = if action == "zero" && depth == 1 {
                        format!("  at main ({}:4)\n", root.join("zero.prg").display())
                    } else {
                        format!("  at proc{i} (fixture.ch:{})\n", i + 10)
                    };
                    trace::location(&mut c, &format!("text{i}"), &text).unwrap();
                }
                if i + 1 == depth {
                    c.b(
                        match action {
                            "trace" => "rt_trace",
                            "panic" => "rt_panic",
                            _ => "rt_zero_uncaught",
                        },
                        true,
                    );
                } else {
                    c.b(&format!("frame{}", i + 1), true);
                }
                trace::unlink(&mut c).unwrap();
                c.epilogue().unwrap();
            }
            runtime::emit(&mut c).unwrap();
            trace::emit(&mut c).unwrap();
            let (b, d) = c.finish().unwrap();
            let bytes = writer::from_code(&b, &d, 0, "hbc-arm64-trace-probe").unwrap();
            std::fs::write(root.join(format!("{action}-{depth}.arm")), bytes).unwrap();
        }
    }
}

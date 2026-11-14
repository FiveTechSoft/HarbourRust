#[path = "arm64-writer.rs"]
mod writer;
fn main() {
    let dir = std::env::args().nth(1).expect("output directory");
    std::fs::create_dir_all(&dir).unwrap();
    for (i, (n, c, e)) in [
        (4, 0, 0),
        (4096, 1, 0),
        (16384, 16384, 16380),
        (16388, 4095, 4),
        (32768, 4096, 32764),
    ]
    .into_iter()
    .enumerate()
    {
        // Byte patterns exercise layout only, not executable instruction semantics.
        let code = vec![0; n];
        let constants = vec![0x55; c];
        std::fs::write(
            format!("{dir}/layout-{i}"),
            writer::from_code(&code, &constants, e, "hbc-layout-test").unwrap(),
        )
        .unwrap();
    }
    let probe = std::fs::read("own-arm64-rust").unwrap();
    let b = writer::from_code(
        &probe[0x4000..0x4028],
        &probe[0x4028..0x403f],
        0,
        "hbc-arm64-own-prototype",
    )
    .unwrap();
    assert_eq!(b, probe);
}

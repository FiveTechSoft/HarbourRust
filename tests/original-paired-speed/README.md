# Paired end-to-end timings of intact upstream originals

Own MIT test-only increment on01f68cbc1db72288ccb0c470e5f529d816f6be59.
No compiler, workflow, push, publication or policy change. Original
programs are mandatory from --spec-root and remain unedited. Sources are
specifications only. Julio Ponce's independent MIT examples remain
credited for ASort; no cambio.diff or supplied implementation is used.

Method: five untimed warm executions per engine and source;101 measured
pairs, alternating which engine runs first. Both engines and the Python
harness inherit the same single CPU affinity (CPU0 in this run). Native
Linux binaries, Harbour built with hbmk2 -gtstd -w0; candidate hbc defaults,
no instrumentation. Every warm and timed rc/stdout/stderr triple must
match the fresh Harbour output. stderr is not assumed empty:longstr2
intentionally writes32bytes. Time uses perf_counter_ns around subprocess
launch, wait and captured output. Binaries are deleted after measurement.
All101raw pairs,source hashes,build logs and warm output bytes are kept.

These are process-level measurements of the actual intact examples,
including process startup,output capture and shutdown. In particular,
recursiv is tiny and largely measures those costs;longstr2 writes about
1.35MB. This is not an isolated algorithm benchmark or a universal speed
claim. Single-core affinity reduces placement variation,not shared-host
noise. No CPU frequency isolation or native Windows/Mac measurement.
A full independent repeat is retained,with the same method.

First run medians in milliseconds (Harbour/HarbourRust ratio;>1 favours
HarbourRust):

- fib.prg: Harbour 6.601119, HarbourRust 2.302636; ratio 2.867x. Repeat ratio 2.867x.
- recursiv.prg: Harbour 2.453267, HarbourRust 1.365090; ratio 1.797x. Repeat ratio 1.791x.
- longstr2.prg: Harbour 3.846174, HarbourRust 4.463143; ratio 0.862x. Repeat ratio 0.862x.

The longstr2 loss is retained and reported,not dropped. 303measured pairs
per run,606pairs across both runs,1212timed process executions all exact.
30warmups per run,60total,also exact. No runtime support expansion or new
original implementation closure. Existing broad regression results belong
to72437161 and were not rerun for this test-only benchmark.
Compiler SHA256 eb36afb9bc6529e7ddec61bcfc839c3c9267485150891965c86014ce8a3d9c70.

    python tests/original-paired-speed/benchmark.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/original-speed --pairs 101

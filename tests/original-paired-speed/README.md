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

## Refresh on compiler9e422bd1,2026-11-24

Test-only evidence refresh on41db9661. Benchmark now records build argv/cwd,
run cwd/stdin and each warm/timed output's rc and SHA256. ENGINE in the
recorded run template means the harbour or harbourrust binary within the
source's work directory. All triples are still checked byte-exact before
recording. No compiler change or new original implementation closure.

Two full independent101-pair runs on compiler
263cd7a814ae7027d9a12f90b55b06c68a332b7eacfee31a79bbe35a372828a1:

- fib.prg: medians6.612285ms Harbour,2.327308ms HarbourRust,ratio2.841x; repeat6.893142/2.418953,2.850x.
- recursiv.prg:2.548080/1.399895ms,1.820x;repeat2.507141/1.384672,1.811x.
- longstr2.prg:4.233916/4.930862ms,0.859x;repeat4.189331/4.877668,0.859x.

The longstr2 loss remains visible. These process timings include startup,
captured output and shutdown,not algorithm-only or universal speed claims.
Both engines inherit the same one-CPU affinity;no frequency/host isolation.
Across repeats606pairs,1212timed executions and60warmups all exact.
No global regression repeated for this tests-only change. Latest compiler
regression remains9e422bd1,including122prior suites,Rust106,Linux1177,
LLVM21,PE1912/22known/0fail emission-only,negative622same18,census58/1041.
Harbour extracted source has no git metadata,commit not verified;hash recorded.

## Fresh post-reset measurement25Nov2026

New evidence on db9294d4compiler,tests-only increment afterd889e489.
Not recovery of lost482cdecc/d21db7f2 or old evidence.No old timing reused.
Compiler c287fe722804acd9c09d0fc69c0326e0279fa16e01834172bd2745a2f910a0ab;
oracle git694428e1c12f726675b19324d62167fa77d68185 freshly built,
hbmk2SHA2562fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
101alternating pairs per source,two independent full runs,five warmups per
engine/source/run,same oneCPUaffinity.606pairs/1212timed executions plus
60warmups,all exact triples including longstr2's intentional stderr.

Medians ms,Harbour/HarbourRust ratio (>1favorsHarbourRust):
- fib:8.294663/2.827309,2.934x;repeat8.214885/2.792853,2.941x.
- recursiv:2.596308/1.392527,1.864x;repeat2.645638/1.424493,1.857x.
- longstr2:4.646497/6.161200,0.754x;repeat4.674195/6.210168,0.753x.

longstr2 loss retained.Process launch,output capture and shutdown included,
not isolated algorithm speed or universal comparison.No host/frequency
isolation.No cross-reset timing-regression claim:environment was rebuilt.
No global regression repeat tests-only,no new original closure,no Windows/
Mac runtime claim.CorpusASort still missing.No push/workflows/publication/
rebase. Raw pairs,commands,cwd,source hashes,warm outputs included.

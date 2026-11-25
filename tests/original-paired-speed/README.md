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

## Current enum-compiler refresh25Nov2026

Fresh tests-only refresh on97679d03.Current compiler
 aa8cb65c93c5ca8999274fb28dd25e85dff8fcee6aedad394f09751dc52d6986.
Same pinned fresh oracle694428e1;two full101-pair runs,606pairs/
1212timed processes+60warmups all exact.Different ordinary shared-host
load means these are not paired regression measurements versus c287fe72.

Medians ms(Harbour/HarbourRust),ratio:
- fib8.490242/2.858912,2.970x;repeat8.492412/2.879795,2.949x.
- recursiv2.682303/1.417717,1.892x;repeat2.660061/1.410235,1.886x.
- longstr2 5.277672/7.011657,0.753x;repeat5.014764/6.765106,0.741x.

Loss retained,longstr2 slower.This includes launch,capturedoutput,shutdown,
not isolatedalgorithm or universalspeed.Same1CPUaffinity,no host/frequency
isolation.No implementation/globalrepeat/originalclosure.Non-Linux untested.

## Fresh paired refresh on scalar-local compiler,2026-11-25

Compiler SHA256 12a0e8d44e94a6d0ef2a8b759e447a9e173968bc2659152de64372732f7fe9f5.
Oracle commit 694428e1c12f726675b19324d62167fa77d68185. Runner now requires and records oracle git identity and its own SHA256.
No compiler change. Two independent101-pair runs,5warmups per engine/source.
Same single CPU affinity for both engines, alternating first engine. Every
rc/stdout/stderr triple exact,including intentional longstr2 stderr.

- fib.prg: Harbour 8.242731ms,HarbourRust 2.793637ms,ratio 2.951x; repeat 8.495667/2.844165ms,2.987x.
- recursiv.prg: Harbour 2.653945ms,HarbourRust 1.417371ms,ratio 1.872x; repeat 2.652143/1.411984ms,1.878x.
- longstr2.prg: Harbour 4.480830ms,HarbourRust 6.050303ms,ratio 0.741x; repeat 4.545909/6.104780ms,0.745x.

The longstr2 loss remains:HarbourRust takes about35%more process time here.
No comparison to earlier host timings as a regression claim. These include
startup,captured output,shutdown and shared-host noise,not algorithm-only
throughput or general superiority.606pairs/1212timed executions+60warmups
all exact. No new admission,global rerun,RC/lifetime or policy change.
Source/raw outputs/commands/cwd/checksums and every paired timing retained.

## Fresh current-frontier21 measurement,2026-11-25

Test-only evidence on compiler711ec8a6a928302e813498c3688b0cfd216dc13f47ead8053245a26e938c22ed.
Oracle694428e1c12f726675b19324d62167fa77d68185,hbmk2 hash recorded.
Two independent101-pair runs,same oneCPUaffinity,alternating engine order,
5warmups per engine/source/run.606pairs/1212timed executions+60warmups,
all rc/stdout/stderr exact,including longstr2 stderr. Source unchanged.

Medians ms,Harbour/HarbourRust ratio (>1 favors HarbourRust):
- fib:8.578523/2.813442,3.049x;repeat8.216443/2.763850,2.973x.
- recursiv:2.623360/1.398771,1.875x;repeat2.658645/1.424465,1.866x.
- longstr2:4.713725/5.178381,0.910x;repeat4.677566/5.187321,0.902x.

longstr2 still loses:HarbourRust takes about10-11%more process time here.
These include process startup,captured output and shutdown. No algorithm-only
or universal speed claim,no host/frequency isolation. No paired regression
claim versus past timings from different shared-host load. Current compiler
unchanged;global tests not rerun for this evidence-only commit. No new source
admission,policy,ownership,RC,Windows/Mac/runtime change or publication.

## Fresh current-frontier25 measurement,2026-11-25

Unchanged compiler4b7ddd4212ad976e97cb74b3367ef5b80877d1cafeef089dc985309ffdf856c8.
Same pinned oracle,2independent101-pair runs,606pairs/1212timed processes,
60warmups,all triples exact. Same singleCPUaffinity,alternating engine order.
Medians ms Harbour/HarbourRust,ratio:
- fib8.456224/2.852181,2.965x;repeat8.591945/2.872657,2.991x.
- recursiv2.747300/1.436924,1.912x;repeat2.737293/1.412641,1.938x.
- longstr2 5.198107/5.825539,0.892x;repeat5.358508/6.077800,0.882x.
longstr2 loss retained,HarbourRust about12-13%more process time. Startup,
capturedoutput,shutdown included,no algorithm-only/universal or historical
regression claim. No host/frequency isolation. No implementation/globalrepeat.

## Fresh immutable string-tree frontier measurement

Compiler 51e8ddf1eb012114ec5c1f0dab6af9b0d45cc996cbbda1c0c065ccc094760bfe.
Two independent 101-pair runs per unedited fib/recursiv/longstr2 source,
5 warmups per engine/source, alternating order and shared one-CPU affinity.
Every rc/stdout/stderr triple matched fresh Harbour: 1212 timed executions
and 60 warmups. Process startup/capture/shutdown included; shared-host
noise remains. No isolated-algorithm or universal speed claim.

Run 1:
- fib.prg: Harbour 8.193198 ms, HarbourRust 2.752782 ms; Harbour/HarbourRust 2.976x.
- recursiv.prg: Harbour 2.634663 ms, HarbourRust 1.410558 ms; Harbour/HarbourRust 1.868x.
- longstr2.prg: Harbour 4.800236 ms, HarbourRust 5.308381 ms; Harbour/HarbourRust 0.904x.
Run 2:
- fib.prg: Harbour 8.171385 ms, HarbourRust 2.733097 ms; Harbour/HarbourRust 2.990x.
- recursiv.prg: Harbour 2.604853 ms, HarbourRust 1.400300 ms; Harbour/HarbourRust 1.860x.
- longstr2.prg: Harbour 4.911755 ms, HarbourRust 5.439016 ms; Harbour/HarbourRust 0.903x.

The longstr2 loss remains reported. Test-only evidence refresh; no compiler
change. Broad regressions belong to the preceding implementation increment.

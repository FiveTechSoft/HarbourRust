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

## Fresh firstbyte/size-tree frontier process measurements

Compiler737836bc4fe50e40d4105e5bd62aaf5d2982165d66352dc3a31069e6e1078ce7.
Two independent101pair runs per source,fivewarmups per engine/source,
alternating order,sameoneCPUaffinity.1212timed+60warm exact triples
against freshHarbour;startup/capture/shutdown included,sharedhost noise
not isolated. No algorithm-only/universal claim.

Run a:
- fib.prg: Harbour 8.367690ms; HarbourRust 2.832266ms; ratio 2.954x.
- recursiv.prg: Harbour 2.783731ms; HarbourRust 1.467830ms; ratio 1.896x.
- longstr2.prg: Harbour 5.872925ms; HarbourRust 6.620072ms; ratio 0.887x.

Run b:
- fib.prg: Harbour 8.706697ms; HarbourRust 2.936369ms; ratio 2.965x.
- recursiv.prg: Harbour 2.760138ms; HarbourRust 1.433277ms; ratio 1.926x.
- longstr2.prg: Harbour 5.531769ms; HarbourRust 6.211415ms; ratio 0.891x.

longstr2 loss remains visible. Tests-only,no compiler change.

## Fresh Linux LLVM console-fix compiler process measurements

Compiler2338925db21cbe386aa2aa10c0160ffa8f992023b4e79de18770660f3063bb7d.
Two independent101pair runs per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exact triples
againstfreshHarbour.Startup/capture/shutdown included,sharedhost noise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.276556ms; HarbourRust 2.795772ms;ratio 2.960x.
- recursiv.prg: Harbour 2.681826ms; HarbourRust 1.423050ms;ratio 1.885x.
- longstr2.prg: Harbour 4.580187ms; HarbourRust 4.927865ms;ratio 0.929x.

Run b:
- fib.prg: Harbour 8.315886ms; HarbourRust 2.791246ms;ratio 2.979x.
- recursiv.prg: Harbour 2.740434ms; HarbourRust 1.456448ms;ratio 1.882x.
- longstr2.prg: Harbour 4.510707ms; HarbourRust 4.933591ms;ratio 0.914x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh immutable-print compiler process measurements

Compiler8d6760e356385d8acda58d87326f5f781796448383161d13d4e2d916f57135ae.
Two independent101pair runs per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.273064ms; HarbourRust 2.770332ms;ratio 2.986x.
- recursiv.prg: Harbour 2.640550ms; HarbourRust 1.416194ms;ratio 1.865x.
- longstr2.prg: Harbour 4.543903ms; HarbourRust 4.980257ms;ratio 0.912x.

Run b:
- fib.prg: Harbour 8.261234ms; HarbourRust 2.767885ms;ratio 2.985x.
- recursiv.prg: Harbour 2.653166ms; HarbourRust 1.416707ms;ratio 1.873x.
- longstr2.prg: Harbour 4.740439ms; HarbourRust 5.231380ms;ratio 0.906x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh print-only selection compiler process measurements

Compilerefbbdc50e71c4a4162f2170821c831b3ecf7a51d711369198f53d096e04597ff.
Two independent101pair runs per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.304355ms; HarbourRust 2.790829ms;ratio 2.976x.
- recursiv.prg: Harbour 2.596553ms; HarbourRust 1.403105ms;ratio 1.851x.
- longstr2.prg: Harbour 4.560289ms; HarbourRust 4.963496ms;ratio 0.919x.

Run b:
- fib.prg: Harbour 8.234788ms; HarbourRust 2.754000ms;ratio 2.990x.
- recursiv.prg: Harbour 2.611963ms; HarbourRust 1.392286ms;ratio 1.876x.
- longstr2.prg: Harbour 4.689506ms; HarbourRust 5.165280ms;ratio 0.908x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh immutable concat-initializer compiler process measurements

Compiler9b50d99477f2ce40b86360f7b4cc926d889f3fd7be585bf321fe8af77f0edbbe.
Two independent101pair runs per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.313446ms; HarbourRust 2.791562ms;ratio 2.978x.
- recursiv.prg: Harbour 2.633826ms; HarbourRust 1.404916ms;ratio 1.875x.
- longstr2.prg: Harbour 4.791922ms; HarbourRust 5.238826ms;ratio 0.915x.

Run b:
- fib.prg: Harbour 8.271272ms; HarbourRust 2.772563ms;ratio 2.983x.
- recursiv.prg: Harbour 2.639407ms; HarbourRust 1.404525ms;ratio 1.879x.
- longstr2.prg: Harbour 5.113305ms; HarbourRust 5.540854ms;ratio 0.923x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh immutable string/NIL process measurements

Compiler61b28c969359680cfec4fcc48450aa3b0143c8f0b3b0e9fc0c06db640f07c33a.
Two independent101pair runs per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.591425ms; HarbourRust 2.875618ms;ratio 2.988x.
- recursiv.prg: Harbour 2.699734ms; HarbourRust 1.424625ms;ratio 1.895x.
- longstr2.prg: Harbour 6.291288ms; HarbourRust 7.075197ms;ratio 0.889x.

Run b:
- fib.prg: Harbour 8.529706ms; HarbourRust 2.881261ms;ratio 2.960x.
- recursiv.prg: Harbour 2.962298ms; HarbourRust 1.549211ms;ratio 1.912x.
- longstr2.prg: Harbour 5.122679ms; HarbourRust 5.729829ms;ratio 0.894x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh nested print-only selection process measurements

Compilerac70cc8d99fa478cb4e8537f555c8c89f7e7507047abab522dcd83b5b7943fad.
Two independent101pairruns per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.654149ms; HarbourRust 2.872143ms;ratio 3.013x.
- recursiv.prg: Harbour 3.055245ms; HarbourRust 1.503394ms;ratio 2.032x.
- longstr2.prg: Harbour 4.814451ms; HarbourRust 5.306655ms;ratio 0.907x.

Run b:
- fib.prg: Harbour 8.777321ms; HarbourRust 2.905731ms;ratio 3.021x.
- recursiv.prg: Harbour 2.633141ms; HarbourRust 1.408550ms;ratio 1.869x.
- longstr2.prg: Harbour 4.832741ms; HarbourRust 5.245927ms;ratio 0.921x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh length-only selection process measurements

Compiler98f1af4edb43601f1a585b2adcdf9e6129a8770c1c113488292c6114751a9aed.
Two independent101pairruns per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.468541ms; HarbourRust 2.821191ms;ratio 3.002x.
- recursiv.prg: Harbour 2.637382ms; HarbourRust 1.414128ms;ratio 1.865x.
- longstr2.prg: Harbour 5.019660ms; HarbourRust 5.616357ms;ratio 0.894x.

Run b:
- fib.prg: Harbour 9.088613ms; HarbourRust 2.949886ms;ratio 3.081x.
- recursiv.prg: Harbour 3.035519ms; HarbourRust 1.509363ms;ratio 2.011x.
- longstr2.prg: Harbour 5.245407ms; HarbourRust 5.747917ms;ratio 0.913x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh Empty-only selection process measurements

Compiler60c199133d23463b773c000f2c8303829fc78ab2d2f80fea152d4258e9dff93e.
Two independent101pairruns per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.337858ms; HarbourRust 2.786134ms;ratio 2.993x.
- recursiv.prg: Harbour 2.641291ms; HarbourRust 1.410714ms;ratio 1.872x.
- longstr2.prg: Harbour 4.701460ms; HarbourRust 5.174656ms;ratio 0.909x.

Run b:
- fib.prg: Harbour 8.216942ms; HarbourRust 2.764889ms;ratio 2.972x.
- recursiv.prg: Harbour 2.613988ms; HarbourRust 1.401852ms;ratio 1.865x.
- longstr2.prg: Harbour 5.036012ms; HarbourRust 5.576632ms;ratio 0.903x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh Asc-only selection process measurements

Compiler6c6df6c14b2aea47c3a673d6209dc22f64c32d1c12fa681fcafaf78a66146c99.
Two independent101pairruns per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.595772ms; HarbourRust 2.842648ms;ratio 3.024x.
- recursiv.prg: Harbour 2.717388ms; HarbourRust 1.432062ms;ratio 1.898x.
- longstr2.prg: Harbour 4.775847ms; HarbourRust 5.217941ms;ratio 0.915x.

Run b:
- fib.prg: Harbour 8.451559ms; HarbourRust 2.831042ms;ratio 2.985x.
- recursiv.prg: Harbour 2.712496ms; HarbourRust 1.437235ms;ratio 1.887x.
- longstr2.prg: Harbour 4.928011ms; HarbourRust 5.289950ms;ratio 0.932x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh ASCII predicate selection process measurements

Compiler7490ef2bf81487fa3259b510eb5e6a3be00d47044dee69fb374992a926b860b9.
Two independent101pairruns per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.363276ms; HarbourRust 2.797831ms;ratio 2.989x.
- recursiv.prg: Harbour 2.680805ms; HarbourRust 1.424549ms;ratio 1.882x.
- longstr2.prg: Harbour 4.788422ms; HarbourRust 5.327439ms;ratio 0.899x.

Run b:
- fib.prg: Harbour 8.347819ms; HarbourRust 2.812565ms;ratio 2.968x.
- recursiv.prg: Harbour 2.619047ms; HarbourRust 1.397960ms;ratio 1.873x.
- longstr2.prg: Harbour 4.647720ms; HarbourRust 5.172580ms;ratio 0.899x.

longstr2 loss retained.Tests-only,no compiler change.

## Fresh literal NIL-pair process measurements

Compilera2101f9451e9d13b1de0f8d4768d8efae127e4cea0f7821d567a9485d29cb0aa.
Two independent101pairruns per source,fivewarmups per engine/source,
alternatingorder,sameoneCPUaffinity;1212timed+60warm exacttriples
againstfreshHarbour.Startup/capture/shutdown included,sharedhostnoise.
No algorithm-only/universalclaim.

Run a:
- fib.prg: Harbour 8.520660ms; HarbourRust 2.847572ms;ratio 2.992x.
- recursiv.prg: Harbour 2.628488ms; HarbourRust 1.408237ms;ratio 1.867x.
- longstr2.prg: Harbour 4.653166ms; HarbourRust 5.034268ms;ratio 0.924x.

Run b:
- fib.prg: Harbour 8.327044ms; HarbourRust 2.797286ms;ratio 2.977x.
- recursiv.prg: Harbour 2.668981ms; HarbourRust 1.419270ms;ratio 1.881x.
- longstr2.prg: Harbour 4.586371ms; HarbourRust 4.933932ms;ratio 0.930x.

longstr2 loss retained.Tests-only,no compiler change.

## Direct NIL print compiler refresh,25Nov2026

Fresh paired process runs on86a2dab8compiler
ed089cce82587b6b9b993b1223fb47fc987ddf07f54b041b622e9ef38a68458e.
Pinned fresh Harbour694428e1,101alternating pairs/source,tworuns,oneCPU,
1212timed+60warm executions all byte-exact. Medians nanoseconds
(Harbour/HarbourRust ratio):fib8446224/2820308,2.995;repeat8589948/2848296,
3.016. recursiv2841517/1451917,1.957;repeat2708572/1429539,1.895.
longstr24777332/5235107,0.913;repeat4766679/5276963,0.903.
The longstr2 loss remains. Startup,captured output and shutdown included,
not isolated algorithm speed or universal comparison. Shared-host noise,
no frequency isolation. No Windows/Mac runtime claim. No compiler change
in this evidence commit,original sources unchanged. Julio Ponce MIT
specifications credited,no implementation/cambio.diff copy. No push,
publication,workflow or rebase.

## Empty literal NIL compiler refresh,25Nov2026

Fresh Harbour694428e1 against c1b681f5compiler
9b46aace70cd275dbed3852dd2022110ccddf25ee25bb9ce53903d625ea98b8b.
Two101alternating-pair runs per3intact originals,same1CPU,1212timed+60warm
executions exact. Medians nanoseconds(Harbour/HarbourRust),ratio:
fib8397747/2802900,2.996;repeat8830172/2939838,3.004.
recursiv2603819/1392381,1.870;repeat2770709/1445123,1.917.
longstr2:4871790/5356610,0.909;repeat5504509/6118252,0.900.
longstr2loss retained.Process startup,capture,shutdown included;shared-host
noise,no frequency isolation,not algorithm-only/universal/paired-regression
speed claims. Original sources unchanged,no Windows/Mac runtime claim.
No compiler change in this evidence commit.No push/workflow/publication/
rebase.Julio Ponce MIT examples are specifications,no implementation copy.

## At selected haystack compiler refresh,25Nov2026

Fresh Harbour694428e1 against658469adcompiler
3fe8397c7b1162c59ffb280ee38e295a35c2e47b9808efe51f6e88af1c304738.
Two101alternating-pair runs/source,three intact originals,1CPU,
1212timed+60warm executions all exact.Medians ns(Harbour/HarbourRust),ratio:
fib8435060/2818134,2.993;repeat8181671/2771741,2.952.
recursiv2716163/1436575,1.891;repeat2650153/1415591,1.872.
longstr2:4668194/5056527,0.923;repeat4704486/5103077,0.922.
longstr2loss retained.Process startup,captured output,shutdown included,
not algorithm-only/universal/regression speed claims.Shared-host noise,
no frequency isolation.No Windows/Mac runtime claim.No compiler change
in evidence commit.Julio Ponce MIT examples specifications only,no supplied
implementation/cambio.diff copy.No push/workflow/publication/rebase.

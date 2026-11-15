# Performance against Harbour 3.2.0, 15 Nov 2026

Question: is the compiler's native output faster than the reference
Harbour implementation? Synthetic kernels only; this is not an ERP
workload benchmark.

## Method

Six sources compiled by both compilers from the same `.prg` text:

| kernel | work |
|---|---|
| loop_int | 200000 iterations of `s := s + i` |
| str | 20000 concatenations `c := c + "x"` |
| arr | 100000 `AAdd(a, i)` |
| func | 500000 calls to `inc2(x) = x + 2` |
| hash | 50000 `hb_hSet(h, "k", i)` |
| strops | 20000 rounds of `SubStr` + `Upper` + `Lower` + `StrTran` |

HarbourRust: the native Windows compiler at `06b45e1` (sha256 prefix
`c66f404e...`), internal PE writer, no instrumentation.

Harbour: the official 3.2.0 Windows distribution in `tools/harbour`
(`harbour.exe`, build r2607071000) with its C output compiled by the
local MinGW-w64 gcc 16.2.0 and linked against the distribution's static
library group. The `hbmk2` driver present in this distribution fails at
its C-compiler probe on this host, so the report reproduces hbmk2's own
compiler and linker command lines by hand; the library set and options
are taken verbatim from `hbmk2 -traceonly`. `OutStd` with `Str`/`hb_eol`
is used for the result line because the plain `?` stream needs a GT
driver selection this manual link does not resolve; both binaries print
identical result bytes.

Each binary is run three times; the table reports the median wall time.
The first execution of a freshly written executable can pay a Windows
Defender cold scan (observed once as 8 s on a trivial program); the
median excludes that artefact.

## Results (seconds)

| kernel | HarbourRust | Harbour 3.2.0 | HarbourRust speedup |
|---|---|---|---|
| loop_int | 0.005 | 0.098 | 19.3x |
| str | 0.005 | 0.083 | 17.2x |
| arr | 0.006 | 0.088 | 14.6x |
| func | 0.009 | 0.149 | 17.4x |
| hash | 0.005 | 0.089 | 18.5x |
| strops | 0.013 | 0.097 | 7.2x |

All six kernels print the same result line in both implementations.

## Limits

Measured on one Windows 11 x86-64 machine while the native test battery
and an unrelated local model server were running. Kernels are synthetic
and small; they do not include DBF/RDD, date, or macro execution, where
HarbourRust has known gaps. This compares the native typed path with
Harbour's dynamic VM on sources both accept; it is not a general
throughput claim and not a claim about programs using unsupported
features. The harness sources and oracle recipe live in the local
`work/bench` directory and are not committed.

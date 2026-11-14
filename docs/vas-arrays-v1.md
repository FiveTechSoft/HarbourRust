# Flat-array VAS v1 (Goose hybrid I3)

This is our MIT implementation, not a port of the Harbour VM allocator.
Harbour is used as a behavioral oracle only. This increment does not claim
complete Goose support or general Harbour array sharing.

## Admission and layout

The typed, whole-program classifier admits 42 programs from the current
1661-entry manifest. The disposable audit probe originally counted 43:
it checked Dyn locals but missed the non-nil Dyn return of
`t225_big_reassign.prg`. The production rule excludes that program. It was
not made eligible by a one-off exception. `tests/vas/cohort.json` records
the exact 42; new PRGs outside the central manifest do not change this count.

Admission runs after signature convergence, separately from the I1 opt-out.
It observes checked local types before branch/loop environments disappear,
includes parameters/returns, and rejects failed rechecks. Only
DArr/DArrU/DArrRef backing is selected. Stack Arr(N) values keep their
representation; their owned boundary copies use the selected family.
The measured cohort contains no DArrRef locals. Existing borrowed-slot
contracts are unchanged, not extended to stable element references.

Programs with unresolved Dyn locals/parameters/returns, nested arrays,
string arrays, mixed arrays, hashes, AView, persistent STATIC, classes,
threads/mutex, DBF_USED or any EXTERNAL declaration remain entirely legacy.
A proven nil-only Dyn return is not an array producer. An Extend call
halfway through a program does not trigger migration: declarations cause
legacy selection from the beginning. DBF exclusion costs 0 among the 115
flat candidates in the audit; separate DBF controls do activate its runtime.

Owner slots remain `{data,len}` (16 bytes); selected backing has a private
24-byte prefix at data-24:

| Offset | Meaning |
| --- | --- |
| -24 | Reserved extent; zero means ordinary fallback |
| -16 | RW-protected/committed bytes; exact allocation bytes for fallback |
| -8 | Capacity in 16-byte cells |

All selected pointers, INCLUDING fallback pointers, use dedicated
alloc/grow/free helpers. They never enter generic `hbc_free` or
`REG_FREE_W`, which assume base=data-8. String/hash/persistent/Extend/DBF
families retain their headers. Routing is explicit at the nine audited
flat allocation/free emission sites and Array(n), scalar AAdd and ASize,
not a global rewrite of allocation calls.

## Reserve, growth and failure policy

Each VAS backing reserves 16 MiB INCLUDING the prefix. Logical capacity
keeps the current initial/doubling/requested-size policy. Needed bytes are
rounded to the host page size. Linux reads AT_PAGESZ from the initial
auxiliary vector, reserves PROT_NONE with mmap and enables RW suffixes
with mprotect. It uses neither MAP_FIXED nor MAP_NORESERVE.
Windows uses GetSystemInfo, VirtualAlloc reserve/commit and
VirtualFree(base,0,MEM_RELEASE). Measured Wine page size is 4096 and
allocation granularity is 65536; they are not interchangeable.

On Linux, 'committed' means RW-protected virtual bytes, not a physical or
swap guarantee. Overcommit can still cause OOM termination after success.
No page-fault handler, decommit, address-stability promise, shared backing
or multi-threaded array management is added. A reservation is retained
until owner release; many live arrays can consume substantial VA.

Reserve failure, initial/later commit failure, or a geometric capacity
larger than the reservation selects an ordinary moving allocation with the
same private prefix. Once fallback, later growth remains fallback. Linux
fallback uses raw mmap/munmap; Windows uses its own HeapAlloc/HeapFree
calls, bypassing arena interception and generic allocation/free helpers.

Checked arithmetic guards capacity doubling, cells*16, header addition
and page rounding before OS calls. Negative ASize uses the existing error;
overflow uses the existing OOM error and exit status. Replacement allocates,
copies live cells and initializes exposed cells (and the snapshotted AAdd
cell) before publishing the owner pointer. Replacement OOM leaves the old
owner pair, header and contents intact before the fatal error. OS release
failures are fatal, not silently counted as successful frees.

Shrink changes len only. ASize growth always writes NIL `{1,0}`, including
shrink/regrow within already writable pages. OS zero-fill is not NIL.
AAdd snapshots its evaluated source cell before growth can release backing.
The existing borrowed-slot API reloads the current owner pair, so moving
fallback does not create a new element-address contract.

## Switches and counters

- `--no-vas-arrays`: compile the legacy layout/helpers, no VAS data/imports.
- `HB_VAS_ARRAYS=off`: an admitted binary uses dedicated ordinary fallback
  from its first allocation. Layout does NOT change at runtime.
- `HBC_VAS_DUMP=1`: compile-time eligibility/reason diagnostic on stderr.

I1/I2 opt-outs remain independent. Allocation balance counts live backing
blocks, not commit syscalls. Growth within a reservation adds no allocation;
moving replacement records one new block and one successful old release.
Instrument builds maintain a separate registry that validates membership
BEFORE reading the prefix, then backend, extent, capacity and commitment.
Registry entries are reused; its concurrent-live limit is 16384. Test-only
fault state exists only in instrument output; normal binaries have no fault
switch. Test probes patch emitted assembly, not production PRGs.

New kernel32 imports are measured in the installed libkernel32.a:
GetSystemInfo hint763 (fb02), VirtualAlloc1486 (ce05), VirtualFree1489
(d105), little-endian .idata$6 prefixes. The own PE writer is exercised under
Wine. Native Windows has NOT been tested.

## Reproduction

Build using the existing Rust 2021 build workflow, then run:

```sh
python3 tests/vas/check_classifier.py --compiler ./hbc --output /tmp/vas-classifier
python3 tests/vas/check_regress.py --compiler ./hbc --output /tmp/vas-linux
python3 tests/vas/benchmark.py --compiler ./hbc --output /tmp/vas-bench --pairs 9
```

Classifier checking accepts `--baseline /path/to/pinned-hbc` to compare
compile-off assembly against a pinned compiler on Linux and Windows.
The benchmark needs a C compiler only for its small native measurement
parent. That parent is not part of the compiler or generated runtime.
It prevents Python fork RSS from contaminating a child's high-water mark.

For Windows regression probes, supply installed tool paths explicitly:

```sh
WINEPREFIX=/your/prefix WINEDEBUG=-all python3 tests/vas/check_regress.py \
  --compiler ./hbc --output /tmp/vas-windows --target windows \
  --wine /path/to/wine --assembler /path/to/x86_64-w64-mingw32-as \
  --linker /path/to/x86_64-w64-mingw32-ld --kernel-lib /path/to/mingw/lib
```

Ordinary channel runs use our PE writer. Only assembly-patched probes use
MinGW, because they test internal state without a public runtime intrinsic.

## Recorded gates, 14 November 2026

Source base ba936133a41ff1c9e54545a63498e7b9d91ccae2, candidate compiler
SHA256 ef2e31a035bf84e9095569606dbf925ff4e491e62282d3a679921b900ddd7f55.

- Linux manifest: 1661/1661 stdout/stderr/rc exact against the pinned base,
  separately normal and instrument. This is differential evidence, not
  1661 Harbour parity claims. The inherited t110 expectation issue remains.
- Compile-off assembly byte-identical to the base for all 1661 entries in
  both modes; excluded/no-array assembly also unchanged. Typed classifier
  exactly 42/1661. Separate permanent check covers both target assemblies.
- Windows Wine cohort B: 1082/1082 stdout/stderr/rc exact against retained
  base raw records, zero timeouts, relative fixture paths. No invalid
  absolute-path cohort-A result is counted.
- Permanent tests: 14 sources x 6 modes = 84 exact channel comparisons per
  platform, post-Main live/reserved/committed/registry zero probes,
  runtime-off zero reserve/commit probes, five deterministic failure cases,
  overflow with no extra OS allocation, eight I1/I2 independence cases,
  three negative controls. Linux and Wine pass. Negative controls catch
  removed NIL initialization, capacity corruption and omitted free.
- Harbour oracle for the cohort42: 38 compile, 31 exact in three channels;
  four LOCAL-in-branch/loop rejections; three headless error timeouts
  (t250/t507/t617); four inherited differences also present in the base
  (t176 negative ASize, t425/426/427 static copy versus alias). A harness-only
  hb_memcheck stub returns zero where used; it is not a Harbour intrinsic.
  These limits are not counted as oracle successes.

### Real array benchmark (nine interleaved triples)

Linux x86-64, same candidate, per-child wall time and peak RSS from the
native measurement parent. Modes are enabled / runtime-off / compile-off.
All outputs, errors and exit codes match. These short runs have visible
scheduler noise; no general speedup is claimed. Min/max samples remain in
the review evidence, not only medians.

| Source | Median ms, E/R/C | Median peak RSS KiB, E/R/C |
| --- | --- | --- |
| AAdd 800k cells | 17.61 / 21.97 / 16.71 | 16380 / 16272 / 16264 |
| ASize to 960k cells | 8.27 / 15.71 / 15.32 | 14796 / 16036 / 15904 |
| 64 live arrays | 3.21 / 3.93 / 3.96 | 5096 / 5176 / 5096 |
| More than reservation | 13.78 / 14.63 / 11.92 | 17220 / 17216 / 17184 |

AAdd does not improve over legacy in this sample; geometric growth crosses
the reservation threshold before 800k live cells. More-than-reservation
also regresses against legacy. ASize shows the clearest gain here. None
of this promises address stability or lower RSS in every workload.

## API references

Read for API contracts, not copied runtime implementation:

- https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc
- https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualfree
- https://learn.microsoft.com/en-us/windows/win32/memory/reserving-and-committing-memory
- https://man7.org/linux/man-pages/man2/mmap.2.html
- https://man7.org/linux/man-pages/man2/mprotect.2.html
- https://www.man7.org/linux/man-pages/man3/getauxval.3.html
- https://docs.kernel.org/mm/overcommit-accounting.html

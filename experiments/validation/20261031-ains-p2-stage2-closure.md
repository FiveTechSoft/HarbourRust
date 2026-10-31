# ains P2 stage 2 closure record, 31Oct 22:38 CET

Independent review of c212a9a6 (agent-01M69TS15RVXCW7413WKGJXYRT):
FAVORABLE within the declared scope, apt for closure. Stage 2 = scalar
builtins ASize/AIns/ADel/AFill over Dyn-held scalar-cell arrays,
statement-only, contract v1. NOT validated / NOT claimed: independent
full-battery repeat (st2e 1524/1524 is writer-reported, not repeated,
by instruction), binary-hash equality of the reviewer rebuild, any
global validation. Interrupted runs st2c (zero artifacts, sandbox
cleanup) and st2d (partial to case ~1161/1524, tool timeout) preserved
raw and never reused.

## Blocker B1 record (found by reviewer 22:23, fixed c212a9a6)
- Root cause (writer stage-2 AFill Dyn path only): a Dyn RHS read from
  a CELL (Expr::Index/Index2/3/4) registered the BORROWED payload as
  temp-free - freed after the fill, freed again at the owner array's
  epilogue dfree (instrumented: allocation registry mismatch rc1;
  uninstrumented: SIGSEGV rc139). Worse subcase: a source cell INSIDE
  the target array was freed by the fill loop itself before later
  cells cloned from it (UAF). Literal and Var-string RHS were clean;
  none of the 14 stage-2 fixtures used a cell RHS - coverage gap
  recorded. Published stage 1 rejects cell-to-cell Dyn RHS statically
  in the checker (verified on the published stage-1 binary), so the
  class existed only in the AFill path.
- Fix: a borrowed Dyn string source (Var view or cell read) is cloned
  ONCE at entry via the existing hbc_strcpy; the owned clone is freed
  after the fill. Genuinely owned temporaries (call results) are
  consumed and freed directly. 31-line diff, no new helpers.

## Verified independently (own rebuild rustc 1.99.1 from anchored
## source, raw rc/bytes, Linux + Wine)
- Identity: c212a9a6 FF 735ffc81 (chain ->00ca0cb6->e7d211c7); tree
  src/hbc.rs sha256 3a7555e2... == run anchor start==end; manifest
  30c64947... == anchor.
- Reviewer's 4 original B1 probes (own-cell total/partial/single-cell,
  foreign-cell): instrumented rc0, no registry mismatch, memcheck
  balances exact; uninstrumented rc0, no SIGSEGV (was rc139).
- Writer probes b1a-b1e byte-exact vs their .out.
- New fixtures t1534 (own/foreign cell RHS) and t1535 (call-result
  RHS): byte-exact vs manifest AND vs fresh Harbour oracles;
  Wine==Linux byte-exact on both and on probes s1/d1.
- Cell independence after fill-from-cell (fresh probe s10):
  afill(x,x[1]); x[2]:="NEW" -> "aa NEW aa", memcheck exact, rc0.
- Fix regressions: t1523/t1524/t1525/t1526 and probes d3/s2/s8
  byte-identical to their pre-fix runs.
- Prior state: 5 stage-1 closures of e7d211c7 verified (21:50 report);
  14 stage-2 fixtures + probes verified (22:23 report).

## Process notes
- Wine collision resolved: reviewer runs ended 22:20:24, before the
  writer's unannounced 22:26:56 battery launch - no overlap. The late
  announcement is recorded as a writer coordination fault.
- Stage-3 contrast (S1-S7) continues; ac6.oracle recaptured valid by
  the writer (libharbour load error was a capture fault: missing
  LD_LIBRARY_PATH), aliasing confirmed (both prints 99) - file pending
  delivery to the reviewer before the final stage-3 contrast. Stage 3
  NOT implemented; no nested mutation, no general Dyn param-return,
  no RC, no silent clones/alias extraction.

# Bounded reduced VAR topology

Own MIT implementation, pinned Harbour used only as behavioral oracle.
The production increment accepts isolated command/xcommand families shaped as:

```
WORD <!root!> [,<!item!>] [<kind:TYPE,AS> <!type!>] [<init:INIT,ASSIGN> <value>]
```

Names and restricted words may vary. Exactly this one-level topology, distinct
anchors with no ambiguous four-letter abbreviation prefix, no required suffix,
no captured prefix translation, no nested result group increment. Existing
isolated `[<!id!>]` path is preserved separately. Family overlap and call guards
remain intact; this does not change global rule priority or rescan suppression.

Captures retain source spans, marker kind, owner and per-owner iteration index.
Optional tails dispatch in source order by anchor, then result order is rendered
by owner. INIT before AS therefore does not swallow the type clause. An anchor
word after a binary operator is an operand, not an optional-tail boundary.
Repeated distinct owners within one result group still fail explicitly; no zip
or Cartesian-product semantics are silently invented.

Expression admission is deliberately narrower than Harbour pp capture. Only
ASCII identifiers, decimal integers, ordinary quoted strings, balanced parens,
function calls and the bounded arithmetic operators are admitted. Macro syntax,
index/array/codeblock/date/escaped literal forms, numeric suffixes, `**` spelling
and incomplete expression shapes are not certified. Captured unsupported forms
fail explicitly rather than translating incorrectly. This validator is a scope
gate, not a Harbour parser or evaluator. Existing 1024-iteration limit remains;
expression validation has a 64-level recursion limit. No runtime/ownership/ABI
change is made.

`cases.json.gz` contains 6134 deduplicated own probes. Replay uses current hbpp
and compiler, with three separately reported outcomes:
- 2794 token matches, including unchanged lines (not all are translations).
- 2743 explicit scope rejections, not supported Harbour syntax.
- 597 unmatched known gaps, not supported Harbour syntax.
- 0 false translations observed. This is evidence, not a completeness proof.

Run `check_reduced_var.py --hbpp ... --hpp ... --output-dir ...` from any cwd.
24 main reduced examples and 3 command definition/removal temporal controls match.
5801 existing own pp fixtures retain exact exit/stdout/stderr (0 changes). Earlier inactive generic candidate and its
20-boundary grid are research history, NOT the production admission contract.
In particular their incomplete/macro/array positives may now be scope errors.
The old restricted-repeat smart guard remains unchanged and passing, rather
than changing its expected rejection merely to make the grid green.

8 own runtime programs match Harbour/default/LLVM exact exit/stdout/stderr on
Linux (`runtime8.json`); both compiler backends/targets are in the normal runners.
4 new explicit-rejection regressions also run in both backends/target profiles.
Local full gates: 1264 manifest rows default + 5 auxiliaries; 550 LLVM PASS rows
plus suite-specific controls. 268 originals x 4 compile profiles have identical
exit/first diagnostics to the refactor baseline; acceptance stays21/15Linux,
20/14Windows. 14 unchanged reviewed Linux originals match freshly built Harbour
exactly in both backends. No real hbclass VAR/class support or original unlock
is claimed. No size/speed comparison or debugger implementation is included.

Known pre-existing removal gap: `#uncommand` against an `#xcommand` rule
removes it here but not in pinned Harbour. This increment does not change that
behavior. X-rule removal is not certified by the three command temporal probes.

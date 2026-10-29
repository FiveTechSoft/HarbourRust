# Historical characterization before implementation

# P2 marker gaps: own-source observations

45 preprocessor-only probes compare pinned Harbour hbpp with our standalone
hpp built from41a92c1. These are NOT runtime tests or newly supported features.
No Harbour implementation was read/copied/translated. Every probe is our own.

- `<!x!>` matches a single ASCII identifier in these measurements: Alpha,A_2,_x.
  It does not match a number,quoted string,expression,member/index access,
  multiple tokens,empty input or non-ASCII identifier in this sample.
- Terminal `<*x*>` captures arbitrary nonempty rest-of-line in this sample,
  including comma-separated tokens and invalid expressions. It is lexical,
  not evidence the resulting program parses or runs.
- `<*x*>` followed by STOP matched none of the15 measured inputs. Do not
  implement it as a normal expression capture with a terminator.
- Our current shared preprocessor rejects both marker definitions as E0010.
  The diagnostic's Harbour attribution is wrong for these valid marker forms.
  This publication records the gap; it changes no production source.

These missing marker definitions are the FIRST blocker for23/8 original test
sources in the268 compile audit. Solving them would not make those sources
pass: later class/runtime/library blockers are unknown until re-audited.

Reproduce after building src/hpp.rs with rustc:

```
python3 experiments/pp-markers/probe.py --hbpp /path/to/hbpp \
  --hpp /path/to/hpp --output-dir /tmp/pp-marker-probes
```

The opt-in probe deliberately checks the CURRENT rejection boundary. Update it
only with a separately reviewed implementation and fresh behavior evidence.

Build the probe frontend with `python3 experiments/pp-markers/build_hpp.py
--output /tmp/hpp`. The standalone src/hpp.rs has a stale one-argument Pp::new
call after the shared engine gained a Windows-profile boolean. The opt-in
builder adapts only that call to false(Linux) in a temporary file and loads the
unchanged src/pp.rs. Production source is untouched. A direct rustc build of
src/hpp.rs currently fails; this is a separate debug-frontend defect.


## Scoped implementation after explicit approval

User approved the shared-preprocessor question on2026-10-29,keeping the change
on experiment/llvm-scalar-aot,validating both backends before publication and
not merging main. Only the two measured match-marker forms are added. This is
own MIT code derived from black-box probes,no Harbour implementation translated.

190 own-source probes cover command/xcommand/statement translate/xtranslate,
identifier literals/expressions/adjacent tokens,optional repetition,wildcard
empty/nonterminal cases and exact quoted tokens. Matched preprocessor token
streams are compared,not whitespace-identical ppo. Nonmatching inputs keep the
prior stricter incomplete-command diagnostic; Harbour leaves them untranslated.
Optional identifier groups repeat greedily; wildcard consumes the whole rest.
The existing call-form translate limitations and other marker grammar stay open.

12 repository regressions add6 executable positives and6 negatives. Both target
profiles/default and LLVM are checked. Default battery1098PASS; LLVM230PASS
(206previous+12positive executions grouped pertarget+12rejection checks).
10218/10130 Rust controls and46 exact error traces remain separate counts.
190 preprocessor probes are not runtime tests. Compilation audit268x4 still
accepts21/15 Linux and20/14 Windows;31first diagnostics move but no newly accepted
original,no lost accepted original. Frozen175 baseline is preserved unchanged.

Historical probe.py intentionally checks the OLD rejection boundary and must
be used with a pre-increment hpp. Current verification:

```
python3 experiments/pp-markers/build_hpp.py --output /tmp/hpp
python3 experiments/pp-markers/check_implemented.py --hbpp /path/to/hbpp \
  --hpp /tmp/hpp --output-dir /tmp/marker-oracle
```

The standalone debug frontend's old constructor is still adapted only in the
opt-in temporary builder; unrelated debug-frontend production repair is omitted.
Versioned audit compiler is explicitly candidate-markers as tested precommit;
publication SHA and independent rebuilt replay are recorded in verification logs.
This does not silently replace old corpus audits with a new compiler label.

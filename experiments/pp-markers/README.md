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

## Historical next blockers after the two-marker increment

The31 moved first diagnostics partition into23 restricted FROM/INHERIT marker
failures,one restricted DESCENDING marker failure,two missing ads.ch includes,
four lexical dotted-word diagnostics and one statement-form failure. Counts
come from the stored audit delta,not31 new execution outcomes. Diagnostic line
numbers are emitted compiler positions and are not automatically original-source
line numbers after include/command expansion. Do not infer exact root cause of
the lexical/statement cases from their first diagnostic alone.

21 own-source hbpp probes now characterize the next restricted-marker gap.
FROM/INHERIT and DESCENDING match case-insensitively in these samples,while
abbreviations,prefix extensions,quoted/parenthesized or multiple tokens do not.
The current implementation still rejects the definitions. This is a new marker
form outside the approved two-marker increment. No code change or permission
for it follows from this record,and no class/RDD support is claimed.

```
python3 experiments/pp-markers/check_restricted_gap.py --hbpp /path/to/hbpp \
  --hpp /tmp/hpp --output-dir /tmp/restricted-gap
```

Missing ads.ch is an include/dependency lookup result under the audit's stated
include policy,not proof that the driver is unavailable in every environment.
Those originals are not executed. No package install,driver/linking change or
new runtime contract is attempted as part of characterization.

## End-to-end guard on limits of the token oracle

Two own-source safe console probes verify older gaps before and after the
marker increment in both backends. A command capturing `.T.` re-emits `. T .`,
which fails the language lexer. A result `#<x>` does not stringify its capture.
Live reference programs compile/run and their output bytes are stored as hex;
our two backends reject in both old/current compilers. No fix is included.

This matters when interpreting190 marker probes: comparing punctuation tokens
is enough to characterize match/nonmatch,but NOT enough to prove correct
lexical re-emission or end-to-end execution of arbitrary captured expressions.
The six positive scalar execution regressions still pass; they do not cover
all expression types. The four first dotted diagnostics in the268 audit are
therefore not proof the language lexer itself is the root cause. A minimized
own-source re-emission failure is now separately preserved. Multiple earlier
command capture/result issues can coexist; accepting a header marker cannot
be promoted to full header/language/runtime support.

## Restricted literal lists:2026-10-30 increment

This increment adds own MIT matching code for literal alternatives such as
`<mode: FROM, INHERIT>` to the shared preprocessor,on the experimental branch.
Names bind through ordinary result markers;source spelling/case is preserved.
Single/multi-word,numeric and empty-parenthesis literal choices are supported.
Ordinary command/translate rules allow keyword abbreviations of at least four
characters;X directives require exact restricted words. This new distinction
is scoped to restricted choices,not an unrelated rewrite of existing literals.
Optional restricted groups repeat greedily,as observed against hbpp.

172 own-source probes compare matched token streams or nonmatches with pinned
hbpp,alongside190 previous marker probes. Nonmatches retain the preexisting own
incomplete-statement diagnostic rather than leaving original text unchanged.
Macro ampersand restrictions and empty/malformed alternatives remain rejected.
A trailing empty choice is legal to Harbour but deliberately outside this
increment;the negative regression records our narrower fail-closed boundary.
Existing translate-prefix/call-form limitations,other result markers,and
lexical reemission/stringify defects are not repaired. Token equality is not
arbitrary end-to-end expression correctness.

Six executable positive and six rejection regressions exercise both backends
and target profiles. Fresh candidate default battery1110PASS ALLGREEN;LLVM
254PASS (previous230 plus12 positive target cases and12 shared rejections).
10218/10130 Rust comparison checks and46 exact error traces stay separate.
Fourteen reviewed original console programs freshly byte-match Harbour/default/
LLVM;this repeats existing evidence,not14 new originals. Two own reference
programs and eight expected rejects reconfirm unchanged dotted/stringify gaps.

Compile-only268x4 acceptance remains21/15 Linux and20/14 Windows.24 distinct
originals move their first diagnostic (96 profile rows),without any newly
accepted or lost accepted source.23 now stop at the separately unsupported
`<.metaClass.>` result marker;one stops at a `#` lexical diagnostic. These are
new frontiers,not24 passing programs. No class/RDD/runtime support is inferred.
Frozen corpus ledgers remain historical and are not silently overwritten.
Versioned results identify candidate-restricted;publication and independently
rebuilt replay are recorded separately in verification logs.

```
python3 experiments/pp-markers/build_hpp.py --output /tmp/hpp
python3 experiments/pp-markers/check_restricted_implemented.py \
  --hbpp /path/to/hbpp --hpp /tmp/hpp --output-dir /tmp/restricted-oracle
```

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

## Next logical-result marker characterization,no implementation

90 own-source preprocessor-only observations characterize `<.m.>`,the next
first blocker in23 class-header originals after3002cb9. Current shared pp still
rejects these results as unknown markers. No production source is changed.

- It tests capture presence,not the truth of the captured expression. Capturing
  `.F.`,0 or an empty string literal produces `.T.`;an absent optional produces
  `.F.`. Required nonempty captures produce `.T.` in these samples.
- Result optional brackets remain separate:an absent capture in `[<.m.>]`
  removes the group,whereas an unbracketed `<.m.>` emits `.F.`.
- Unknown names reject at rule definition. In these pinned probes,changing
  result name m to M also rejects:do not assume the existing case-insensitive
  result validation is an adequate specification for the new form.
- A failed pattern does not acquire a Boolean result. For example the ordinary
  command optional identifier sample with two identifiers remains untranslated.
  Directive/matching behavior is separate from result-marker presence.

A next implementation would need scoped result-name validation,typed marker
recognition for binding and optional groups,and atomic dotted logical output
that stays lexically valid. General reemission/stringify changes are not part
of this characterization or authorized by the restricted-list increment.
Token probes alone would be insufficient:own end-to-end scalar cases must
exercise absent/present,false/zero payloads and result optional groups in both
backends/targets. Existing invalid-name/boundary behavior needs explicit checks.
This is not class-runtime support and no original source was executed.

```
python3 experiments/pp-markers/check_logical_result_gap.py \
  --hbpp /path/to/hbpp --hpp /tmp/hpp --output-dir /tmp/logical-result-gap
```

## Logical result increment:2026-10-30

Own MIT shared-pp code now recognizes `<.m.>` as capture presence. Absent
optional capture emits atomic `.F.`;any nonempty capture emits `.T.`,including
captured `.F.`,0 and `""`. This does not evaluate the payload. Result optional
brackets use binding separately:an absent `[<.m.>]` drops the group. Logical
result names are checked against exact pattern spelling in this increment;
unknown/miscased/malformed names remain definition errors. Existing ordinary
result-name behavior is not globally rewritten.

The90 characterization rows replay as88matched logical-result/validation
checks and2explicit preexisting matcher divergences,not90passes. In the two
ordinary optional-identifier samples,Harbour leaves two identifiers unmatched
but our preexisting matcher consumes them. The plain-result version also
reproduces before the logical increment. This matching issue is not repaired
or hidden.172restricted-list and190previous probes still pass unchanged.

Six own-source positive programs and four negatives are added to both target
profiles/backends. The six positives also freshly byte-match Harbour on Linux.
Default candidate battery1120PASS ALLGREEN;LLVM274PASS (previous254 plus12
positive target cases and8shared rejection cases).10218/10130Rust controls and
46exact error traces remain separate. Fourteen already-reviewed originals are
freshly exact again;no new original is added. Two reference programs and eight
expected rejects reconfirm untouched general dotted-reemission/stringify gaps.

Compile-only268x4 acceptance remains21/15Linux20/14Windows,with no lost/new
accepts.24originals move first diagnostic:23now stop at unsupported conditional
result `<-lck->`;one moves from lexical# to an incomplete-command diagnostic.
No class/runtime support follows. Production beyond this logical-result form,
including conditional results,stringify,general lexical reemission,Dyn and
ownership,is unchanged. Candidate audit labels and frozen historical ledgers
remain separate;independent rebuilt publication checks have their own logs.

```
python3 experiments/pp-markers/check_logical_result_implemented.py \
  --hpp /tmp/current-hpp --before /tmp/pre-logical-hpp \
  --output-dir /tmp/logical-result
```

## Next null-result marker characterization,no implementation

80own-source preprocessor observations characterize `<-m->`,now the first
unsupported result in23class-header originals. The informal conditional-result
label needs precision:this marker emits no payload at all. Without result
brackets,`<-m-> yes` leaves yes whether m matched or not. Inside brackets,
`[<-m-> yes]` retains yes only when m was captured;the group disappears when
absent. Thus binding/optional group membership is the conditional mechanism,
not emitting a Boolean or directly conditionalizing subsequent unbracketed text.
Captured .F.,0 and empty string literals still count as present. Unknown or
miscased marker names reject at definition in the pinned probes. Plain/logical
result markers can coexist with the zero-byte marker.

Current shared pp rejects these definitions unchanged. A next implementation
would need exact-name validation,zero-byte substitution,and inclusion in the
binding set for existing result brackets. Own end-to-end tests should separately
assert unbracketed erasure,present/absent groups,false-valued payload and invalid
names in both backends/targets. No general bracket rewrite,stringify,dotted
reemission,class or ownership contract follows. No original or own runtime
program is executed by this characterization,and no implementation is included.

```
python3 experiments/pp-markers/check_null_result_gap.py \
  --hbpp /path/to/hbpp --hpp /tmp/hpp --output-dir /tmp/null-result-gap
```

## Scoped null-result implementation (experimental)

The shared preprocessor now validates `<-m->` against the exact capture name,
marks nonempty captures as bound for existing result brackets,and substitutes
zero bytes for the marker. It does not conditionalize unbracketed text and does
not evaluate captured values. No general bracket,stringify,lexical reemission,
class,Dyn or ownership implementation is added.

Fresh pinned hbpp observations reproduce all80frozen own-source cases;the new
`check_null_result_implemented.py` replays their result token streams or
validation rejections. This is token behavior,not arbitrary byte reemission.
Six own positive programs are separately byte-exact against freshly compiled
Harbour;ten new battery rows cover unbracketed erasure,optional groups,false
payload,plain/logical coexistence,translation and invalid names. Both target
profiles are checked in LLVM;shared rejection checks exercise both backends.

Local candidate batteries:1130PASS default,294PASS LLVM. Prior172restricted
list and190marker probes pass. Logical-result replay retains88result/validation
passes and2documented preexisting matcher divergences,not90passes.
Fourteen already-reviewed Linux console originals are freshly exact again.
Compile-only268x4 acceptance remains21/15Linux20/14Windows,no lost/new accepts.
23originals advance first diagnostic from `<-lck->` to the result form
`<type: FUNCTION, PROCEDURE>` at hbclass.ch line267. They do not compile
completely. Main is unchanged. No new size or speed claim is made.

```
python3 experiments/pp-markers/check_null_result_implemented.py \
  --hpp /tmp/current-hpp --output-dir /tmp/null-result
```

## Generated directive / escaped marker characterization only

The next23original first diagnostics refer to `<type: FUNCTION, PROCEDURE>`
at hbclass.ch267,but this is not another ordinary result-marker form. There
it is escaped inside a result that generates a new #xcommand definition.
Own probes isolate this without copying a reference implementation.

144preprocessor observations cover outer/inner command and xcommand,escaped
match/result markers,unescaped controls,unknown/miscased generated result
names,outer/inner name collision,optional escaped brackets and abbreviation.
Escapes defer interpretation by one definition stage;the outer captured tag
is substituted while the escaped inner name survives,even with the same name.
Ordinary generated command accepts FUNC for FUNCTION;generated xcommand does
not. Unknown/miscased generated results fail when the factory is invoked,
not when the unused factory is defined. Unescaped nested labels fail earlier.
Our current pp rejects these144cases early,including valid definitions.

Four extra timing observations distinguish registration from escape handling.
An unused factory with an unknown escaped inner result is accepted by hbpp.
A rule only becomes available after the factory invocation. A marker-free
factory already passes our validation but leaks the generated #xcommand as
output and leaves INNER unchanged;Harbour registers it and emits OUT( yes ).
An unused marker-free factory leaves INNER unchanged in both preprocessors.
Thus merely skipping validation for escaped markers would not fix this gap.

A next implementation needs deliberately scoped escaped-token staging and
registration/validation of generated directives in source order,including
name collision,optional brackets,ordinary/X behavior and recursion limits.
This can be a shared-preprocessor increment without class/runtime contracts,
but is broader than one new marker form and needs its own scope approval.
No implementation,new program execution,original acceptance,size or speed
measurement is part of this characterization. Production remains732eb4b.

```
python3 experiments/pp-markers/check_generated_directive_gap.py \
  --hbpp /path/to/hbpp --hpp /tmp/hpp --output-dir /tmp/generated-gap
```

## Generated command implementation, scoped experimental increment

Escaped result markers and escaped optional brackets are now deferred one
stage. Binding/substitution only sees current-stage markers;staged syntax is
restored before registering the generated #command/#xcommand. Generated
rules are validated on invocation of the factory,not when an unused factory
is defined. Exact generated result names preserve the observed invalid-case
boundary without changing the older unescaped name-validation contract.

A generated command definition is registered in source order,not emitted as
program text. Doubled separators followed by another command directive can
register several definitions;quoted separators stay literal. Other generated
directives remain explicitly unsupported. The existing16-expansion recursion
limit still rejects circular command expansion. No general macro staging,
class/runtime,Dyn,ownership or main/LLVM branch merge is included.

Fresh pinned-hbpp replay verifies148observations. These are NOT148equal output
streams:unknown/invalid definitions match rejection behavior;preexisting
stricter own nonmatch errors are preserved where Harbour emits unmatched text.
Eight own positive programs separately match freshly rebuilt Harbour bytes.
Six new rejection fixtures cover unknown/case/exactness/recursion/unsupported
and unescaped labels. Quoted generated separators were also probed directly.
Batteries:1144PASS default and322PASS LLVM,including Windows/Wine;10218/10130
Rust controls and46error traces are separate checks. Prior80null,172restricted
and190marker checks pass;logical replay remains88checks plus2known matcher
divergences,not90passes. Fourteen already-reviewed originals are exact again.

Compile-only268x4 acceptance is unchanged21/15Linux20/14Windows.23originals
advance beyond the escaped header marker to later incomplete-command errors;
one other first diagnostic now explicitly rejects a generated directive
outside command/xcommand scope. None is a new complete original acceptance.
No fresh size or speed comparison is claimed. Main date work is untouched.

```
python3 experiments/pp-markers/check_generated_directive_implemented.py \
  --hbpp /path/to/hbpp --hpp /tmp/current-hpp --output-dir /tmp/generated
```

## No complete rule match: preserve the original statement

A rule for PROCEDURE method CLASS name must not reject an ordinary PROCEDURE
Main() merely because it shares a first keyword. Fresh own hbpp observations
confirm that nonmatching commands preserve source for the language parser.
The old E0020-at-first-keyword fallback is removed,without keyword exceptions.
Thirteen existing negative fixtures remain negative on both backends/targets;
they now assert the parser's real unsupported-statement rejection,not an
invented Harbour preprocessor error. No invalid fixture became accepted.

Three new end-to-end positives exercise overlapping procedure,assignment and
call keywords and match fresh Harbour bytes.1147default/328LLVM battery checks
pass. The32-observation nonmatch oracle is30matching token checks plus2known
translate-prefix differences,NOT32passes;prefix translation is not changed.
Prior148generated-command,80null,172restricted and190identifier/wildcard
boundaries pass,now preserving reference nonmatches. Logical replay still has
88checks plus2preexisting optional-matcher divergences.

Compile-only268x4 acceptance remains21/15Linux20/14Windows.25first diagnostics
advance:21to call-form translation arity limits,2to dynamic macro evaluation,
one to dotted-token reemission and one to #cinline. No newly complete original,
class runtime,main merge,size or speed result follows. Fourteen reviewed
original console outputs are freshly exact again. These diagnostic stages and
old frozen evidence are intentionally not relabeled as current passes.

## Call-form translation: next gap, characterization only

21first diagnostics now reach optional/overloaded call-form translation.
The current implementation treats this as a single function-like define,
which loses overloads and mistakes nested/optional markers for fixed params.
96own-source observations isolate optional nested argument lists,overload
order,different arities and use inside statements/expressions. All reference
preprocessing succeeds,but own results include arity errors and unexpanded
marker text. An ordinary generic pattern defined after a call-specific one
can win;do not assume command-style most-specific precedence here.

12additional observations cover case-insensitive call names,quoted text,
unknown/miscased results,recursion,exact name boundaries,chaining and removal.
`#xuntranslate` removes an X rule while ordinary #untranslate did not remove
that X rule in the measured cases. The current spelling/mechanics differ.
An unknown result is rejected by Harbour at definition,not emitted as text.
These12rows are observations,not successful implementation tests.

A next scoped increment should separate translation rules from #define,
retain overload order,match balanced call tokens with optional/list captures,
substitute only result markers,and preserve unmatched source. Removal and
recursion need explicit regression tests. This is preprocessor work,not new
runtime/class/memory semantics. No production change is part of this section;
latest production is08736b7. General expression translation/prefix behavior
and generated directives beyond command/xcommand remain separately bounded.

## Call-form translation implementation, scoped

Call-form translations now have their own ordered rule table,not a single
#define entry. Latest matching overload wins;unmatched calls remain source.
Balanced expression/list captures and optional nested argument groups match
with a bounded search (10000states per rule). Names are case-insensitive;
result marker spelling is checked at definition. Replacement skips quoted
calls and preserves the surrounding source bytes. Translation recursion has
its own16-stage bound. #xuntranslate removes one matching X rule;ordinary
#untranslate removes ordinary rules only. This does not change #define's
case-sensitive identity or broaden generated-directive execution.

108own preprocessing boundaries pass against fresh pinned hbpp. Eight new
positive programs separately match Harbour bytes;four negative fixtures
exercise bad result names,recursion and rule removal.1159default/352LLVM
battery checks pass,including Windows/Wine. Earlier marker/nonmatch checks
pass with their documented2logical and2translate-prefix divergences kept
separate from passes. Fourteen reviewed originals are exact again.

Compile-only268x4 acceptance remains21/15Linux20/14Windows.25first diagnostics
move relative to08736b7:18to general dotted-token emission,3to literal#,
2to unsupported statements,one to a command-recursion limit and one to an
unterminated dotted token. No new complete original,main merge,class runtime,
Dyn or ownership contract,size or speed claim follows. General prefix
translation,full Harbour expression grammar and lexical reemission remain
open;this is a measured slice,not all #translate syntax.

## Existing lexical atoms survive capture/reemission

cmd_tokens now keeps existing lexer dotted logical atoms and compound
operators intact,without fusing whitespace-separated punctuation. This fixes
`.T.` becoming `. T .`,and `:=`,`++`,`==`,`<=` and related existing operators
being split. It adds no lexer grammar or operator semantics. Alias `->` is
not recognized by this compiler lexer and stays outside this change. Strings
remain raw. Harbour may normalize .NOT. to !;the oracle permits this semantic
normalization instead of pretending textual identity.

52compound-atom preprocessing checks pass;four alias observations remain
outside scope,not56passes. Seven own programs are byte-exact with fresh
Harbour. Two negatives ensure spaced punctuation is not silently fused.
Default battery1168PASS;LLVM368PASS. Six positive atom programs run under
both backends/targets. The seventh,power**,is default-only because the existing
LLVM scalar slice rejects its folded FloatV;this limitation is unchanged and
is not hidden as an LLVM pass. Fourteen reviewed originals are exact again.

Compile-only268x4 acceptance remains21/15Linux20/14Windows. Six first
diagnostics move,but none is a newly complete original. General lexical
reconstruction,stringify,generated directives outside command/xcommand,
class runtime and main date work are not changed. No size/speed claim.

## Stringify: next pp gap, characterization only

Seven of eight original first diagnostics containing literal#come from
stringify result forms;one is the separate unsupported # comparison operator.
80own-source observations compare #<x> and <"x"> under four directives. Both
produce strings and preserve inner spaces/adjacency exactly:alpha(1, 2) is
not alpha ( 1 , 2 ),and doubled input spaces remain doubled in the string.
Captured quoted literals are normalized before enclosing the text;single and
double hello literals both stringify to text containing double quotes.

The current token-vector capture plus join has already discarded those source
spans. Quoting that joined value would silently generate wrong output. A next
pp-only increment needs a captured lexical view plus original/normalized text
for stringify,with quote behavior and optional/absent capture tests. No
runtime/class/memory or # comparison grammar is implied by this gap.

Separately,25original first '..' diagnostics were inspected after atom fixes:
24emitted error lines contain ellipsis used by varargs/forwarding;the remaining
one contains ../test in an RDD USE path. They are not broken logical atoms.
Do not expand the lexer to hide pending varargs ABI or RDD contracts. This
section adds observations only;production remainsfbaef4e,no new execution.

## Plain #capture stringify, scoped exact implementation

Captures retain matcher text and source-token identities;rendering recovers
original byte spans from the owning token buffer,which remains alive during
render. #<x> for a plain capture preserves interior spaces and adjacency.
Single-quoted literals normalize to double-quoted text before enclosing the
result. Existing single/double string delimiters are used only when they can
represent the result exactly. Empty capture produces "";an absent optional
result group still disappears. Marker-looking text inside a stringified
literal is protected from later substitutions.

This is NOT general stringify. List/repeated/nonplain captures,literal-bearing
optional groups,escape literals and results needing bracket/escape delimiters
are explicitly rejected. The separate <"x"> form is still unsupported. Those
paths did not previously yield valid supported stringify programs. No lexer,
runtime,ABI,memory or ownership contract is added. The capture metadata stays
internal to preprocessing;ordinary emitted capture behavior is unchanged.

50supported plain checks pass with exact quoted contents against fresh hbpp;
60additional cases assert explicit outside-slice rejections,not compatibility
passes. Eight own runtime programs are byte-exact with Harbour;14reviewed
originals are exact again.1180default/392LLVM battery checks pass,including
Windows/Wine. Prior marker/call/nonmatch checks pass with their documented
divergences separate. Seven first diagnostics change,but268x4acceptance stays
21/15Linux20/14Windows,no new complete original. No size/speed result follows.

Follow-up regression review against compiled fbaef4e:110 characterization
programs wrapped as real QOut console programs give one baseline acceptance
and50current acceptances,with no lost acceptance.60ordinary-marker controls
have identical preprocessor exit/output/diagnostics. Literal-bearing optional
ordinary capture compiles in both;present stringify previously failed on #;
optional stringify removed before rendering still compiles in both.
A separate result-literal probe DID reveal a regression in the first increment:
"#<x>" was reparsed as stringify. The follow-up recognizes stringify only
outside result literals and preserves previous ordinary substitution inside
those literals. Three quoted controls now exactly match fbaef4e. A new mixed
quoted/unquoted result regression covers both paths.1181default/394LLVM fresh
local checks pass. This correction preserves historical literal behavior;it
does not claim Harbour compatibility of marker-looking text in result literals.

## Next gap: optional groups and expression boundaries

192new behavioral observations,not192compatibility passes:84token matches,
64explicit rejections,44successful-output mismatches.96ordinary-marker
controls have identical pp output/diagnostics versus fbaef4e,so these gaps
preexist the source-span/stringify increment. Examples:

* `[WORD <x>]` on `WORD alpha WORD beta` can capture literal WORD into one
  expression instead of rejecting an unbound repeated result or binding each
  occurrence for a repeated result group.
* `<x> [TAIL <y>]` can accept adjacent identifiers as one capture,where the
  Harbour command does not match.
* Non-call translate currently requires full input consumption instead of
  Harbour's prefix replacement with remaining tokens preserved.

Do not remove stringify guards merely because a single optional match works.
Result-group repetition and expression boundaries need separate verified pp
work. No production change in this characterization.

## Fixed non-call translations, scoped implementation

Rules retain translation identity alongside source-order commands. Pure fixed
translation families now replace token sequences at any unquoted position,
latest matching translation first,before commands. Unmatched source bytes,
including tail adjacency and spaces,are preserved. Commands still require a
whole statement. Expansion is bounded to16passes,10000replacements and1MiB
intermediate output. Removal distinguishes translation/command and X identity;
the previously accepted UXTRANSLATE alias is retained,not newly claimed as
Harbour syntax. XUNTRANSLATE is the measured X removal form.

If a family also has captured/optional or call-form translations,ALL its rules
stay on the historical route.32non-call mixed probes,16call mixed probes and
4temporal mixed probes verify that fallback preserves baseline behavior,even
where Harbour differs. If #define would change the original statement,the
whole statement stays on its historical route. The check uses the pure expand
function on an immutable definition map;it does not consume state. Three macro
probes preserve prior output;one additional probe is a pure translation chain,
not a macro fallback. No general phase reordering is introduced.

The replay classifies250observations into62supported fixed token matches,
36mixed-family baseline checks and152outside-slice observations.16call mixed
controls and3macro controls are additional baseline checks. Seven own console
programs have byte-exact output against freshly rebuilt Harbour.1189default
and410LLVM checks pass fresh locally;14reviewed originals remain freshly
byte-exact.268x4compile audit acceptance is21/15Linux20/14Windows. These
counts do not imply general preprocessing completion or new original accepts.

## Normal stringify next-gap characterization

184own-source observations in normal-stringify-gap-20261031,not implementation
or compatibility passes. For a present plain capture,<"x"> has the same
source-preserving quoting measured for #<x>. For an absent optional capture it
emits zero bytes instead of "". Marker names are case-sensitive. A list capture
stringifies each comma-separated element separately;that is not the plain
capture contract. Result literal data must not be reparsed as a marker.
Escaped/bracket literals and literal-bearing optional groups remain outside
the previous scoped implementation. No production change in this evidence.

## Scoped normal stringify implementation

<"x"> now uses existing exact source spans/quoting for present plain captures.
Absent optional capture emits zero bytes,unlike #<x>'s empty string literal.
Marker identity remains exact;stringified literal data is staged opaque.
Literal-bearing optional match groups,list/nonplain/repeated captures and
bracket/escape literal requirements stay outside the supported slice.

104of184oracle observations verify exact quoted contents or invalid marker
identity;80remain outside-slice observations,not passes. The previous110case
suite is now50#plain+45new normal matches+15outside-slice rejections. Test1180
formerly rejected normal stringify wholesale;it now tests exact-case mismatch,
while1190positively tests the newly supported form. Five own runtime programs
are byte-exact against fresh Harbour.1196default/424LLVM checks pass locally.
Fourteen originals are freshly exact;268x4acceptance stays21/15Linux20/14Windows.
Two first diagnostics advance without a new full original acceptance. Ordinary
capture and quoted#capture controls match baseline;normal marker-looking text
inside a result literal remains literal data. No lexer/runtime/ABI change.

## List stringify characterization

144own-source observations in list-stringify-gap-20261031,not implementation.
#<x> on a list capture quotes the whole captured source,including commas and
interior whitespace. <"x"> quotes top-level elements separately,preserving
separator whitespace. Empty elements contribute no invented empty literal.
Commas inside strings,calls,parentheses or array constructors do not split
an element. Bracket-string and escape-literal semantics remain separate from
the present simple quoted-literal implementation. No new matcher/runtime code.

## Scoped list stringify implementation

Existing list captures can now use #<x> for one quoted complete capture or
<"x"> for separately quoted top-level elements. Commas and surrounding spaces
are preserved;empty elements contribute no invented string. Parentheses and
array-constructor braces keep inner commas together. Capture matching is not
changed. Bracket tokens,escape literals,unrepresentable quote combinations,
non-list nonplain markers and literal-bearing optional match groups remain
outside this slice. Normal-list unmatched delimiter handling fails explicitly.

224oracle observations:176supported exact quoted-content checks and48outside
observations,not224passes.136plain normal probes have identical pp outputs,
exit codes and diagnostics versus512a42d. Five own runtime programs are
byte-exact against fresh Harbour. Tests1179/1196 formerly rejected all lists;
they now reject bracket-token lists. The earlier110case suite becomes50#plain,
45normal,3new list matches and12outside-slice rejections.1202default and436LLVM
checks pass freshly locally;14reviewed originals are freshly exact.268x4audit
acceptance stays21/15Linux20/14Windows. No lexer/runtime/ABI changes or speed
and size claim follow from this preprocessor increment.

## Macro argument nesting and simultaneous parameter substitution

Function-like define argument collection now balances parentheses,braces and
index brackets before treating a comma as an argument separator. Existing
single/double string protection is preserved. Newly reached bracket literals
with commas reject explicitly rather than pretending existing literal support
can normalize them. Mismatched delimiters reject. Existing empty/wrong-arity
behavior is not widened or advertised as Harbour-compatible.

Parameters are substituted in one scan of the ORIGINAL macro body,case-sensitive
and at word boundaries outside strings. Inserted arguments are never rescanned
as parameter names;the resulting body still goes through legitimate recursive
macro expansion. This fixes PAIR(x,y) with an argument containing y,including
codeblock argument syntax,without implementing codeblock runtime support.

25oracle observations:16supported exact token checks and9outside-slice
observations. Eight previously supported controls have identical pp output,
exit and diagnostics versus a6c5cae. Five own console programs are byte-exact
against fresh Harbour.1209default checks pass locally. The original _pp_test
advances from line82macro arity to line120unrepresentable stringify quotes;
it is NOT accepted as a whole.268x4audit acceptance stays21/15Linux20/14Windows;
14reviewed originals are freshly exact. No runtime/ABI/lexer expansion or new
size/speed claim. Existing tests for array temporary Len remain unchanged;
new console fixtures assign arrays to locals rather than changing that limit.

## Bracket literal boundary, decision pending

16own lexical observations,not implementation. Bracket strings are raw until
the first closing bracket,not nested. Both quote characters,commas,semicolons
and comment-looking // or && are data inside the literal. Brackets after an
expression such as a[1] or a [1] remain indexing. Output can normalize to ordinary
quotes where representable;both quote kinds can require a bracket literal.
The existing compiler only protects single/double quotes through comment
stripping,statement splitting,macro expansion,pp tokenization and source lexing.
Adding a lexer arm alone would therefore corrupt content earlier in the pipeline.
A coherent bracket-literal slice needs context-sensitive literal/index handling
across those stages,using existing Str values and no new runtime representation.
Escape strings are a separate contract. No production change here.

21additional context observations:literal/index decisions occur before and
after expansion. Raw RETURN [a,b] and macro-body [a,b] need not normalize in
hbpp output even though a later expression accepts a string. A bracket after
a closed literal is indexing,including whitespace. Stringifying a bracket
capture containing both quote kinds can require e"...",not only another
bracket delimiter. Therefore bracket-string source support does not by itself
prove every previously blocked stringify result is representable. Keep escape
results explicitly outside the bracket-only slice rather than silently dropping
a bracket layer or changing the string contents.

## Bracket source literals, coherent lexical slice

Raw bracket strings now produce the existing Str representation,ending at the
first ]. Source phases protect literals from comment/semicolon processing,
macro lookup and translation matching. PP source tokens are distinct from
pattern tokens,so optional-pattern/result brackets keep their existing meaning.
The reader uses lexical context (an identifier before [ retains indexing);the
compiler token context distinguishes an expression end from a keyword expecting
an expression. Existing index brackets with/without whitespace are preserved.

Macro provenance matters:source bracket arguments protect contents,but bracket
text in a stored macro body still permits parameter and macro substitution as
measured. Representable bracket arguments normalize to ordinary quoted literals
before insertion;arguments requiring BOTH quote kinds reject explicitly pending
separate escape-result support. e"..." remains outside. Stringify of a bracket
capture remains an explicit separate escape-result limit. Thus _pp_test's line120
is NOT claimed fixed or its whole file accepted by this increment.

Seven own console programs are freshly byte-exact with Harbour/default. Five
run in both backends/targets;array-of-strings and string concatenation fixtures
are default-only due to existing LLVM scope.13phase checks and10baseline pp
index/string controls pass.1218default/464LLVM checks pass locally;14reviewed
originals are freshly exact,and268x4acceptance stays21/15Linux20/14Windows.
Test1209 formerly rejected all bracket-comma macro arguments;it now checks an
unterminated bracket,with positive1212covering the supported argument form.
No runtime/ABI representation change or new size/speed claim.

## Escape literal byte contract, measured before implementation

16own expressions were compiled and executed,and then measured via numeric
Asc(SubStr(...)) byte values because GTSTD transforms control characters.
Upper/lower e double-quoted literals support newline,CR,TAB,bell,backspace,
formfeed,vertical tab,backslash and escaped quote;unknown backslash-q becomes q.
Single-quoted e syntax is not accepted. Octal101 gives65;hex41b consumes all
three digits and yields byte27. This byte behavior is not automatically the
compiler's UTF-8 String contract for values above127. A first implementation
must explicitly bound numeric escapes rather than assume Unicode semantics.
No production change in this characterization.

## ASCII escape literal slice

e"..." and E"..." now decode the measured standard ASCII escapes,backslash,
escaped quote and unknown escaped character passthrough into existing Str.
Octal and hex escapes explicitly reject pending a byte-string contract;no
Unicode or >127numeric escape semantics are inferred. Source scanning protects
escaped quotes through comments,separators,continuations,macros,call translations
and source tokenization. Ordinary raw single/double/bracket strings are unchanged.
Stringify can emit bracket or escaped results for both quote kinds/control
contents. Bracket-capture contents preserve their measured quoted source layer.

Ten numeric Asc byte checks exactly match Harbour/default;five own console
programs are freshly byte-exact. Three qualify for LLVM;Asc builtin and string
concatenation remain default-only existing limits.12own stringify outputs match
hbpp exactly. Seven raw-string/index/macro baseline controls match301e081.
Tests1177/1178/1195/1202now reject numeric escapes rather than forms newly
supported by this slice. The old110suite's newly accepted literal boundaries
are observations until individually verified,not silently counted as passes.
1223default/470LLVM local checks pass. Fourteen originals are freshly exact;
268x4acceptance stays21/15Linux20/14Windows. _pp_test advances120to168list index
stringify,but is NOT fully accepted. No runtime/ABI change or size/speed claim.

## List index stringify follow-up

Source tokenization now distinguishes a bracket literal atom from index brackets,
so normal-list stringify can balance [] along with ()/{} while locating top-level
commas. The earlier blanket bracket-token guard is removed;no matcher changes.
Whole-capture # stringify preserves source even when its text is not a valid
expression,as measured;normal-list mismatched delimiters still reject explicitly.
Sixteen new observations give14exact outputs and2outside-slice boundaries,not
16compatibility passes. Three own runtime programs are byte-exact with Harbour.
1226default/476LLVM checks pass fresh locally.14originals are freshly exact;
268x4acceptance stays21/15Linux20/14Windows. _pp_test advances168to248unsupported
<x:&> match marker,NOT complete acceptance.1179now checks numeric escape and1196
unbalanced list delimiters;1224positively covers newly supported index lists.
No runtime/ABI/new lexer semantics or size/speed claim.

## Restricted macro marker boundary

128own-source observations for <x:&>,not implementation or runtime evaluation.
Whole-command matches include &name,optional dot and concatenated macro-name
segments,balanced &(expression),and measured bare &/&() forms. Plain identifiers,
&123,index postfix and extra arithmetic do not match the entire command.
Translate may replace a prefix and leave remaining source;that still belongs
to the separately unresolved captured-translation prefix contract. The original
_pp_test uses an intentionally incomplete XTRANS(<x:&>( pattern,so accepting
its definition alone does not establish call matching or complete acceptance.
Any emitted runtime macro operator remains the existing named native limit.

## Directive-template bracket regression and correction

The bracket-source increment301e081 accidentally let optional brackets in a
continued #command template enter string context.23originals then stopped in
hbclass.ch:576before their previous body diagnostics. Unchanged total acceptance
DID NOT mean no regression. The source-literal predicate now explicitly excludes
directive templates;their brackets retain their original pattern/result meaning.
A new continued restricted-list optional-template console fixture matches fresh
Harbour output.23of23affected first diagnostics are restored exactly versus
75176dd. The full comparison versus75176ddhas only4remaining diagnostic advances
(_pp_test,pp,strdelim,vec1),with no accepted/lost originals.13bracket-source phase
checks and12escape stringify checks still pass.1227default/478LLVM checks pass
fresh locally;14reviewed originals remain freshly exact. This corrects a real
regression;earlier baed678must not be described as regression-free.

## Stringify of existing identifier/restricted/wildcard captures

The existing source-span stringify path now admits <!x!>, literal-restricted
<x:alpha,beta>, and rest-of-line <*x*> captures. Normal <"x"> on a wildcard
quotes comma-separated top-level elements, like the existing list marker path;
#<x> still quotes the whole capture. Source spacing and quoted data are retained.
168own probes check matched and preserved nonmatching inputs, optional capture
presence/absence, command/Xcommand/translate/Xtranslate, and wildcard lists with
nested delimiters and empty elements. These are token/content checks, not runtime
programs. Five additional console programs have fresh byte-exact Harbour output.

Original audit changes only four RDD wrappers: their first diagnostic moves from
wildcard stringify to line300 unterminated dotted word. They are NOT accepted;
RDD, static storage and native runtime contracts remain pending. Full acceptance
stays21/15Linux20/14Windows.1232default/488LLVM checks pass freshly locally;
14reviewed originals are freshly exact versus rebuilt Harbour.

Separately recorded96characterization observations expose historical <(x)> gaps:
it is treated as parenthesis-required and strips delimiters, unlike the measured
Harbour captures. Those observations are not compatibility passes, and this
increment does not change that marker or captured translation prefix matching.
Literal-bearing optional stringify and repeated/disjoint captures remain outside
the admitted contract. No classes/runtime/ABI/main change and no speed/size claim.

## Extended marker is not a parenthesis-only marker

Own480plus280black-box observations record a historical <(x)> contract gap.
Harbour accepts unspaced file/expression tokens, quoted data, parenthesized
expressions and macro forms. A parenthesized source retains its delimiters under
<x>, #<x>, and normal <"x">. Result-side <(x)> is smart stringify, not an
instruction to add parentheses: it quotes a filename/bare token, retains a quoted
string or parenthesized expression, and treats macro captures specially. Source
whitespace and top-level commas affect boundaries; captured translations can
replace a prefix. The current parenthesis-only matcher and unconditional
re-parenthesization do not implement that contract. These760observations are
characterization evidence only, not760passes. No implementation is claimed here.
A future correction must preserve token/source identity and separate match-marker
semantics from result-marker semantics, with explicit macro/optional boundaries.

## Smart-result candidate held back after original diagnostic audit

384own smart-result observations are preserved with a reversible candidate patch.
292scoped output checks and4explicit rejection checks pass for that candidate;
its local1240default/504LLVM tests pass. It is deliberately NOT enabled because
3originals move to earlier diagnostics: classch on repeated/disjoint captures,
_pp_test and pp on smart macro captures. Those are regressions, not progress.
Production remains1232default/488LLVM from5a7223e; this evidence commit does not
change compiler semantics. Candidate fixtures, results and exact diagnostic deltas
are under smart-result-candidate-20261031. Resolving preprocessing macro smart
results does not authorize or require a native runtime macro evaluator.

## Scoped smart result corrected after contract classification

Result-side <(x)> on existing plain/list/identifier/restricted/wildcard captures
now quotes bare source, preserves quoted/parenthesized expressions, handles list
items separately, and emits no bytes for an absent capture. It stages generated
data before other marker substitution. Textual smart macro forms &name[.] and
&(expression) lose their leading ampersand as measured; this is preprocessing,
NOT a new runtime evaluator. Macro-name concatenations and postfixes are quoted
as measured. Escape smart captures stay explicitly outside this slice.

The previous implementation emitted false source:123became(123)instead of"123";
&namebecame(&name)instead ofname. Six console fixtures have fresh exact Harbour
output.404scoped pp checks are exact plus1explicit escape rejection. Existing
extended <(x)> match-marker behavior is NOT corrected here; its historical
parenthesis-only branch remains separately documented.

The initial inactive candidate's two macro diagnostic regressions are resolved.
The final268x4audit changes only classch:330to21. This is a deliberate earlier
rejection of previously incorrect repeated smart-result output, NOT a regression
on a correctly translated program. Own minimal comma-repeat Harbour output is
OUT("alpha","beta","gamma");previous output wasOUT((alpha),(beta gamma));new
output is an explicit repeated/disjoint-capture error. A whitespace repeat also
previously fused values incorrectly. Contract comparison is preserved in
smart-result-20261031/contract-classification.json. The classch original is still
NOT accepted. A correct repeated result needs per-iteration capture groups and
result expansion,not a concatenated capture vector;that representation/matcher
change is not included. No fallback preserves known-false output.

Fresh local batteries1240default/504LLVM and14originals exact. Acceptance stays
21/15Linux20/14Windows. No classes/runtime/ABI/main change, no speed/size claim.
The earlier candidate patch/results are historical, not the final implementation.

## Repeated result groups: representation gap measured separately

280own-source observations in repeated-smart-gap-20261031 show that repeated
matching and result groups are coupled. A result group repeats its full template,
including separators; a non-grouped marker does not grant repeated whole-command
matching. Current capture concatenation erases this information. Literal-bearing
optional groups also have a historical tail-overcapture gap,documented with
Harbour/previous/current outputs. This evidence commit does not implement or
claim repeated compatibility;production compiler remains284d009.

## Smart-result guard correction after repeated-case audit

284d009did NOT correctly cover repeated smart results. Repeated restricted
captures could still be fused and literal-bearing optional groups could swallow
a later iteration into a plain tail. New fail-closed guards apply only while
rendering smart <(x)>: a restricted capture longer than any literal alternative
is rejected; a captured marker inside an optional group whose literal occurs
again in the source is rejected conservatively. This is NOT a repeated matcher
implementation or a complete detection of every overcapture form. A repeated
literal can cause a deliberate conservative rejection in this slice.

Six boundary controls retain correct single iterations,multiword restricted
choices,absent optionals and unrelated literal optionals.410pp outputs match
Harbour and3scope rejections pass.1242default/508LLVM checks pass locally.
Full268x4audit differs from284d009only in classch error text at the SAME line21;
there is no new phase regression or acceptance change.14original exact checks
were freshly run before the final guard narrowing;remote final checks follow.

Plain # and normal stringify share the pre-existing matcher debt;they have NOT
been advertised as repeated compatibility. Their scoped regressions were rerun:
168identifier/restricted/wildcard checks,plain50checks plus measured additions,
and104normal checks pass. These guards do not change their execution paths.
Raw/plain matching may still fuse or overcapture repeated groups,as preserved in
the repeated characterization evidence. No general preprocessor-complete claim.


Independent remote validation ofa4bd444completed:1242default/508LLVM,410exact
pp checks plus3scope rejections,and14reviewed original programs fresh exact
versus Harbour/default/LLVM.268x4audit matches local exactly. Earlier506LLVM
wording was a counting mistake;the final logs contain508PASS lines. This
correction changes evidence text only,not the compiler or its admitted scope.

## Extended matching boundary recheck after smart-result separation

200additional own observations distinguish extended match boundaries from plain
expression capture. With <(x)>,unspaced a+b and file paths match,while a + b,
f(1,2),a[1,2],and braces do not match a whole command in these measured forms.
An initial parenthesized expression retains its parentheses and can include a
following arithmetic tail with spaces. Quoted initial data has a different
boundary. Captured translate can consume only a prefix. The historical t93
negative is correct for spaced1+2without parentheses but its comment claiming
that the marker always REQUIRES parentheses is too broad. No extended matcher
change is included:implementing it as ordinary expression capture would be wrong.

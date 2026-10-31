# Bounded five-rule VAR family admission

Own MIT implementation, pinned Harbour behavioral oracle. Admits exactly one
reduced VAR plus four structural variants:IN,IS,IS...IN,IS...TO. No sixth rule,
unrelated family member,translation or call-form overlap is admitted. Global
literal score and rule order remain unchanged. Correct complete-match boundaries
rather than a priority reversal prevent broad type swallowing an IN variant.

For overlapping families,type is restricted to one non-anchor ASCII identifier
followed by an allowed tail/end. More general expressions explicitly reject.
The isolated reduced VAR expression contract is not silently reused:2500initial
probes found9false translations when it was. Latest10000seeded probes observe
0false translations;7811deduplicated:4380tokenmatches(includesunchanged lines),
3423explicitrejections,8unmatchedgaps. These gaps are not supported syntax.

Two COMMAND definition/removal temporal cases match. Adding a duplicate sixth
rule deliberately excludes the family and retains historical scope guard;
that third temporal control is a fallback classification,not compatibility.
Historical xcommand/uncommand mismatch is unchanged. Existing command-queue
identity/provenance and resource bounds remain. No general suppression heuristic.

Six own runtime witnesses exact Harbour/default/LLVM Linux exit/stdout/stderr.
Sixpositive/twonegative manifest rows added. Local full1300PASS=1295manifest+5aux,
622LLVM PASS.14reviewed unchanged Linux originals exact freshly built Harbour
in both backends.268x4diagnostic audit changes only classch:first old line21pp
scope guard moves to later parser line330unknown dotted word. Accepted totals
stay21/15Linux20/14Windows. This is a pp phase advance,not original compilation,
linking or runtime support. The VAR/AddMultiData fragment is now expanded,but
METHOD/helper output remains wrong. Do not call the whole header correct.

Full Harbour compiler -p preprocessing classch succeeded; standalone hbpp on its
header reported an #if expression error,so its partial output is not a whole-file
oracle. No whole-header equality claim is made. No class runtime,ABI/ownership,
main,globalpriority,debugger,size/speed changes. Independent remote gates pending.

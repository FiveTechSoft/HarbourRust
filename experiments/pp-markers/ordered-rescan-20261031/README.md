# Bounded ordered command rescan

Own MIT implementation; pinned Harbour behavioral oracle. Replaces whole-result
command rescans with ordered work items when expansion emits statement separators.
Process each child to completion before its next sibling. A generated definition
changes only later siblings, never completed earlier siblings. Source path/line
are retained; each work item carries expansion depth and monotonic registered rule
IDs. IDs track provenance, NOT suppression. Self/cycles still reject.

Generated COMMAND/XCOMMAND factory bodies retain existing doubled-separator
boundaries. Generated DEFINE/UNDEF now execute at their queue position, using the
same owned parser as direct definitions. A DEFINE body ends at a separator. Other
generated directives, including INCLUDE and UNCOMMAND, stay explicit scope errors.
This is narrower than Harbour. Call-form translation rescanning remains separate.
Existing global rule selection, overlap guards and direct rule removal unchanged.
No actual hbclass VAR enablement, class semantics or runtime/ABI change.

Limits:16expansion depth,10000work items/queued statements,1MiB per replacement and
per original source-statement emitted payload. Rule IDs allocate on registration,
not vector position, so removal does not recycle provenance IDs. No once-used
suppression heuristic is introduced. Previously rejected naive priority and
immutable-child prototypes remain inactive research history.

1200seeded own sequence cases all token-match Harbour after semicolon/newline
statement-separator normalization (850deduplicated replay cases). Use
check_reduced_var.py --statement-separators --corpus ordered-rescan-20261031/cases.json.gz.
Quoted semicolons remain data. This normalization is only for the pp probe grid;
runtime outputs above are compared byte-exact.
104DEFINE cases:101tokenmatches,3self-definition cases rejected by both with
different error presentation. Eight own runtime witnesses match Harbour/default/
LLVM Linux exact exit/stdout/stderr, including generated DEFINE/UNDEF/function
bodies. Oldt1143 now passes pp then fails parser no-functions, an intentional phase
change supported by those witnesses; not merely a changed rejection expectation.
Three new rejection rows preserve cycle/unsupported INCLUDE/UNCOMMAND boundaries.
22classified exact prior pp deltas are in the preceding research directory:
mostly correct sequence changes/spacing; old comma-fusion gap remains a gap.

Full local gates:1287manifest+5aux=1292defaultPASS;606LLVM PASS. 268originals x4
compile profiles retain exact exits/first diagnostics21/15Linux20/14Windows.
14unchanged reviewed Linux originals exact freshly built Harbour/default/LLVM.
Prior6134/6148/2778replay categories unchanged;410smart+3rejections,80identifier,
16family controls pass. No original unlock,size/speed,main,ownership/debugger or
global-priority claim. Independent remote gates follow publication.

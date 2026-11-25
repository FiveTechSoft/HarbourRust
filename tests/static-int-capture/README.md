# Canonical integer STATIC references in Eval blocks

Own MIT. Ordinary Linux non-macro Eval blocks may use literal-initialized
integer STATIC bindings when every free variable is one of those bindings.
The block prologue materializes each canonical process-storage address.
It never snapshots a static value or retains an owner-frame address.
Integer reads, ++ and output metadata use the existing RefI64 lowering.
AScan/ASort keep their existing read-only owner-frame capture path unchanged.

15 exact triples (3 sources x 5 modes): local persistent counter increment,
module counter with reassignment between Eval calls, local persistent read.
5 named limits: ordinary local capture, mixed local/static capture, returned
block, Windows, float static initializer. No returned/detached blocks, local
cell lifetimes, string capture or global RC support claimed. statics.prg is
still rejected because DetachVar also captures xLocal. This is a component,
not intact-original admission. No full LLVM or performance claim.

Failed attempts are retained: returned-block probes hit the existing return
guard; the initial helper name Run collided with Harbour's command syntax,
so it was renamed VisitCounter; two resource-killed builds produced no
current binary claim. Final evidence must match the fresh successful build.
Black-box oracle https://github.com/harbour/core.git at
694428e1c12f726675b19324d62167fa77d68185.

Capture-boundary diagnostic follow-up: ordinary local/mixed captures now
carry the persistent integer Eval guard name while retaining the historical
capture-error prefix. Nested STATIC references have an explicit environment
boundary before recursive block typing. No new capture admitted. The six
limit fixtures assert these diagnostics, including nested blocks. Linux-only
diagnostic changes are expected in five existing negative fixtures; Windows
stays unchanged. Broad gates on the previous compiler do not imply gates on
this diagnostic follow-up.

# Direct return of canonical integer STATIC blocks

Own MIT. Admit only RETURN of a direct BlockLit already proved by the
persistent integer capture checker. The block value is a process-lifetime
code pointer. Its prologue rebuilds canonical integer STATIC addresses,
so the callee's frame is not retained. Existing return/call code handles
that Copy value; no allocator, runtime, reference count or ABI change.

15 exact triples across five modes: two blocks returned by one factory
share a counter, module rebinding while returned block lives, returned block
passed to another function. Four named limits: ordinary local capture,
mixed static/parameter capture, indirect block-variable return, Windows.
Three strict-zero runs use final cleanup and rc99/DELTA=0.
The earlier integer-capture return-limit fixture now uses an ordinary local,
not the newly admitted direct STATIC return.

No detached xLocal, general closure environment, indirect return provenance,
array block storage, string capture or intact statics.prg closure claimed.
AScan/ASort remain unchanged. Only the checker return gate changes.
Black-box oracle https://github.com/harbour/core.git at
694428e1c12f726675b19324d62167fa77d68185.

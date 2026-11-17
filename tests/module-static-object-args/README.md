# Nullable method string arguments, bounded increment

This increment extends the a1cd4862 STATIC-NIL work. It releases owned
argument casillas when a nullable receiver fails before entering its method.
It does not implement general frame unwind after a method-body throw.
`STATIC o := 0` retagging remains a named rejection.

String-bearing sends require a variable or Self receiver. Input argument
types are integer, logical, date or string. String expressions admit only
variables, literals, checked + / - / * expression trees, and the measured
Space, Upper, Lower and Left builtins with recursively admitted arguments.
Types and arity still pass through the ordinary checker. User function calls
(including fresh()), nested sends/receivers, indexing, division, inline
effects and other builtins are named rejections on this route. Dyn, float
and container input arguments remain rejected. A string may cross into an
existing Dyn parameter as an owned tag4 copy; that is not admission of a Dyn
input. Existing module-owned-string message restrictions also remain.

The arguments evaluate left to right using the ordinary boundary, moved
source slots are nulled, and omitted parameters are padded with NIL. If Self
is null, the caller releases the owned StrOwn and Dyn boundary casillas that
the callee would otherwise own. Borrowed Str casillas are not freed. On a
live receiver, the ordinary callee ownership and virtual dispatch remain.
No string error is substituted for evaluated arguments. The NIL error still
uses the declared description-string catch model, not a Harbour Error object.

`check.py` has 254 assertions, runnable in independent --stage shards:

- memory: 168 assertions, each with an actual and a separate control run.
  Four method parameter shapes (typed string, Dyn destination, three strings,
  and string/logical/integer), seven sources, live/null, N1/500/1000.
  Both sides must reach the strict DELTA guard with exact stdout and delta2,
  the measured object-pool control, not a zero-leak claim.
- oracle: 56 fresh Harbour / Linux / Wine comparisons. The oracle source
  translates TRY/CATCH into BEGIN SEQUENCE with ErrorBlock/Break. Expected
  call/catch counts prove the method entered only on live receivers. Windows
  expected bytes use the target's CRLF contract. This translation does not
  claim equivalence of Harbour Error objects and compiler description strings.
- negative: 30 real compiler rejections, all with Harbour-valid sources.
  They cover fresh calls, later throwing arguments, nested sends, indexing,
  Dyn/float input, duplicate moved locals, constructor receiver chains and an
  unmeasured builtin. Both NIL/live source forms are checked.

A control contains the same send under `if .f.` so inference sees exactly
the same omitted parameters and string copies, without executing the call.
This is a pool/loop control, not a synthetic fake-object pointer. Local string
sources are refreshed after each move before the next iteration.

Two native-manifest programs exercise real live multiple-string arguments
and caught nullable-string failure. Their raw Linux/Wine pins are -text.

Pre-fix research has its own explicit provenance: a1cd4862 plus ONLY removal
of the string-admission barrier in a separate research compiler. That bypass
reproduced N500 delta502 versus live2, and exposed an existing inherited
virtual-dispatch flag bug with fresh() arguments (live segfault, null could
throw before evaluating fresh). The production route rejects those forms;
it does not claim the dispatch bug fixed. Separate method-body-throw probes
showed delta4 at N1 and1501 at N500. Those are retained as an open general
frame-unwind limit, not counted among the balanced assertions above.

Reviewer boundary correction: the recursive whitelist checks every variable leaf against its static type, rejecting Dyn even when nested in Left counts, arithmetic, Space counts or later scalar arguments. Typed input alone is not a proof: Dyn arithmetic can return I64 while still throwing during extraction. Five extra negative shapes, each NIL/live, prevent both wrong Left payload and previously marshalled string leaks.

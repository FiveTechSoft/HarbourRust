# Read-only module STATIC floating constants

Original MIT. Ordinary Linux literal float module slots store IEEE bits plus
existing packed width/decimal metadata, loaded fresh through canonical storage.
Read, arithmetic, Str, copies, function arguments/returns, local shadowing and
INIT/Main/EXIT reads are measured. Assignment, increments, inline assignment,
@ borrows and loop counters are explicitly rejected. No mutable float claim.
Local STATIC float and folded1/3 initializer remain rejected. Threads/macros,
Str(Dyn), Windows and LLVM remain outside this route.

40 exact triples across8 sources/five modes, strict-zero3,13 limits,Rust118,
GTSTD88. Four negative diagnostics change (date/effectful/hash text plus
float fixture changed to rejected assignment). Original float fixture is
preserved as former-float-limit.prg and oracle-exact. Census1041/65 admission
unchanged,6 later/updated rejection diagnostics. Original initexit.prg now
reaches PUBLIC/macro+STATIC string rejection, not closed. Fatal divergence OPEN.
First Rust build failed borrow-check; retained. First own folded initializer
fixture rejected; retained and named limit, literal precision tested separately.
No full Linux manifest, performance or independent rebuild claim.

C2 mutation coverage: +=,-=,*= lower to Stmt::Assign and are rejected by
the module read-only guard. /= is rejected during parsing before binding;
%= and ^= are not supported statements and are parser rejections. Nested
codeblock := and ++ reach Expr::Set/Inc through the recursive visitor and
are rejected. Read capture is rejected by the existing integer-only capture
guard. @ passing reaches Expr::ByRef and is rejected. Passing by value to a
callee which assigns its parameter is admitted and oracle-exact: the float
value+metadata is copied and the module slot remains unchanged. A same-name
LOCAL shadows before binding, its assignment remains admitted and exact.
The module1/3 initializer now has its own division-initializer diagnostic.
These paths were inspected at parser Assign lowering, recursive visitors,
module bind shadow handling, and function argument value copying.

Superseded by tests/static-floatstore: float statement assignments now supported,
including +=/-=/*=. Other mutation/capture limits remain. Earlier results above
record the read-only increment, not the current implementation.

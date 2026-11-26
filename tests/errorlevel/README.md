# ErrorLevel ordinary Linux integer status

Original MIT. Harbour core694428e1 oracle: ErrorLevel() initially0, setter
returns prior value and stores signed32; final process status is low8.
Measured negative,258,4294967297, nested setter, EXIT changes, Main and INIT
QUIT. Only zero or one i64 argument, ordinary Linux without threads/macros
or Str(Dyn) contexts. Other types are named compile rejections, not coercion.
Setter argument executes before loading prior state, matching nested calls.
Normal-return cleanup/GTSTD close runs before final status syscall. Actual
nonzero status with completed EXIT hooks prints no fatal-skip notice.

30 exact triples across six sources/five modes,10 limits, strict-zero3,
Rust118, GTSTD88 with ErrorLevel reclassified oracle-exact instead of unsupported.
618 negative Linux/Windows and1041 census/65 admitted are unchanged.
First Rust test build hit timeout60, retained as failure; retry succeeded.
No performance, full Linux manifest or exceptional fatal unwind claim.
Fatal divergence remains OPEN. ErrorLevel is status, not a fatal exception.

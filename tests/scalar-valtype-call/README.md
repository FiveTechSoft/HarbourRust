# ValType user-call I64 and Bool

Original MIT. Increment on73e8a41a. Resolved user calls returning I64 or Bool execute once before yielding N or L. Existing string and F64 paths unchanged. No builtin integer/logical-call blanket admission, no integer arithmetic/logical-expression admission, global RC or numeric-array division.

New integer/logical side effect and ordering, owned and literal string arguments, nested forward returns:25 exact triples across five modes. Exception5 exact with explicit TRY-to-SEQUENCE oracle adapter. Intact t4145 exact and migrated manifest neg to pos2 with byte-copied oracle output. Strict-zero4 probes (instrumented assembly exit99 and DELTA0). Raw logs provided separately.

STATIC module string probes belong to73e8a41a supplements; global ownership not claimed. Mixed Len(string inside ValType,array outside) remains rejected though Harbour admits. Negative differential before manifest migration618 sources changes only t414.

C2 correction on aad0e144: pos2 requires two paths in tools/run_native_manifest.rs. Added Windows expected bytes by LF-to-CRLF adaptation, not Windows runtime or Harbour/Windows evidence. Targeted native runner verified on Linux. Post-migration negative runner reads live617 neg rows, t414 excluded. Full manifest/performance/FullLLVM still not claimed; float115, F64call35 separate C2 comparison only.

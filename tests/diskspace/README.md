# hb_DiskSpace bounded typed-string Linux profile

Own MIT statfs helper fitted to external Harbour executable probes and Linux
ABI. Typed string literal/variable path, literal selector0..3 only. Values:
0=bavail*bsize,1=bfree*bsize,2=(blocks-bfree)*bsize,3=blocks*bsize. Result F64,
decimals0,width10 below1e10,width20 otherwise. Path copied to NUL-terminated
buffer, max4095bytes; syscall failure returns0. No borrowed pointer escapes.
Only ordinary Linux without threads/macros. Extra/dynamic selectors,Dyn path,
computed temporary path,other platforms excluded. No general RC model change.

check.py45controlled triples =9snapshots x5Linuxmodes; external Harbour's
statvfs interposed, native helper single statfs syscall replaced with fields.
Includes failure,0,bsize!=frsize,selector formulas,1e10width edge and large
magnitudes. This is injected snapshot exactness, not changing live disk exact.
live.py24stable tmpfs/failure rows (oracle+5modes). limits.py10rejections.
Initial snapshot failed at width metadata, corrected with raw failure kept.

Does NOT close intact diskspac.prg. Its first Empty-computed-argv limit and
hb_DirBase/Dyn consumers remain. Signed-range synthetic fields only; unsigned
huge statfs counters and arithmetic overflow outside corpus unverified.

# Isolated reduced VAR flags

Own MIT implementation. Pinned Harbour is only a behavioral oracle.
Extends the bounded reduced VAR topology with up to six independent optional
single restricted-marker groups. Anchors remain disjoint, including their
four-letter abbreviation prefixes. Flags keep their own owner/iteration/source
spans; they do not fuse into comma identifiers, type or initializer captures.
Both logical presence and grouped source spelling are covered.

No flags semantics are evaluated here. EXPORTED/PROTECTED/HIDDEN simultaneously
can be captured, not validated as legal class scope. Real hbclass scope helpers,
rule overlap, rescan, class runtime and global priority remain separate. The
real header still does NOT use this isolated path due to family overlap.

2778 deduplicated own probes from3000seeded cases:2628tokenmatches(includes
unchanged lines),150explicitrejections,0false translations observed. Not a
completeness proof or2778supported programs. Replay with check_reduced_var.py
--corpus var-flags-20261031/cases.json.gz and hbpp/hpp/output-dir.
Prior6134and6148grids retain exact categories;410smart+3explicit rejections,
80identifier16family controls pass. Three command temporal controls exact.
17plan units pass. Same1024iteration/64expression-depth limits.

Six own runtime programs exact Harbour/default/LLVM Linux exit/stdout/stderr.
Nine manifest rows added:6positive,2scope errors,1parser rejection. Repeated flag
with an ungrouped logical result is correctly left untranslated by both pp
implementations (t1277); it is NOT a positive runtime case. First fixture used a
trailing directive semicolon that swallowed PROCEDURE in both implementations;
fixed the fixture instead of changing the pp continuation contract.
Local+independent remote full gates:1276manifest+5aux=1281defaultPASS,584LLVM PASS. All268originals x4
first diagnostics/exit identical (21/15Linux20/14Windows);14reviewed unchanged
Linux console originals freshly exact in Harbour/default/LLVM. No original
unlock,size/speed,main,runtime/ABI/ownership/debugger change. Independent remote
2778replay,diagnostic audit,14originals and full gates verified. Historical xcommand removal mismatch remains.

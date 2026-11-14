# Read-only NTX support (proposed hito 2)

This increment adds an own MIT NTX reader. It does not link Harbour's RDD or VM,
copy its implementation, or evaluate the stored index expression.

## Supported subset

Linux x86-64 ordinary assembly backend, one read-only DBF area and one existing
NTX index. The index expression must name one C field directly, with the same
key width as that field (1-255 bytes). Ascending, nonunique, unconditional,
standard NTX only. All physical DBF records, including deleted records, must
appear exactly once; keys must match the snapshot's field bytes and be ordered
by key then record number. NTX and workspace allocations are each bounded to
64 MiB. Validation is eager: opening scans the tree and builds a flat key-order
view. Open costs O(records); later seek is O(log records). This is a bounded
snapshot reader, not a general RDD or a write-capable B-tree.

```harbour
function Main()
   dbUseArea(.T., "DBFNTX", "customers.dbf", "CUSTOMERS", .F., .T.)
   ? OrdListAdd("names.ntx")
   ? dbSeek("SMITH"), Found(), RecNo(), FieldGet(1)
   dbGoBottom()
   dbSkip(-1)
   OrdListClear()
   dbCloseArea()
return nil
```

Calls added: `OrdListAdd(filename)` returns a logical, `OrdListClear()` returns
NIL, `dbGoBottom()` returns NIL, `dbSeek(key [, softSeek [, findLast]])` returns
a logical, and `Found()` returns a logical. Existing top/skip calls follow the
index while open. `RecNo()` remains the physical DBF record number; `LastRec()`
remains the DBF count. Clear keeps the current physical record and Found flag;
subsequent skip uses physical order. Top/bottom/skip clear Found, including
skip(0). Close/reopen releases both snapshots. Implicit program exit, runtime
rejection and C bridge fatal errors also close the index.

Character seek uses byte prefixes, truncating queries longer than key width.
Duplicates choose first or last according to findLast. On a miss, ordinary seek
positions at EOF. Softseek chooses the next key, or the previous key when
findLast is true; if there is none in that direction, it positions at EOF.
An empty query matches all keys in a nonempty index. Queries must be statically
typed strings (borrowed or owned); dynamic string cells are rejected at compile
time. Optional flags must be logical. Missing filename extensions gain `.ntx`.
A second open index is rejected; clear it before opening another.

## Explicit exclusions

Unique, descending, conditional/custom/partial indexes, calculated or compound
expressions, numeric/date/logical keys, shared locking, writes, scopes,
collation/codepage conversion, multiple orders, Windows and LLVM. Unsupported
headers, DBF/index mismatches, cycles, repeated records/pages, overlapping
entries, invalid page/slot bounds or uneven leaf depth fail closed. Only the
standard 0x0006 signature is admitted; no broad compatibility claim is made for
other NTX variants. Files must be quiescent during snapshot reads, as for DBF.

No scalar tag or object layout changes are part of this increment. All existing
DBF limits in [DBF-READONLY.md](DBF-READONLY.md) still apply.

## Reproduce

Build hbc from this source and independently build Harbour at reference pin
`694428e1c12f726675b19324d62167fa77d68185`, then:

```sh
python3 tests/ntx/check_oracle.py \
  --compiler ./hbc \
  --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 \
  --output /tmp/ntx-oracle-evidence
```

The output directory must be new. This builds fixtures using Harbour only,
then compares six same-source programs in normal and instrumented modes:
12 paired stdout/stderr/exit-status executions. Tests cover 250 records with
71 distinct keys, duplicate and prefix searches, 288 seek flag combinations,
empty tables, full forward/backward traversal, owned query lifetime,
clear/reopen, and a 255-byte-key tree spanning 130 data pages. Fixture builders
are not evidence of HarbourRust write support.

For 255-byte field output, tests use OutStd rather than QOut. Harbour GTSTD's
screen wrapping changes long QOut lines, while HarbourRust writes raw output;
that existing DBF/output difference is not fixed by this index increment.

The paired gate is not the full manifest, negative, sanitizer, C bridge or
resource-lifetime test suite. Development evidence is reviewed separately.

## Format references

- https://clicketyclick.dk/databases/xbase/format/ntx.html
- https://pic.hallikainen.org/techref/language/dbase/ndxs.htm

Some published descriptions disagree with generated files or Harbour return
values. Generated fixtures and real Harbour executions determine admitted
behavior. No Harbour implementation source is used to implement this reader.

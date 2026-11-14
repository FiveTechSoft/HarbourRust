# Read-only CDX support (hito 3)

HarbourRust adds an own MIT reader for a bounded, observed Harbour-produced
compound CDX format. No Harbour RDD implementation, VM or RTL is linked, copied
or translated. This is not general DBFCDX compatibility.

## Admitted subset

Linux x86-64 ordinary assembly backend. One read-only dBASE III area and one
explicitly opened, nonstructural compound CDX containing exactly one tag. The
tag must be ascending, nonunique and unconditional, over one direct C field
of width 1-240 bytes. Every physical DBF record, including deleted records,
must appear once, with a key matching that field's bytes. No expression is
evaluated from the index file.

```harbour
request DBFCDX
function Main()
   dbUseArea(.T., "DBFCDX", "customers.dbf", "CUSTOMERS", .F., .T.)
   ? OrdListAdd("names.cdx")
   ? dbSeek("SMITH"), Found(), RecNo(), FieldGet(1)
   dbGoBottom()
   dbSkip(-1)
   OrdListClear()
   dbCloseArea()
return nil
```

`REQUEST DBFCDX` declares an incorporated driver. It does not link external
modules. It also lets this source link the corresponding driver in a real
Harbour oracle build. Other nonlocal module requests remain unsupported.
`dbUseArea` still requires six explicit arguments and shared=.F., readonly=.T.;
DBFNTX remains available with its existing limits. The selected driver chooses
which index format OrdListAdd accepts. A missing filename extension gains
`.cdx` for DBFCDX or `.ntx` for DBFNTX.

Use a CDX basename different from the DBF basename, and open it explicitly.
The reader conservatively compares basenames case-insensitively even across
different directories; a matching basename is rejected before file opening.
Structural DBFs (DBF byte28 set) and automatic index opening are outside this
increment and rejected. Multiple tags are rejected, never silently reduced to
one tag. Clear the current index before opening another.

## Behavior and validation

The call surface is the same as the NTX increment: OrdListAdd returns a logical,
OrdListClear and dbGoBottom return NIL; dbSeek and Found return logical values.
Top/bottom/skip follow index order; RecNo remains physical and LastRec remains
the DBF count. Prefix and duplicate-key seeks, softseek and findLast follow
real Harbour DBFCDX behavior. Query strings must be statically typed (borrowed
or owned); optional flags must be logical. Dynamic string queries are rejected.

One measured driver difference is preserved: seeking an empty CDX index leaves
BOF=.F., EOF=.T.; NTX leaves BOF=.T., EOF=.T. Top/bottom on an empty index leave
both flags true. Found, clear/reopen and copied-value lifetimes are tested.

CDX uses 512-byte pages, including files whose total size is 512 modulo1024.
NTX retains its 1024-byte page requirement. CDX leaf prefix/trailing-space
compression is decoded with bounded masks and bit counts. The decoder checks
page bounds, root attributes, unique page/record visits, uniform leaf depth,
sibling links, internal separator maxima, free-space accounting, complete
record coverage, sorted key/record order, and every reconstructed key against
the owned DBF snapshot. It rejects stale or unsupported files before exposing
an index cursor.

Opening eagerly builds a key-order vector: O(records) open and O(log records)
seek. Vector entries refer to character bytes in the DBF snapshot, so no
separate persistent decoded-string store is needed. Index snapshots are at
most64MiB; the entry vector is at most64MiB plus validation bitmaps. DBF and
index snapshots are released on close, reopen, implicit program exit and
supported error paths. Files must be quiescent while read; no locking or
concurrent-writer consistency guarantee is made.

## Explicit exclusions

- Character fields wider than240 are rejected with `CDX direct character key
  field width must be <=240`. Real Harbour truncates wider character keys;
  this increment does not accept that partial-field comparison silently.
- Structural/autoopened indexes, multiple tags/orders, calculated/compound
  expressions, noncharacter keys, unique/descending/conditional/custom/partial
  tags, scopes, writes, shared locking, collation or codepage conversion.
- Windows and LLVM CDX support. Existing DBF and NTX limits still apply.
- Header variants beyond the measured standard compact/compound headers and
  observed marker/signature are not claimed compatible.

No scalar tag or object layout changes are part of this increment.

## Reproduce the same-source gate

Build hbc from this source and separately build official Harbour at reference
pin `694428e1c12f726675b19324d62167fa77d68185`. On Linux x86-64 with Python3 and
GNU binutils:

```sh
python3 tests/cdx/check_oracle.py \
  --compiler ./hbc \
  --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 \
  --output /tmp/cdx-oracle-evidence
```

The output directory must be new. Fixture builders run only under Harbour;
this does not imply HarbourRust write support. Seven identical `.prg` programs
are compiled under both compilers, with hbc normal and instrumented modes:
14 paired stdout/stderr/exit-status checks. Coverage includes duplicates,
prefix/soft/findLast (288 combinations), empty, forward/backward traversal,
owned query/value lifetimes, C240 keys, and a deeper 20,000-record tree with a
file length not divisible by1024. Assembly is compressed and intermediate
executables/objects are removed as each case finishes to limit disk use.

This gate is separate from the full regression manifest, negative/fault tests,
C bridge checks, resource tracing and sanitizer tests.

## Format sources

- Microsoft compound format:
  https://learn.microsoft.com/en-us/previous-versions/visualstudio/foxpro/k35b9hs2(v=vs.80)?redirectedfrom=MSDN
- Microsoft compact header/internal/leaf layout:
  https://learn.microsoft.com/en-us/previous-versions/s8tb8f47(v=vs.90)
- Public xbase layout mirror:
  http://www.manmrk.net/tutorials/database/xbase/cdx.html

Generated fixtures and executions with real Harbour decide admitted behavior
when older descriptions are incomplete. No Harbour RDD code is used.

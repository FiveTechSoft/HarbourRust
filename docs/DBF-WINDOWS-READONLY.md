# Windows PE read-only DBF/NTX/CDX adapter

This adds Windows x86-64 ordinary native PE support to the existing own-code
read-only snapshot reader. It does not link Harbour's RDD, VM or RTL. This is
not general DBFCDX compatibility. Runtime evidence is under Wine 11, not native
Windows certification. No guarantee is made that a particular customer DBF
such as M_CLIE.DBF falls within the supported on-disk subset.

## Same admitted subset, not a new RDD

One workarea, six explicit DBUSEAREA arguments, literal DBFNTX/DBFCDX and
literal shared and readonly flags; readonly=.F. retains the exclusive
handle with GENERIC_READ|GENERIC_WRITE (Harbour's exclusive contract), while
field writes remain outside the subset. shared=.T. is admitted only with
readonly=.T. (see "Shared read-only opens" below). Existing C/N/L/D dBASE III rules,
scalar-consumer limits and size limits stay in force.
See [D1](DBF-WRITE-OPEN-D1.md). NTX and CDX must be opened explicitly
with OrdListAdd. CDX is one ascending, nonunique, unconditional tag over one
direct C field of 1..240 bytes, with complete matching physical-record coverage.
See [DBF](DBF-READONLY.md), [NTX](NTX-READONLY.md) and [CDX](CDX-READONLY.md).
No writes, memo fields, shared RDD locking, indexes on shared opens,
structural CDX on writable opens,
multitag/scopes/expressions/codepage conversion, LLVM or Mach-O DBF support.

Static arguments, APIs, driver and shared/readonly restrictions fail at
compile-time. Literal filename lexical restrictions also fail at compile-time;
computed strings receive the same checks at runtime before file opening.
Actual DBF flags/format, CDX tags/layout and DBF/index consistency can only be
checked at runtime. Unsupported content is rejected before exposing a cursor,
not silently truncated or reduced to a supported tag. No compile-time claim
is made for runtime file contents.

## Shared read-only opens

`dbUseArea(..., .T. /*shared*/, .T. /*readonly*/)` opens the table with
GENERIC_READ and FILE_SHARE_READ|FILE_SHARE_WRITE, so hbc can read a table
that a running application keeps open shared. Measured against real Harbour
3.2 on native Windows (`tests/dbf/shared-readonly`, two processes):

- beside a Harbour shared read-write holder, hbc opens and reads the same
  records as a Harbour shared reader;
- while hbc holds the table, a Harbour shared read-write open appends and a
  Harbour exclusive open is refused (NetErr), as with a Harbour reader;
- a Harbour exclusive holder refuses the open (win32 error 32).

Registered differences:

- hbc snapshots the table at open. Records appended by another process
  after that are not seen (Harbour's `LastRec()` grows from 3 to 4 in the
  gate; hbc's stays 3). A writer that appends while the snapshot is being
  read can make the open fail with a size or format error; it is not
  silently truncated.
- On a sharing violation Harbour sets `NetErr()` and the program continues;
  hbc aborts at the open with the Win32 error. `NetErr()` is not supported.
- No index is admitted on a shared open. Harbour reads index files under
  its index lock protocol while writers update them; hbc does not implement
  that protocol. The structural `.cdx` is not opened, and `dbSetOrder(n>=1)`,
  `dbSeek` and `ordListAdd` fail with an explicit message.
- shared=.T. with readonly=.F. is a compile-time error (shared writes need
  record and file locks).

On Linux there are no share modes: a shared open is the same O_RDONLY
snapshot, and the same index and NetErr restrictions apply. The
Linux side is not measured against Harbour by this gate.

## Windows path contract

ASCII only, ordinary relative or drive-absolute paths, maximum 259 bytes before
the terminator. Both '/' and '\' are accepted. Forward slashes are normalised
to backslashes before CreateFileW; basename/extension scans treat both as
separators. Embedded NUL, non-ASCII, controls/wildcards, UNC, device/namespace
paths, drive-relative paths, rooted-without-drive paths, overlong names and
trailing-dot/space component ambiguities are rejected. No automatic long-path
prefixing, ACP guessing or UTF-8 conversion. Files still need to exist and be
readable under the OS path-length/access rules.

A DBFCDX open also opens the structural bag `<dir>/<base>.cdx` when that file
exists, as Harbour does (see [CDX](CDX-READONLY.md)). An index path is the
structural bag when it names the table's path with another extension,
compared ASCII case-insensitively with `/` and `\` as one separator. The same
basename in another directory is an ordinary bag.

## Handles, snapshots and cleanup

CreateFileW uses GENERIC_READ, OPEN_EXISTING and shareMode 0. Handles remain
exclusive until dbCloseArea or OrdListClear for an index. This lifetime was
measured against a fresh official Harbour PE shared=.F./readonly=.T. oracle
under Wine. DBF and CDX are still separate acquisitions; no atomic multi-file
snapshot, network-filesystem consistency or RDD locking protocol is promised.
Use offline/quiescent files.

GetFileSizeEx bounds the private VirtualAlloc snapshot. ReadFile loops accept
short reads, reject premature EOF/error and verify an extra byte/final size.
Equal-sized rewrites are not generally detected. CDX/NTX add bounded entry
and validation-bitmaps storage. Index storage closes before its borrowed DBF
snapshot. Explicit close/reopen, program exit and supported fatal paths release
resources. A failed VirtualFree retains ownership for an explicit retry;
CloseHandle failure is reported as unknown/unreleased and is not blindly
retried. This is not a promise that every OS failure is recoverable.

## Build and tests

Users do not need MinGW or a C compiler. A developer-only
`tests/generate_windows_asm.py` builds the checked-in Windows blob; select the
cross GCC with HR_MINGW_CC. `generated/windows-recipe.json` records compiler,
flags and transitive own-source hashes. Windows C uses Win64 internally;
explicit wrappers translate the compiler helper ABI, its aggregate return and
its sole string-copy callback. The callback preserves Win64 rdi/rsi and
xmm6..15, and supplies shadow space/alignment. Only named kernel32 imports and
the internal hbc_strcpy dependency are allowed. No CRT or __chkstk dependency.

`tests/windows-dbf/check_oracle.py --help` lists the external compiler,
Harbour hbmk2, cross-toolchain, Wine and new-output-directory inputs.
Fresh Harbour pin 694428e1c12f726675b19324d62167fa77d68185 builds the fixture
writers and runtime oracles as PE; actual execution is under Wine 11. Normal
and instrumented modes cover 21 same-source DBF/NTX/CDX programs (42 pairs).
Both outputs have CRLF normalised for comparison: hbc's existing '?' path uses
LF while hb_eol() on Windows returns CRLF. Raw channels remain available;
this is not an unnormalised byte-exact Windows output claim.

Additional gates in tests/windows-dbf cover 41 path cases, 26 pre-cursor/static
rejections, a native-PE ABI canary, a 100-cycle/3000 FieldGet probe ending in
explicit hb_memcheck() 0, native-PE API-accounted stress/implicit/fatal
cleanup, and a real-Windows-API C harness with 200 cycles plus
short-read/fault seams and handles 0/snapshots 0. Existing Linux DBF/NTX/CDX
oracle gates also pass, and regenerated Linux assembly is unchanged. Full
manifest: ELF 1736/1736; PE/Wine 1715/1736 with 21 unchanged CurDir/classes platform
rejections, not a blanket all-green PE or native-Windows claim.

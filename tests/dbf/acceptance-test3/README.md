# Acceptance: Antonio's test3.prg (verbatim)

`test3.prg` here is byte-for-byte Antonio's program (Windows, G:\HARBOUR4):

- `DBUSEAREA(.T.,"DBFCDX","M_CLIE.DBF","CLIE",.F.,.F.)` (exclusive
  read-write open; sixth argument readonly=.F.),
- `? CLIENTE` (bare field-name access),
- `DBCLOSEAREA()`.

It MUST NOT be modified to pass.

## Anonymized fixture (D1.1)

`M_CLIE.DBF` + `M_CLIE.cdx` here reproduce the exact STRUCTURE of
Antonio's production file with 100% synthetic data: version 0x03, 51
fields (31 C, 15 N, 5 D), 13 records, 11508 bytes, rlen 757, header byte
28 = 0x01 (production-index flag) with the accompanying CDX (tags
CLIENTE / NOMBRE / DESCEND(SALDO)). D1 rejected the real file solely for
that flag; D1.1 accepts and preserves header flag bytes 14/15/28/29. Per
Antonio's instruction (2026-11-16) the real production file is never
published: company names, RFCs, addresses, contacts, credentials and all
amounts here are invented; only the field structure and the opaque
sequential CLIENTE codes are preserved.

Acceptance (recalibrated 2026-11-16): test3 must print `000033` - the
CLIENTE field (C(6) code) of record 1. Verified byte-exact against
official Harbour opening this anonymized fixture with its CDX
auto-opened, and earlier against the real production file under the same
procedure (both print `000033`).

The same-source Harbour oracle lane cannot run test3 verbatim (Harbour
needs `REQUEST DBFCDX`); oracle equivalence on this fixture is covered
by tests/dbf/programs/mclie-real.prg (fixture mclie_real.dbf copied from
this M_CLIE.DBF). The final acceptance run is Antonio's, on native
Windows, with his real file.

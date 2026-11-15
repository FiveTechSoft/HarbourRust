# Date helper hardening2.6

Seven helper suffixes join ASM_RESERVED: dtos, stod, year, date_add, date_diff,
date_days, date_from_days. Their user-function spellings now fail with a named
reserved error instead of colliding at assembly/runtime. No valid program's
observable output changes. hbc_dtos empty output remains exactly8spaces but
writes only its8byte payload, not an extra8bytes into allocator slack.

check.py: fresh Harbour694428e gtstd exact output, Linux/PE normal/instrumented,
post-owner hb_memcheck0 wrappers, Mach-O emission,7 named collision rejections.
Fixture deliberately calls CToD("") to activate the existing DATE_PORT_HELPERS
emission gate. That pre-existing gate omits the new standalone SToD/DToS/Year
calls; it is a real separate bug, intentionally NOT fixed in this micro.
Year's direct QOut display width differs today; hb_ntos verifies numeric value
without silently calling display-width behavior fixed.

guard.py: native encoder test extracts emitted hbc_dtos and stubs allocation
to return exactly8writable bytes before an inaccessible Linux page. Empty
output must be8spaces without SIGSEGV. No Windows guard-page claim.

Limits: helper-name safety and bounded empty store only. No new date admission,
calendar semantics or helper-emission gating change. Existing standalone-date
emission bug and Year display-width discrepancy remain explicit. Native Mac
execution not available; Mach-O is emission only. No speed claim.

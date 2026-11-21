# hb_SToD, ordinary Linux

Own existing MIT SToD helper is reused after measuring hb_SToD against the
external Harbour executable. Exactly one typed string argument. First8bytes
are parsed as YYYYMMDD;short/invalid dates are empty. Extra trailing bytes
are ignored. Year0 and the calendar validation follow the measured date
helper,not a new parser. No new runtime helper or date arithmetic change.
Input borrows and owned temporaries are released after conversion.

Only new hb_SToD spelling is limited to ordinary Linux,no threads or
macro/PRIVATE/PUBLIC contexts. Existing SToD paths keep prior admission.
Dyn,missing/nonstring and extra args remain named build limits even though
the oracle returns empty dates for missing/nonstring and ignores extra args.

18own sources36exact int/ext pairs,including11550date-grid inputs per mode,
short,long,NUL,year0,leapcenturies,temporary,param,effect once andthrow.
6memory modes100warmup+10000calls,int/ext,total exact anddelta0.
13named build limits,no rejected binary run.3Rust-valid functional variants
of the shared SToD emission,measured through new hb_SToD calls,build compiler/
program0,run0 and differ in stdout from exact oracle controls.4proxies separate.
Original dates2 is compile-only,never run;next rejection Set is reported
separately. No external body copied into product/tests,no standalone claim.

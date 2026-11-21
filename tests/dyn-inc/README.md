# Dyn integer expression increment/decrement

Own MIT implementation, Harbour is external executable oracle only.

Adds prefix/postfix ++/-- to ordinary local Dyn integer cells on ordinary
Linux. Guards exact integer tags0/9 before any store. Result is I64. Postfix
preserves old integer display metadata; prefix and updated slot clear it.
No owner is freed/changed on kind error. Existing typed integer emission is
unchanged. Existing I64 overflow limit remains a named noncatchable limit;
Harbour can promote at extremes, this increment does not add that behavior.

Float Dyn is a named catchable runtime limit (oracle increments floats);
NIL/logical/string kind errors match oracle and leave their slot unchanged.
No silent coercion. PRIVATE/PUBLIC/macro/thread contexts,static/shared and
byref Dyn storage are rejected at build. Static rejection may occur earlier
through the existing persistent-storage guard.

19positive sources38int/ext exact oracle pairs. cases.json includes an
additional NIL guard source used only by mutants.py,not the positive gate.
catch.py:12bad-kind sources24oracle-exact pairs plus4F64 sources8named runtime
limit controls,not oracle parity. All test TRY syntax adapted only in oracle.
safety.py:9modes of100warmup+10000measured attempts,string/float errors and
integer writes,zero allocation delta,CATCH variable explicitly declared.
limits.py:11storage/context limits with oracle controls plus4profile limits.
3Rust-valid mutants must build/run0 and differ from oracle-equal controls;
4proxies test fail-closed behavior,not product mutants.
originals.py includes pinned occurs.prg unchanged through an own driver and
checks Occurs count and fox_At positions1/2/3. No external body copied.
Census scratch1041:oneLinux diagnostic changes from Inc Dyn to no-main,
zero acceptance changes. This is a library-driver success,not a newly accepted
standalone program.

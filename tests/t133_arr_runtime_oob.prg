// DIVERGE-FAILMODE: runtime out-of-bounds. Harbour opens an interactive error dialog and HANGS (probes a1/a2, timeout even with stdin EOF) - no oracle bytes. Ours prints the Harbour wording and exits 1. Same error condition, different failure mode.
function main()
local a := {10, 20}
? a[1]
local i := 5
a[i] := 1
return nil

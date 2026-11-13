// MODEL: array assignment COPIES (Rust [i64; N] is Copy - rustc-verified). Harbour shares a reference: there ? a[1] prints 99 (probe a3). Ours prints 10.
function main()
local a := {10, 20, 30}
local b := a
b[1] := 99
? a[1]
? b[1]
return nil

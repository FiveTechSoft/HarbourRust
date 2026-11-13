// t492 (neg): `==` on a STATIC array stays a named rejection - Harbour
// compares references, our static arrays are frame copies (D5/D7).
function main()
    local a := {1, 2}
    if a == a
        ? 1
    endif
return nil

// byte-wise string ordering: prefix rule, first-differing-byte rule,
// empty string, byte values (Z = 0x5A sorts before a = 0x61)
function main()
    local a := "abc"
    local b := "abd"
    local c := "abcd"
    if a < b
        ? "lt1"
    endif
    if a < c
        ? "lt2"
    endif
    if b > a
        ? "gt1"
    endif
    if c > a
        ? "gt2"
    endif
    if "" < a
        ? "lt3"
    endif
    if a <= "abc"
        ? "le1"
    endif
    if a >= "abc"
        ? "ge1"
    endif
    if "Z" < "a"
        ? "bytewise"
    endif
    if "b" > "abc"
        ? "gt3"
    endif
    if b < a
        ? "no"
    endif
    ? "fin"
return nil

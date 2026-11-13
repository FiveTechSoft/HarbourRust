// string comparisons work since iterations 9 (=, <>) and 10 (ordering,
// byte-wise like memcmp: no collation, uppercase bytes sort before
// lowercase)
function main()
    local a := "abc"
    if a < "abd"
        ? "lt"
    endif
return nil

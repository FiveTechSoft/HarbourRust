// ordering comparisons on strings are not in the PoC: only = and <>
// (semantic change in iteration 9: = and <> on strings now work)
function main()
    local a := "x"
    if a < "x"
        ? "lt"
    endif
return nil

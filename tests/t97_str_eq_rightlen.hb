// Harbour default (SET EXACT OFF) equality matrix (probe b23): `=`
// compares over the RIGHT operand's length; <> is its negation.
// SET EXACT and Harbour's `==` are not in this grammar.
function main()
    if "abcd" = "abc"
        ? "eqA"
    endif
    if "abc" = "abcd"
        ? "noB"
    endif
    if "abc" = "abc"
        ? "eqC"
    endif
    if "" = "abc"
        ? "noD"
    endif
    if "abc" = ""
        ? "eqE"
    endif
    if "abc" <> "abd"
        ? "neF"
    endif
    if "abcd" <> "abc"
        ? "noG"
    endif
    if "abc" <> "abcd"
        ? "neH"
    endif
    return nil

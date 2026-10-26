// t607: logical assignment and logical variables as conditions
function main()
    local f := .F.
    f := .T.
    if f
        ? "si"
    endif
    if .NOT. f
        ? "no"
    else
        ? "no2"
    endif
return nil

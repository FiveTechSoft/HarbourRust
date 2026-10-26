// AAdd on the middle with a variable: SHARE or copy in Harbour?
function main()
    local a := {{{1, 2}}}
    local b := {7, 8}
    AAdd(a[1], b)
    b[1] := 99
    ? a[1][2][1]
return nil

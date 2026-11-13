// ASize on the middle level of a three-level array: what grows?
function main()
    local a := {{{1, 2}}}
    ASize(a[1], 3)
    ? len(a)
    ? len(a[1])
    ? len(a[1][1])
    ? a[1][2]
return nil

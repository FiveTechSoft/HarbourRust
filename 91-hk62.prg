// exit inside a depth-3 loop
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        if x = 2
            exit
        endif
        ? x
    next
    ? "fin"
return nil

// moving the root away inside the loop (a call moves DArr3 parameters) is rejected.
function consume(b)
return len(b[1][1])
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        ? consume(a)
    next
return nil

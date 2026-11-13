// t488: exit inside the inner of two nested middle loops (oracle hk122).
// Only the first inner element is written; the outer loop still completes
// both its iterations. Adapted input: locals initialised.
function main()
    local a := Array(2, 2, 2, 2)
    local x := 0
    local y := 0
    for each x in a[1, 2]
        for each y in a[1, 1]
            y[1] := 5
            exit
        next
        x[1] := 6
    next
    ? a[1, 1, 1, 1]
    ? a[1, 1, 2, 1]
    ? a[1, 2, 1, 1]
    ? a[1, 2, 2, 1]
return nil

// t486: nested FOR EACH over two middle arrays of the same four-level root
// (oracle hk120). Inner y over a[1,1] writes 4, outer x over a[1,2] writes 3;
// a[2,1,1,1] stays NIL. Adapted input: locals initialised (bare `local x, y`
// is outside the subset).
function main()
    local a := Array(2, 2, 2, 2)
    local x := 0
    local y := 0
    for each x in a[1, 2]
        for each y in a[1, 1]
            y[1] := 4
        next
        x[1] := 3
    next
    ? a[1, 1, 1, 1]
    ? a[1, 2, 1, 1]
    ? a[2, 1, 1, 1]
return nil

// t487: the FOR EACH middle borrow aliases the root's casillas (oracle hk121).
// x[1] := 8 through the loop variable is visible immediately reading
// a[1,2,1,1] directly, persists into the next iteration's element, and the
// untouched branch a[1,1,1,1] stays NIL. Adapted input: local x := 0.
function main()
    local a := Array(2, 2, 2, 2)
    local x := 0
    for each x in a[1, 2]
        x[1] := 8
        ? a[1, 2, 1, 1]
    next
    ? a[1, 2, 2, 1]
    ? a[1, 1, 1, 1]
return nil

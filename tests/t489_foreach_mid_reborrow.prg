// t489: a second FOR EACH over the same middle re-borrows it after the
// first loop ends and sees the writes (oracle hk123). Adapted input:
// local x := 0.
function main()
    local a := Array(2, 2, 2, 2)
    local x := 0
    for each x in a[1, 2]
        x[1] := 7
    next
    for each x in a[1, 2]
        ? x[1]
    next
return nil

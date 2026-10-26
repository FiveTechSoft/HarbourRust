// the loop variable REUSES a visible integer slot (oracle hk323 /
// exit.prg: Harbour does not shadow here; the outer variable counts)
function main()
    local i := 9
    for i := 1 to 2
        ? i
    next
return nil


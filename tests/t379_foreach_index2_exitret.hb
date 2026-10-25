// exit and return inside a loop over a borrowed depth-3 child: nothing owned, balance 0 (hk62).
function reco()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        if x = 2
            exit
        endif
    next
    for each x in a[2][1]
        if x = 4
            return 1
        endif
    next
return 0
function main()
    ? reco()
    ? hb_memcheck()
return nil

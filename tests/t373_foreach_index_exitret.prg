// exit and return inside a loop over a borrowed subarray: nothing owned by the loop, balance 0.
function reco()
    local a := {{1, 2}, {3, 4}}
    local x := 0
    for each x in a[1]
        if x = 2
            exit
        endif
    next
    for each x in a[2]
        if x = 4
            return 1
        endif
    next
return 0
function main()
    ? reco()
    ? hb_memcheck()
return nil

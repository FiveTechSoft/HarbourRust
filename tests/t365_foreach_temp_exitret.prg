// exit and return inside a loop over a temporary: the epilogue frees it on both paths (oracles hk55/hk56).
function mk()
    local a := {}
    AAdd(a, "b")
    AAdd(a, "a")
return a
function reco()
    local c := ""
    for each c in mk()
        if c = "a"
            exit
        endif
    next
    for each c in mk()
        if c = "a"
            return 1
        endif
    next
return 0
function main()
    ? reco()
    ? hb_memcheck()
return nil

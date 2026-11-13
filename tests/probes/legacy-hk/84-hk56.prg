procedure main()
    ? reco()
    ? "fin"
return
function reco()
    local c := ""
    for each c in hb_HKeys({"b" => 20, "a" => 10})
        if c = "a"
            return "ret-" + c
        endif
    next
return "sin-ret"

// loop var vs string: Harbour compares byte-wise (hk33) / errors BASE/1071 on numbers (hk34) - pending, named error.
function main()
    local h := {"a" => 1}
    local k := hb_HKeys(h)
    local c := ""
    for each c in k
        if c = "a"
            ? 1
        endif
    next
return nil

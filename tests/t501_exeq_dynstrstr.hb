// t501: `==` between two Dyn string casillas compares CONTENT exactly,
// not cell identity (oracle hk143: nested loops over the same keys
// array - .T./.F./.F./.T.).
function main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c1 := 0
    local c2 := 0
    for each c1 in k
        for each c2 in k
            if c1 == c2
                ? 1
            else
                ? 0
            endif
        next
    next
return nil

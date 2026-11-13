// t500: `==` on a Dyn string casilla (FOR EACH over hb_HKeys) against
// string literals is the EXACT comparison, symmetric (oracle hk141:
// keys iterate b,a - .T./.T./.F./.F.).
function main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c := 0
    for each c in k
        if c == "b"
            ? 1
        else
            ? 0
        endif
        if "b" == c
            ? 1
        else
            ? 0
        endif
    next
return nil

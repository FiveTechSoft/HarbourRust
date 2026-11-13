// loop variable against a string: REAL Harbour byte comparison (oracle hk33) - the old fold is gone.
function main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c := ""
    for each c in k
        if c = "a"
            ? "igual"
        else
            ? "distinta"
        endif
        if c <> "b"
            ? "no-es-b"
        endif
    next
return nil

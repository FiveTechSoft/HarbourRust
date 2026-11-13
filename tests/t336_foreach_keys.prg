// for each over an hb_HKeys string array: string elements, keys array alive after (oracle hk17).
function main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c := ""
    for each c in k
        ? c
    next
    ? len(k)
return nil

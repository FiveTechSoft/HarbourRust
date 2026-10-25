// for each over a hash iterates VALUES in insertion order, NIL casillas iterate as NIL (oracles hk18/hk31).
function main()
    local h := {"b" => 20, "a" => 10, "c" => NIL}
    local v := 0
    for each v in h
        ? v
    next
    ? v
return nil

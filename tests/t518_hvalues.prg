// t518: hb_HValues(h) - NEW array of the value casillas in insertion
// order, independent of the hash (oracle hk153: 3/1/NIL/42/1/99).
function main()
    local h := {"a" => 1, "bb" => NIL, "c" => 42}
    local v := hb_HValues(h)
    ? len(v)
    ? v[1]
    ? v[2]
    ? v[3]
    v[1] := 99
    ? h["a"]
    ? v[1]
return nil

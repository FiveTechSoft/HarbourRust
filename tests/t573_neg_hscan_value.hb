// t573 (neg): hash values are integers or NIL in this increment (a
// string scan value is a named rejection).
function main()
    local h := {"a" => 10}
    ? hb_HScan(h, "a")
return nil

function main()
    local x
    x := Mk()
    ? ValType(x), hb_IsHash(x), hb_IsObject(x)
return nil
function Mk()
    local h := {"a" => 1}
return h

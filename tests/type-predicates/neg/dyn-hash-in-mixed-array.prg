function main()
    local h := {"a" => 1}, a := {h, 1}, x
    ? ValType(a[1]), hb_IsHash(a[1]), hb_IsObject(a[1]), hb_IsNil(a[1])
    x := h
    ? ValType(x), hb_IsHash(x)
    x := NIL
    ? hb_IsHash(x), hb_IsNil(x)
return nil

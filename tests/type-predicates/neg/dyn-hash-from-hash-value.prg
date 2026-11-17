function main()
    local h := {"a" => 1}, a := {"k" => h}, x
    x := a["k"]
    ? ValType(x), hb_IsHash(x), hb_IsObject(x)
    ? ValType(a["k"]), hb_IsHash(a["k"])
return nil

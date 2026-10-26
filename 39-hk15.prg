function main()
local h := {"one" => 1}
local k := hb_HKeys(h)
ASize(k, 3)
AAdd(k, "x")
? len(k)
? k[4]
? k[2]
return nil

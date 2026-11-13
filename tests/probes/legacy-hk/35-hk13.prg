function main()
local h := {"one" => 1, "two" => 2, "tre" => 3}
local k := hb_HKeys(h)
ASize(k, 2)
? len(k)
? k[1]
? k[2]
ASize(k, 4)
? len(k)
? k[3]
return nil

function main()
local h := {"one" => 1}
local k := hb_HKeys(h)
ASize(k, 3)
? len(k)
k[3] := "new"
? k[3]
? len(k)
ASize(k, 5)
? k[4]
ASize(k, 2)
? len(k)
? k[1]
return nil

function main()
local h := {"one" => 1}
local k := hb_HKeys(h)
local c
ASize(k, 3)
for each c in k
    ? c
next
return nil

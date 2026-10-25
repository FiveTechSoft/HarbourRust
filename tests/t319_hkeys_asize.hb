// ASize shrink on the array that hb_HKeys returns (oracle hk13, shrink
// half): keeps the first keys, frees the removed copies, hash untouched.
function main()
local h := {"one" => 1, "two" => 2, "tre" => 3}
local k := hb_HKeys(h)
ASize(k, 2)
? len(k)
? k[1]
? k[2]
? h["two"]
return nil

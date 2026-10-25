// HB-EXACT mirror of oracle hk7: the array returned by hb_HKeys is
// mutable (AAdd grows it, k[i] := s overwrites an element) and the
// source hash is unaffected.
function main()
local h := {"one" => 1, "two" => 2}
local k := hb_HKeys(h)
? len(k)
AAdd(k, "tres")
? len(k)
? k[3]
k[1] := "nueva"
? k[1]
? k[2]
? len(h)
? h["one"]
return nil

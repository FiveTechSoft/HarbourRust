function main()
local h := mk()
? len(h)
? h["a"]
return nil

function mk()
local h := {"a" => 7}
return h

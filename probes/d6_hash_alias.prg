function main()
local h := {"a" => 1}
local h2 := h
h2["a"] := 9
? h["a"]
return nil

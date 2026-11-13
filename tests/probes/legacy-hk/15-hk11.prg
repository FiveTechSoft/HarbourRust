function main()
local h := {"one" => 1}
addkey(h)
? len(h)
? h["two"]
return nil

function addkey(p)
p["two"] := 2
? len(p)
return nil

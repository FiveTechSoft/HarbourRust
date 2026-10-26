function main()
local a := {10, 20, 30}
local h := {"one" => 1}
local k := hb_HKeys(h)
local x, c
for each x in a
    ? x
next
? len(a)
? a[2]
for each c in k
    ? c
next
? len(k)
? k[1]
return nil

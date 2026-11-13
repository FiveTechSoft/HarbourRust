function main()
local a := {5, 6}
local h := {"one" => 1}
local k := hb_HKeys(h)
local x, c
for each x in a
    x := x * 2
next
? a[1]
? a[2]
for each c in k
    c := "changed"
next
? k[1]
return nil

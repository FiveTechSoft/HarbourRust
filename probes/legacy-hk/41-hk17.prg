function main()
local h := {"one" => 1, "two" => 2}
local k, a := hb_HKeys(h)
for each k in a
  ? k
next
return nil

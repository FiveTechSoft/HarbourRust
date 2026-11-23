function main()
local d
d := mk("12.5")
? val(d)
d := mk("  42abc")
? val(d) + 1
d := mk("")
? val(d)
d := mk("-3.75")
? val(d) * 2
return nil

function mk(s)
local r
r := s + ""
return r

function main()
local d
d := mk()
begin sequence
? val(d)
recover
? "recovered"
end sequence
return nil

function mk()
local r := 5
return r

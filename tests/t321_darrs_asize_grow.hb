// ASize GROW on an array of strings: Harbour grows with NIL casillas
// (oracle hk13: k[3] prints NIL). This increment reports a clean error
// instead (registered limitation): exit 1 with a named message.
function main()
local h := {"one" => 1}
local k := hb_HKeys(h)
ASize(k, 3)
return nil

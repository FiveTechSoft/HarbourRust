// Printing grown (NIL) casillas prints NIL (oracle hk13 read); string
// elements print their bytes.
function main()
    local h := {"one" => 1}
    local k := hb_HKeys(h)
    ASize(k, 3)
    ? k[1]
    ? k[2]
    ? k[3]
return nil

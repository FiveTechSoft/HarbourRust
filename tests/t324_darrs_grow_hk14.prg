// HB-EXACT mirror of oracle hk14: ASize grows the key array with NIL
// casillas; overwriting one with a string works; growing again adds
// more NIL; shrinking keeps the first elements.
function main()
    local h := {"one" => 1}
    local k := hb_HKeys(h)
    ASize(k, 3)
    ? len(k)
    k[3] := "new"
    ? k[3]
    ? len(k)
    ASize(k, 5)
    ? k[4]
    ASize(k, 2)
    ? len(k)
    ? k[1]
return nil

// t611: hb_HClone and hb_HValues preserve logical cells (oracle hk207)
function main()
    local h := { "a" => .T., "b" => 1 }
    local c := hb_hclone( h )
    ? c["a"]
    ? valtype( c["a"] )
    local v := hb_hvalues( h )
    ? v[1]
    ? valtype( v[1] )
    ? hb_hscan( h, .T. )
return nil

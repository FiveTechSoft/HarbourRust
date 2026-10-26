// t610: hb_HSetDef with a logical (overwrite on tag difference too) and
// hb_HScan finds a logical value (oracle hk206)
function main()
    local h := { "a" => 1, "b" => 2 }
    ? hb_hsetdef( h, "a", .T. )
    ? hb_hsetdef( h, "z", .T. )
    ? valtype( h["z"] )
    ? hb_hscan( h, .T. )
    ? hb_hscan( h, 1 )
return nil

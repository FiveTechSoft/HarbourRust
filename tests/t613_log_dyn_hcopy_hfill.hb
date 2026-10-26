// t613: hb_HCopy (source first) copies logical cells and hb_HFill fills
// with a logical (oracle hk208e)
function main()
    local d := { "x" => 9 }
    local s := { "y" => .T. }
    hb_hcopy( s, d )
    ? d["y"]
    ? valtype( d["y"] )
    ? d["x"]
    hb_hfill( d, .F. )
    ? d["x"]
    ? d["y"]
    ? valtype( d["x"] )
return nil

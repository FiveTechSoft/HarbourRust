// t513: ordering between two Dyn string casillas is byte-wise over the
// right operand's length (oracle hk148: nested FOR EACH over the keys
// of {"a"=>1,"bb"=>2} - <: .F./.T./.F./.F., >: .F./.F./.T./.F.,
// <=: .T./.T./.F./.T., >=: .T./.F./.T./.T.). Before this fix the
// Dyn x Dyn ordering path clean-exited on any non-integer casilla.
function main()
    local h := {"a" => 1, "bb" => 2}
    local k := hb_HKeys(h)
    local c1 := 0
    local c2 := 0
    for each c1 in k
        for each c2 in k
            if c1 < c2
                ? 1
            else
                ? 0
            endif
        next
    next
    for each c1 in k
        for each c2 in k
            if c1 > c2
                ? 1
            else
                ? 0
            endif
        next
    next
    for each c1 in k
        for each c2 in k
            if c1 <= c2
                ? 1
            else
                ? 0
            endif
        next
    next
    for each c1 in k
        for each c2 in k
            if c1 >= c2
                ? 1
            else
                ? 0
            endif
        next
    next
return nil

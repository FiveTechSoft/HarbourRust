// t510: `=` between two Dyn string casillas compares CONTENT with
// Harbour's prefix rule over the right operand's length, `#`/`<>` is its
// negation (the dialect spells it `<>`; the oracle used `#`) (oracle hk145: nested loops over the same keys array of
// {"a"=>1,"bb"=>2} - .T./.F./.F./.T. then .F./.F.). Before this fix
// hbc_dyn_eq answered .T. for any two string casillas by tag alone.
function main()
    local h := {"a" => 1, "bb" => 2}
    local k := hb_HKeys(h)
    local c1 := 0
    local c2 := 0
    for each c1 in k
        for each c2 in k
            if c1 = c2
                ? 1
            else
                ? 0
            endif
        next
    next
    for each c1 in k
        if c1 <> c1
            ? 1
        else
            ? 0
        endif
    next
return nil

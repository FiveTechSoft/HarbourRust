// t614: alloc/free balance with logical casillas (tag 3) - mixed literal,
// AAdd growth, hash writes, HClone, HValues, HCopy and HFill are all owned
// by work() and freed at its epilogue; the balance must return to 0.
function work()
    local a := { .T., .F., 1 }
    aadd( a, .T. )
    a[1] := .F.
    local h := { "a" => .T., "b" => 1 }
    local c := hb_hclone( h )
    local v := hb_hvalues( h )
    hb_hcopy( c, h )
    hb_hfill( h, .F. )
    return len(a) + len(v)
function main()
    local x := work()
    x := work()
    ? hb_memcheck()
    return nil

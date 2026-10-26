// t542: hb_HPos with an OWNED key temporary (function-returned
// string): the lookup borrows it and it is freed right after hbc_hpos
// returns (wrap + memcheck = 0, own ownership check, same pattern as
// t298/t533/t535; not a Harbour oracle).
function kf()
    return "bb"
function wrap()
    local h := {"a" => 1, "bb" => 2}
    ? hb_HPos(h, kf())
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil

// len(p) alone would pin a flat dynamic array; the string-key read pins
// a hash. The two merge to the hash pin (len of a hash is its pair
// count, oracle hk11) - order-independent, so the len first is fine.
function f(p)
    ? len(p)
    ? p["k"]
return 0
function main()
    local h := {"k" => 7, "z" => 8}
    local r := f(h)
return nil

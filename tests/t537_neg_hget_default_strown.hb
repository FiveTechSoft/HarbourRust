// t537: an owning string temporary (function-returned string) as the
// default is rejected in this increment - explicit rejection, so no
// owned temporary is ever silently discarded or leaked by the default
// slot.
function sf()
    return "x"
function main()
    local h := {"a" => 1}
    ? hb_HGet(h, "a", sf())
return nil

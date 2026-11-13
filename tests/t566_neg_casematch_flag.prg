// t566: hb_HSetCaseMatch's flag must be an integer in this increment
// (named rejection; the dialect has no logical type).
function main()
    local h := {"a" => 1}
    hb_HSetCaseMatch(h, "x")
return nil

// t565: hb_HSetCaseMatch's first argument must be a hash variable
// (named rejection).
function main()
    local x := 5
    hb_HSetCaseMatch(x, 0)
return nil

// t567: hb_HCaseMatch's argument must be a hash variable, not a
// subscript (named rejection).
function main()
    local h := {"a" => 1}
    ? hb_HCaseMatch(h[1])
return nil

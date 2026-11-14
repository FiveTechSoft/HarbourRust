// t556: hb_HCaseMatch default 1; hb_HSetCaseMatch(h, 0) makes EXISTING
// keys match case-insensitively (read and HasKey); back to 1 restores
// byte-exact matching (oracle hk169). hb_HCaseMatch keeps its numeric
// 1/0 flag surface; hb_HHasKey renders .T./.F. as a logical.
function main()
    local h := {"a" => 1}
    ? hb_HCaseMatch(h)
    hb_HSetCaseMatch(h, 0)
    ? hb_HCaseMatch(h)
    ? hb_HHasKey(h, "A")
    ? h["A"]
    hb_HSetCaseMatch(h, 1)
    ? hb_HHasKey(h, "A")
return nil

// t556: hb_HCaseMatch default 1; hb_HSetCaseMatch(h, 0) makes EXISTING
// keys match case-insensitively (read and HasKey); back to 1 restores
// byte-exact matching (oracle hk169; getter printed as 1/0 - the
// dialect has no logical type, boolean rendering family registered).
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

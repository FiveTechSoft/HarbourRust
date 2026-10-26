// t560: hb_HClone propagates the CaseMatch flag: the clone reads a
// case variant of its own key (oracle hk173).
function main()
    local h := {"a" => 1}
    hb_HSetCaseMatch(h, 0)
    local c := hb_HClone(h)
    ? hb_HCaseMatch(c)
    ? c["A"]
return nil

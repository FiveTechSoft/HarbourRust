// t562: hb_HMerge obeys the DESTINATION's flag: an insensitive dst
// overwrites "a" with the source value and keeps its own key casing;
// a SENSITIVE dst inserts the source's case variant as a new entry even
// when the SOURCE is insensitive (oracle hk175).
function main()
    local d1 := {"a" => 1}
    local s1 := {"A" => 2}
    local d2 := {"B" => 4}
    local s2 := {"b" => 3}
    local ks := hb_HKeys(d1)
    hb_HSetCaseMatch(d1, 0)
    hb_HMerge(d1, s1)
    ? len(d1)
    ks := hb_HKeys(d1)
    ? ks[1]
    ? d1["a"]
    hb_HSetCaseMatch(s2, 0)
    hb_HMerge(d2, s2)
    ? len(d2)
return nil

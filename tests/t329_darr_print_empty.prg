// HB-EXACT mirror of oracles hk20/hk22/hk24: whole dynamic arrays
// (numeric flat, string-key array from hb_HKeys) print NOTHING.
function main()
    local a := {1, 2}
    local h := {"b" => 1, "a" => 2}
    local k := hb_HKeys(h)
    ? a
    ? a, 7
    ? k
    ? k, 9
    return nil

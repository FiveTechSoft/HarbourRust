// HB-EXACT mirror of oracles hk23/hk25: printing a whole hash or
// array BORROWS it (len still works afterwards); a string element in
// last position is space-trimmed at the line end.
function main()
    local h := {"ab  " => 1, "cd" => 2}
    local a := {10, 20}
    local k := hb_HKeys(h)
    ? h
    ? len(h)
    ? a
    ? len(a)
    ? k[1]
    ? k[2], k[1]
    return nil

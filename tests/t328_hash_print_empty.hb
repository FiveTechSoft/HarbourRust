// HB-EXACT mirror of oracles hk16/hk20/hk21: a whole hash prints
// NOTHING; separators between items are still emitted; trailing
// empty items (with their separators) vanish at the line end.
function main()
    local h := {"one" => 1}
    ? h
    ? h, 5
    ? 5, h
    ? h, h
    ? 5, h, 6
    ? "x", h, "y"
    return nil

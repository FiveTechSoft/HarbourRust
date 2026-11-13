// HB-EXACT mirror of oracles hk22/hk24: QOut space-trims the END of
// the line; interior spacing is preserved exactly. Applies to string
// literals and variables alike.
function main()
    local x := "ab  "
    ? "ab  "
    ? "ab  ", 5
    ? x
    ? x, 3
    return nil

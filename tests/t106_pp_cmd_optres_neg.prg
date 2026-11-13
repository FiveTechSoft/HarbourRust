// negative: a kept bracket whose unbound marker is individually removed can
// leave broken syntax; Harbour rejects it too (probe b36c, E0030).
#command HALF <x> [AND <y>] => ? <x> [+ <x> + <y>]
function main()
    HALF 5
    return nil

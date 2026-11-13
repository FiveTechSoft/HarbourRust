// pos (63r, flipped from neg "printing alone cannot pin"): printing alone
// pins a parameter to the tagged union (oracles hk257/hk259; exact-case
// oracle hk263 for this body: prints x, returns 0). Byte output and exit
// match Harbour.
function show(s)
    ? s
    return 0

function main()
    ? show("x")
    return nil

// Varying argument types across call sites merge the parameter to the
// tagged union; hb_PValue exposes each call's own value (multiarg family).
function q(x)
    ? hb_PValue(1)
    return nil
function main()
    q(11)
    q("xy")
    q(.f.)
    return nil

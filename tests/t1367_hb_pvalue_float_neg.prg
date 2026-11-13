// neg: hb_PValue cannot expose a float parameter - Dyn has no float
// payload tag in this increment (multiarg's own blocker, registered).
function p(k, s, f)
    ? hb_PValue(1), hb_PValue(2), hb_PValue(3)
    return nil
function main()
    p(5, "abc", 2.5)
    return nil

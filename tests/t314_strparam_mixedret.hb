// A function returning its owned string parameter on one path and a
// string literal on another unifies to an owned return: the literal
// return point emits a copy, the caller owns (and frees) every result.
function pick(x, s)
    if s = "none"
        return "fallback"
    endif
    if x >= 1
        return s
    endif
return "fallback"
function wrap()
    local h := {=>}
    h["x"] := 5
    local k := hb_HKeys(h)
    ? pick(1, k[1])
    ? pick(0, "none")
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil

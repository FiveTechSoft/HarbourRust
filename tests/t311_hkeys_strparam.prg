// An owned string (a copy read out of an hb_HKeys result) moves into a
// string parameter; the callee prints it (a borrow) and returns it (the
// ownership moves back). The caller uses it as a hash key (a borrow).
function echo(s)
    if s = "x"
        ? s
    endif
return s
function wrap()
    local h := {=>}
    h["x"] := 5
    local k := hb_HKeys(h)
    local r := echo(k[1])
    ? r
    ? h[r]
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil

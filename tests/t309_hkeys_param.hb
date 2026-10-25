// An array of strings passed as a parameter MOVES (single owner); the
// callee owns it, mutates it and returns it; the caller reassigns the
// result. Harbour instead SHARES the array (oracle hk8: the callee's
// mutation is visible without any return) - the registered deliberate
// difference (pr2/pr5 family), pending the user's contract decision.
function grow(p)
    AAdd(p, "two")
    p[1] := "changed"
    ? p[1]
return p
function wrap()
    local h := {=>}
    h["one"] := 1
    local k := hb_HKeys(h)
    k := grow(k)
    ? len(k)
    ? k[1]
    ? k[2]
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil

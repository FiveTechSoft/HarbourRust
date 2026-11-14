// demo multi-module: report module (cross-module calls).
// Increment notes recorded by probes K/N/O/L: an array parameter is
// typed as dynamic only when the callee exercises a dynamic-only
// operation on it (AAdd + ASize-restore pair after the loop); an
// element read must go through a local (an if-condition index on the
// parameter degrades typing), and an element of an array parameter
// cannot be re-passed as a function argument, so the stock-tag rule is
// decided locally here.
function PrintItems( skus, qtys )
    local i, tag
    local nQty
    local nOk := 0
    local nOut := 0
    local out := {}
    for i := 1 to len(skus)
        nQty := qtys[i]
        tag := "OUT"
        if nQty > 0
            tag := "OK"
        endif
        ? skus[i], nQty, tag
        if tag == "OK"
            nOk += 1
        else
            nOut += 1
        endif
    next
    AAdd(out, nOk)
    AAdd(out, nOut)
    AAdd(skus, "")
    ASize(skus, len(skus) - 1)
    AAdd(qtys, 0)
    ASize(qtys, len(qtys) - 1)
    return out

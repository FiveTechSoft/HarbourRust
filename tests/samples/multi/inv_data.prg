// demo multi-module: data module (seed + helpers with STATIC state)
// Bounds in this increment: hash values are tagged scalars (integer,
// logical or NIL), AAdd grows with one element kind per array, and an
// array parameter is typed as dynamic only when the callee exercises a
// dynamic-only operation on it (the ASize no-op pin below).
function SeedSkus()
    local skus := {}
    AAdd(skus, "A-100")
    AAdd(skus, "B-220")
    AAdd(skus, "C-305")
    return skus

function SeedQtys()
    local qtys := {}
    AAdd(qtys, 12)
    AAdd(qtys, 7)
    AAdd(qtys, 0)
    return qtys

// static local storage persists across calls (per function)
function NextId()
    static nId := 0
    nId += 1
    return nId

// STATIC FUNCTION: file-private helper (module-private while the
// modules are separate files; the concatenated build shares one unit)
static function StockTag( nQty )
    if nQty > 0
        return "OK"
    endif
    return "OUT"

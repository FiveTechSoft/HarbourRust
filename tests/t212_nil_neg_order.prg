// negative: ordering NIL is a Harbour type error (no headless oracle); this
// PoC rejects it at compile time instead of comparing the sentinel.
function main()
if NIL < 1
   ? "bad"
endif
return nil

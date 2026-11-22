// A Dyn/NumLocal argument (other than a NIL literal) is outside the
// oracle's static-type coverage: named rejection, never a panic.
PROCEDURE Main()
   LOCAL x
   LOCAL r := hb_ATokens("a b", x)
   ? Len(r)
   RETURN

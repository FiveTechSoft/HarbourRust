// Oracle row D_1644: plain ATokens does not exist in Harbour 3.2.0
// (runtime "Undefined function"). HarbourRust has no such builtin:
// the equivalent guarantee is this COMPILE-TIME named rejection.
PROCEDURE Main()
   LOCAL r := ATokens("a b")
   ? Len(r)
   RETURN

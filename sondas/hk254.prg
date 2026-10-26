PROCEDURE Main()
   LOCAL s := { "a", "bb", "ccc" }
   LOCAL n := { { 1, 2 }, { 3, 4 } }
   LOCAL h := { 1, { 2, 3 } }
   ? LEN( s )
   ? s[1] + s[2] + s[3]
   ? LEN( n ), LEN( n[1] ), n[2][1] + n[1][2]
   ? LEN( h ), VALTYPE( h[1] ), VALTYPE( h[2] )
   RETURN

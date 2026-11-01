// Contract A1 body-pin case (reviewer): the body pins a and b to I64
// (arithmetic a+1), the omitted call sites flip them to Dyn via nil_ev
// - the I64 guard must not fire before the merge. Expected values from
// the reference oracle run of THIS source.
PROCEDURE Main()
   F( , 2 )
   F( 1, )
   F( , )
   F( 1, 2 )
RETURN
FUNCTION F( a, b )
   ? iif( ValType( a ) = "U", -1, a + 1 )
   ? iif( ValType( b ) = "U", -1, b + 1 )
RETURN NIL

// Inline assignment as a call argument (parexpr contract A2): Expr::Set
// only, integer. Arguments evaluate LEFT TO RIGHT, each exactly once.
// Part 1 = oracle probe p4 of the args proposal with hb_DefaultValue
// replaced by plain addition (A3: no builtin defaults in fixtures);
// expected 34 / 22 exactly as oracle run4. Part 2 adapts p4's byref
// order check without STATIC/strings: three byref calls evaluate
// left-to-right once each (6, n=3).
PROCEDURE Main()
   LOCAL x := 0, n := 0
   ? F( x := 1, x := x + 10, x := x * 2 ), x
   ? G( @n ) + G( @n ) + G( @n ), n
RETURN
FUNCTION F( a, b, c )
RETURN a + b + c
FUNCTION G( v )
   v := v + 1
RETURN v

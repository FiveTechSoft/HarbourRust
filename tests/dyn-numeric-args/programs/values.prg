// Numeric builtins with a Dyn operand (a float or integer held in a Dyn slot) and arithmetic with a Dyn operand as their argument. Independent fixture.
function Ok( x )
return x
function Id( x )
return x
function Boom()
 Break( "expected" )
return 3
function Main()
 local a, b, c, z, n, s, big, m, r
 a := Ok( 1.5 )
 b := Ok( 7 )
 c := Ok( -2.75 )
 z := Ok( 0 )
 n := NIL
 s := Ok( "x" )
 big := Ok( 9007199254740993 )
 m := Ok( -9 )
 ? "str-plain", Str( a ), Str( a, 8, 2 ), Str( c ), Str( b ), Str( z )
 ? "str-sum", Str( a + 1 ), Str( a - b ), Str( a * 2, 6, 1 ), Str( c * c )
 ? "str-int-sum", Str( b + 1 ), Str( b * b ), Str( m - 1 )
 ? "int-plain", Int( a ), Int( c ), Int( b ), Int( z ), Int( m )
 ? "int-big", Str( Int( big ), 20 ), Str( Int( big - 1 ), 20 )
 ? "int-expr", Int( a + 1 ), Int( a * b ), Int( c - 1 ), Int( b + 1 )
 ? "abs-plain", Abs( a ), Abs( c ), Abs( b ), Abs( z ), Abs( m )
 ? "abs-expr", Abs( a - b ), Abs( b - a ), Abs( a * -2 ), Abs( c + 1 ), Abs( m + 1 )
 ? "abs-nested", Str( Abs( a - b ) ), Int( Abs( a - b ) * 2 ), Abs( Abs( c ) - 3 )
 ? "max", Max( a, 2 ), Max( a, b ), Max( 2, a ), Max( c, a )
 ? "max-same", Max( a, a ), Max( b, b ), Max( m, c )
 ? "min", Min( a, 2 ), Min( a, b ), Min( 2, a ), Min( c, a )
 ? "min-same", Min( a, a ), Min( b, b ), Min( m, c )
 ? "max-expr", Max( a + 1, 2 ), Max( a - b, 0 ), Max( 0, a * c ), Max( a + 1, b - 1 )
 ? "min-expr", Min( a - 1, 0 ), Min( a + 1, 2 ), Min( 5, a * 2 ), Min( a + 1, b - 1 )
 ? "max-tie", Max( 2, Ok( 2.5 ) - 0.5 ), Min( 2, Ok( 2.5 ) - 0.5 ), Max( Ok( 2.5 ) - 0.5, 2 ), Min( Ok( 2.5 ) - 0.5, 2 )
 ? "round", Round( a, 0 ), Round( a, 1 ), Round( c, 1 ), Round( b, 2 )
 ? "round-expr", Round( a + 1.26, 1 ), Round( a * 3, 1 )
 ? "sqrt", Sqrt( a ), Sqrt( b ), Sqrt( a * 4 ), Sqrt( z )
 ? "mod", Mod( a, 1 ), Mod( b, 4 ), Mod( a + 1, 2 ), Mod( c, 1 ), Mod( 9, a )
 ? "pct", a % 1, b % 4, b % a, ( a + 1 ) % 2, c % 1
 ? "user-arg", Id( a + 1 ), Id( a - b ), Id( a * b ), Id( b + 1 ), Id( c * 2 )
 ? "user-nested", Str( Id( a + 1 ) ), Ok( a - b ) + 1, Id( Abs( a - b ) )
 ? "sum-of-calls", Abs( a ) + Max( a, b ), Min( a, b ) * 2, Int( a ) + Int( c )
 try
  r := Abs( n )
  ? "not reached"
 catch
  ? "abs-nil-error"
 end
 try
  r := Int( n + 1 )
  ? "not reached"
 catch
  ? "int-nil-sum-error"
 end
 try
  r := Max( a, s )
  ? "not reached"
 catch
  ? "max-string-error"
 end
 try
  r := Min( n, a )
  ? "not reached"
 catch
  ? "min-nil-error"
 end
 ? "a", a, "b", b
return nil

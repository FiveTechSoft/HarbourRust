// Ten-deep reverse call chain: every function calls the next,
// so convergence needs ten monotone rounds (no fixed round cap would
// justify this; termination rests on finite lattice progress).
procedure main()
   ? f1( 1 )
   return
function f1( n )
   return f2( n ) + 1
function f2( n )
   return f3( n ) + 1
function f3( n )
   return f4( n ) + 1
function f4( n )
   return f5( n ) + 1
function f5( n )
   return f6( n ) + 1
function f6( n )
   return f7( n ) + 1
function f7( n )
   return f8( n ) + 1
function f8( n )
   return f9( n ) + 1
function f9( n )
   return f10( n ) + 1
function f10( n )
   return n * 100

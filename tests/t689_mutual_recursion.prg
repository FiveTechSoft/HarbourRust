// Mutual recursion between STATIC functions (oracle hk253): muta(2) = 2.
procedure main()
   ? muta( 2 )
   return
static function muta( n )
   if n <= 0
      return 0
   endif
   return mutb( n - 1 ) + 1
static function mutb( n )
   if n <= 0
      return 0
   endif
   return muta( n - 1 ) + 1

// Forward reference (oracle hk253): Harbour resolves calls to functions
// defined later in the file. Order-independent inference (seeded
// signature table + monotone fixpoint) replaces define-before-use.
procedure main()
   ? early( 3 )
   return
function early( n )
   return n * 10

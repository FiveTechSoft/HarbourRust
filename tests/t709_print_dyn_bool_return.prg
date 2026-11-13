// pos (63s): a logical Dyn parameter through print AND return - the caller
// prints the returned tagged value (oracle hk265: .T. .T. .F. .F., exit 0).
// Scalar tag 3: no ownership transfer; the printed temporary frees only
// tag-4 payloads.
procedure main()
   ? q( .t. )
   ? q( .f. )
   return
function q( x )
   ? x
   return x

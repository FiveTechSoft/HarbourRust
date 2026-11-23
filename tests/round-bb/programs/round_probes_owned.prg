// Owned-path UAF regression (reviewer A): hb_ntos and hb_CStr called
// DIRECTLY on an owned heap-float Dyn temporary (the Id(...) result is
// owned by the caller and released by the callee wrapper). Pre-fix the
// release ran before the value was unpacked.
function Id( v )
return v
function main()
   ? hb_ntos( Id( 0.1 + 0.2 ) )
   ? hb_CStr( Id( 0.1 + 0.2 ) )
   ? hb_ntos( Id( 2.675 ) )
   ? hb_CStr( Id( 2.675 ) )
   ? hb_ntos( Id( 1000000000000000.5 ) )
   ? hb_CStr( Id( 1000000000000000.5 ) )
   return nil

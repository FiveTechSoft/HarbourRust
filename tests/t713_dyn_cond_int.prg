// posx 1 (63t): an integer Dyn cell in condition position is Harbour's
// type error (oracle hk267: dialog hangs headless) - the registered
// clean named exit 1 via hbc_dynlog_error. Before 63t the payload
// leaked through as the branch value (silent divergence).
procedure main()
   p( 0 )
   return
function p( x )
   ? x
   if x
      ? "yes"
   else
      ? "no"
   endif
   return

// posx 1 (63u): an integer Dyn cell as the DO WHILE condition is
// Harbour's type error (oracle hk273: dialog hangs headless) - the
// registered clean named exit 1 via hbc_dynlog_error.
procedure main()
   p( 0 )
   return
function p( x )
   ? x
   do while x
      ? "in"
   enddo
   return

// posx 1 (63t canary): a tag-2 borrowed-string casilla (string-array
// element) in condition position must ALSO hit hbc_dynlog_error - oracle
// hk269: Harbour raises the same type error for a[1] = "abc" (dialog
// hangs headless; registered clean exit 1).
procedure main()
   local a := {}
   aadd( a, "abc" )
   if a[ 1 ]
      ? "yes"
   endif
   return

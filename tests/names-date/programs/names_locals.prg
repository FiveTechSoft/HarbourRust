PROCEDURE Main()
   LOCAL month := 11, str := "local", aSize := { 2, 3 }, Left := 4, Right := 5
   ? month, str, aSize[ 2 ], Left, Right
   month += 1
   ? month, Str( Month( SToD( "20261116" ) ), 2 ), Str( 7, 2 ), Left( "abc", 2 ), Right( "abc", 2 )
RETURN

PROCEDURE Main()
   Probe( 11, "value", 4, 5 )
RETURN
PROCEDURE Probe( month, str, Left, Right )
   month := month + 1
   Left := Left + 2
   Right := Right + 3
   ? month, str, Left, Right, Str( Month( SToD( "20261116" ) ), 2 )
RETURN

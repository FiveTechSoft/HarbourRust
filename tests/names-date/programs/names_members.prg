#include "hbclass.ch"
PROCEDURE Main()
   LOCAL o := NameBox():New()
   ? o:Str(), o:Left( 3 ), o:Right( 4 ), o:Month(), o:aSize( 5 )
   ? Str( 8, 2 ), Left( "abcd", 2 ), Right( "abcd", 2 ), Str( Month( SToD( "20261116" ) ), 2 )
RETURN
CLASS NameBox
   DATA value INIT 11
   METHOD Str()
   METHOD Left( month )
   METHOD Right( str )
   METHOD Month()
   METHOD aSize( Left )
ENDCLASS
METHOD Str() CLASS NameBox
RETURN "member"
METHOD Left( month ) CLASS NameBox
RETURN month + 1
METHOD Right( str ) CLASS NameBox
RETURN str + 2
METHOD Month() CLASS NameBox
RETURN ::value
METHOD aSize( Left ) CLASS NameBox
RETURN Left + 3

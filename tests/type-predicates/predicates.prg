// Type predicates (hb_IsHash, hb_IsObject, ...), hb_Hash() and ValType of
// statically typed hash, object and codeblock variables.
#include "hbclass.ch"
CLASS K
   DATA n INIT 1
ENDCLASS
PROCEDURE Main()
   LOCAL h := { "a" => 1 }, o := K():New(), x, b := {|| 1 }, a := { 1, "s", .T. }, d := Date(), y, o2, l := .T.
   LOCAL hEmpty := hb_Hash()
   ? ValType( h ) == "H", ValType( o ) == "O", ValType( x ) == "U", ValType( b ) == "B", ValType( 1 ) == "H"
   ? ValType( h ), ValType( o ), ValType( b ), ValType( hEmpty ), Len( hEmpty )
   hEmpty[ "k" ] := 7
   ? Len( hEmpty ), hEmpty[ "k" ], hb_IsHash( hEmpty )
   ? ValType( o2 ), hb_IsObject( o2 ), hb_IsNil( o2 )
   o2 := K():New()
   ? ValType( o2 ), hb_IsObject( o2 ), hb_IsNil( o2 )
   x := "s"
   ? ValType( x ) == "C", ValType( a[ 2 ] ) == "C", ValType( a[ 3 ] ) == "L", ValType( h[ "a" ] ) == "N"
   ? hb_IsHash( h ), hb_IsHash( x ), hb_IsHash( y ), hb_IsHash( a[ 1 ] )
   ? hb_IsObject( o ), hb_IsObject( x ), hb_IsObject( h )
   ? hb_IsNil( y ), hb_IsNil( x ), hb_IsNil( h )
   ? hb_IsLogical( l ), hb_IsLogical( a[ 3 ] ), hb_IsLogical( x )
   ? hb_IsDate( d ), hb_IsDate( x ), hb_IsBlock( b ), hb_IsBlock( x ), hb_IsChar( x ), hb_IsChar( 1 )
   IF hb_IsObject( o ) .AND. ! hb_IsHash( a[ 1 ] )
      ? "ok"
   ENDIF
   ? hb_IsChar( "a" ), hb_IsNil( NIL ), hb_IsChar( 3 ), hb_IsDate( Date() )
   Check( 5 )
RETURN

PROCEDURE Check( xValue )
   ? hb_IsHash( xValue ), hb_IsNil( xValue ), hb_IsObject( xValue )
RETURN

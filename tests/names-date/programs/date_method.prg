#include "hbclass.ch"
PROCEDURE Main()
   LOCAL o := DateBox():New()
   ? o:Show( SToD( "20261116" ) )
RETURN
CLASS DateBox
   METHOD Show( d )
ENDCLASS
METHOD Show( d ) CLASS DateBox
RETURN CDow( d )

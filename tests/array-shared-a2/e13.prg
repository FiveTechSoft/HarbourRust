// Arreglo local hacia un parametro sin tipo fijo y elemento de un arreglo
// recibido, bajo excepciones: sin memoria pendiente.
FUNCTION Falla()
   Break( "esperado" )
RETURN 1

FUNCTION Copia( aDatos )
   LOCAL a := IIf( aDatos == NIL, {}, aDatos )
RETURN Len( a )

FUNCTION Largo( c, lFalla )
   IF lFalla
      Break( "esperado" )
   ENDIF
RETURN Len( c )

FUNCTION Total( aNombres, lFalla )
   LOCAL i, n := 0
   FOR i := 1 TO Len( aNombres )
      n += Largo( aNombres[ i ], lFalla .AND. i == 2 )
   NEXT
RETURN n

FUNCTION Agrega( aDatos, xValor )
   AAdd( aDatos, xValor )
RETURN Len( aDatos )

FUNCTION Exercise()
   LOCAL i, a, b, atrapados := 0, total := 0
   FOR i := 1 TO 100
      a := {}
      b := {}
      AAdd( a, i )
      AAdd( b, "uno" + Str( i, 3 ) )
      AAdd( b, "dos" + Str( i, 3 ) )
      total += Copia() + Copia( a ) + Total( b, .F. ) + Agrega( b, "tres" + Str( i, 3 ) )
      TRY
         total += Total( b, .T. )
      CATCH
         atrapados++
      END
      TRY
         total += Agrega( a, Falla() )
      CATCH
         atrapados++
      END
      TRY
         total += Largo( b[ Falla() ], .F. )
      CATCH
         atrapados++
      END
      TRY
         total += Agrega( b, "x" + Str( Falla(), 3 ) )
      CATCH
         atrapados++
      END
      total += Len( a ) + Len( b )
   NEXT
   IF atrapados != 400 .OR. total != 2000
      Break( "resultado inesperado" + Str( atrapados ) + Str( total ) )
   ENDIF
RETURN NIL

FUNCTION Main()
   LOCAL i, baseline
   Exercise()
   baseline := hb_memcheck()
   FOR i := 1 TO 20
      Exercise()
   NEXT
   ? "pending", hb_memcheck() - baseline
RETURN NIL

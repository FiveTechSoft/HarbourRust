# Dyn + Dyn en `+` (suma o concatenacion en tiempo de ejecucion)

Alcance minimo (decidido por el padre, 5:18 PM):
- Dos operandos Dyn con payload string dan un string propio (tag 4).
- Dos enteros (tags 0 y 9) siguen la ruta entera (resultado tag 0).
- Cualquier otra mezcla (string+entero, NIL, logico, array, float, fecha) mantiene el error de
  runtime del oracle (capturable con TRY).
- Ambos operandos se evaluan una vez, izquierda a derecha; la izquierda se copia antes de
  evaluar la derecha. Si la derecha lanza (BREAK/TRY), el snapshot se libera.

Tipado: `a+b` con a, b Dyn se tipa Dyn SOLO si el checker lo marco en un consumidor que ya
acepta un Dyn: item de `?`/`??`, asignacion a una variable Dyn, y cadenas de `+` bajo esos
consumidores. En cualquier otro contexto (for, indices, replicate, substr, left, right,
padl, abs, min, max, int, return, argumento de llamada, comparaciones) se conserva la ruta
numerica antigua y su tipo I64. Motivo: tiparlo Dyn en todas partes rompio esos contextos
(rechazos nuevos y resultados vacios en left/right/padl), medido contra el build base.

No cubierto (limites documentados, sin ocultar):
- float Dyn (`known/float-dyn.prg`: el oracle da 3.0, nosotros ERR; el check falla si algun dia
  coincide silenciosamente). Es el siguiente corte.
- fecha + entero y resta de strings Dyn: rechazo nombrado (`rejects/`).
- `return a+b` con a, b Dyn y paso directo como argumento de llamada: mantienen el
  comportamiento anterior (no marcados).
- `for` con slot Dyn: rechazado como antes.
- La salida de `?` de lineas > ~80 columnas difiere del oracle de forma ajena a este corte.

Gate: `python3 tests/dyn-dyn-plus/check.py --compiler HBC --hbmk2 HBMK2 --tree SHA --output DIR`
- `programs/`: byte exacto contra el oracle (concat, cadenas, swap, enteros, errores mixtos/NIL, orden de evaluacion, BREAK en el segundo operando).
- `context/`: casos de contextos enteros y de cadena, comparados con el oracle.
- `rejects/`: rechazos por nombre.
- Memoria N=1/500/1000 con control (`assign`, `accum` = `s := s+a+b`, `int-add`, errores mixto/NIL, BREAK de la derecha): delta de allocs/frees = 0.

Revision tras revision independiente (dos riesgos, ambos medidos por ejecucion antes de arreglar):
- Una cadena `a+b+1` (Dyn string + entero) dejaba el `a+b` interno como string Dyn propio y el
  `+1` numerico lo convertia sin liberarlo al saltar el error: delta 500 a N=500 (shape
  `chain-int-err`). Ahora un `+` hijo solo queda marcado si el padre es consumidor Dyn
  (Dyn+Dyn marcado o concat string+Dyn); si el padre es numerico, se desmarca.
- La suma entera Dyn+Dyn no comprobaba overflow en funciones con STATIC o parametros por
  referencia (CHECKED_I64): envolvia en silencio. Ahora hace `jo` a `hbc_static_overflow` igual
  que la ruta entera vieja (`static-overflow` del gate).

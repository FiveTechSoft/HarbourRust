# Observador acotado de un elemento recibido

Implementación MIT propia. Harbour sólo se ejecuta como oráculo externo.

La función observadora tiene un único parámetro y exactamente una sentencia:
`RETURN Len(parametro)`. Se activa sólo si hay una llamada directa con un
elemento de un parámetro-array, cuyo índice no menciona el propio array.
La firma completa pasa a vista prestada. Las demás llamadas a esa función
también deben satisfacer la frontera de vista existente. No se crea una unión
general de parámetros ni se admiten cadenas como argumentos completos.

Se conserva la llamada real y su marco de diagnóstico. Los elementos cadena
usan un header de longitud en el marco del caller, sin asignación ni transferencia
de propiedad. Un descriptor hijo usa su header existente. Kind6 es privado de
este observador y nunca entra en el accessor de arrays. Kind7 marca LEN inválido;
el error se produce dentro del callee. El cuerpo exacto impide capturas,
mutaciones, escapes, reenvíos y acceso al contenido del header sintético.
Los métodos, referencias de función y perfiles fuera del Linux ordinario quedan
fuera. El propio caller mantiene todas las restricciones de vista existentes.

`check.py`: 24 fuentes propias y original opcional, cinco modos Linux,
comparación literal de rc/stdout/stderr con Harbour. `safety.py`: rechazos de
alcance y perfiles, y contadores propios de memoria. `errors.py`: errores LEN y
bounds registrados, marcos del callee y recuperación bounds sin pendientes.
LEN conserva su salida fatal registrada, incluso dentro de TRY; no es una
comparación con el diálogo de error de Harbour. `mutants.py`: dos mutantes de
salida incorrecta requieren build0/run0, y un mutante de admisión exige rechazo.
`guard_selftest.py`: cuatro proxies comprueban que el gate falla cerrado;
no son mutantes funcionales del producto.

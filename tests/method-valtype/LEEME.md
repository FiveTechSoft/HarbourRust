# ValType acotado del resultado de un método

Implementación MIT propia. Harbour sólo ejecutable externo.

Forma admitida: función ordinaria con un parámetro y exactamente una sentencia
`RETURN ValType(o:Metodo())`. El método no recibe parámetros explícitos. Se
selecciona su implementación por descriptor real de clase, no por una supuesta
ABI común entre jerarquías. Se conserva la llamada normal al método y sus
marcos, sin cambiar retorno, trace, epílogo ni despacho genérico.

El parámetro del observador es una casilla Dyn de objeto. Cada implementación
seleccionable debe tener resultado lógico tipado, o resultado objeto con todas
sus sentencias RETURN siendo `RETURN Self`. El resultado Self posee la referencia
normal devuelta por el método, que el observador libera tras clasificarla. No se
asigna memoria para la letra del tipo. Se mantienen efectos y estado del método.
El argumento del observador debe ser un objeto variable tipado, instancia directa
o creación directa seguida de método que devuelve Self. Se rechazan factories,
receptores anidados y reenvíos Dyn no tipados.

Los objetos frescos devueltos por métodos quedan fuera: una medición independiente
sin el observador expone un leak heredado de retorno de objeto fresco. Aquí no
se modifica ese Ret. Se conserva la prueba fallida y su control base/final.
No es despacho de mensajes genérico sobre Dyn. Tampoco admite ValType(Send)
fuera del observador exacto, DATA, cadenas/NIL/arrays/enteros devueltos, métodos
con parámetros, función-referencia, métodos observadores, perfiles no Linux
ordinarios, threads, macros, MEMVAR, extensiones ni objetos STATIC de módulo.

`check.py`: 24 fuentes propias y original opcional, cinco modos Linux, comparación
literal rc/stdout/stderr con Harbour. Incluye jerarquías no relacionadas, herencia,
override, slots distintos, efectos, estado del objeto y conservación de dueños.
`safety.py`: límites rechazados y contadores propios de memoria, sin atribuir
esos contadores a Harbour. `errors.py`: bounds registrado en el método, marco del
observador y recuperación sin pendientes. `mutants.py`: dos salidas funcionales
incorrectas con build0/run0, un mutante de memoria instrumentada y uno de rechazo,
separados por tipo. `guard_selftest.py`: cuatro proxies fail-closed, no mutantes
funcionales del producto.

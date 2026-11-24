# LOCAL a[n] declarado como array

MIT propio sobre83b67bfc88f549eec3d0e50176b7c3b6fef25d80. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada ni cambio.diff. Oráculo Harbour fresco. Árbol extraído sin git, commit fuente no verificado; hash hbmk2 incluido.

Sintaxis LOCAL a[n] / a[n,m,...] hasta4 dimensiones, una sola pareja de corchetes, sin inicializador simultáneo. Baja al constructor Array existente mediante nombre interno no colisionable. Reutiliza sus tipos, NIL inicial, evaluación izquierda-derecha, allocation y cleanup sin ABI ni RC nuevo. Dimensiones variables/expresiones/calls conservan el checker Array existente. Cero tamaño admitido. No añade dimensiones chained ni STATIC array declarativo ni almacenamiento de blocks/objetos nuevo.

Gate30:4 fuentes intactas propias por5 modos=20 exactas Harbour;4 balances finales cero;6 límites (dimensión vacía,>4,string,initializer,chained,STATIC). Hasta4 dimensiones, lectura/escritura, dimensión0, variables anteriores en misma declaración, creación repetida en función y orden de dos calls de dimensiones que incrementan @x. Un fixture con función llamada Array se retiró: Harbour no enlaza por símbolo duplicado. No se cuenta como evidencia. Otro intento pasó i%3 como dimensión de parámetro pero su '%' produce tipo float no admitido por Array existente; se sustituyó por parámetro integer simple y no se amplió ese contrato.

Regresión118 suites previas reconciliadas por nombre/SHA donde existe, Rust106,LLVM21 exactas frescas,Linux1177 stdout/golden,PE solo emisión1912PASS/22conocidas/0FAIL,negativos622 mismos18,censo58/1041. Trece diagnósticos avanzan, sin nuevas admisiones ni cierre original. codebl2 pasa la declaración de array y se detiene en MEMVAR. Sin velocidad/RC/objetos/división numérica nuevos. Sin push/publicación/workflows/rebase.

python tests/local-array-declaration/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

C2: dos fixtures de LOCAL array redeclarado dentro de bucle, plano con nested FOR/LOOP/EXIT y array2D junto a longitud0. Criterio propio de balance cero, sin oráculo Harbour adaptado ni afirmación de compatibilidad intacta (Harbour no admite LOCAL tardío). Ambos ya pasan sin modificar compilador. Gate ampliado42:20 exactas Harbour,4 balances cero intactos,6 límites,10 salidas propias de redeclaración por5 modos y2 balances cero propios. Sumas esperadas1065 y2556 calculadas desde las iteraciones, comparadas byte a byte.

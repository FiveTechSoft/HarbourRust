# Delayed ATokens con inicialización demostrada

MIT propio sobre76a2b5e2f341dda99a7bfad53df6967627577b1f. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada/cambio.diff. Harbour upstream es oráculo.

Linux nativo ordinario, LOCAL NIL sin @/captura/inline writes. El slot puede ser DArrS desde declaración si todos sus stores son hb_ATokens(otra variable,separador literal) y cada lectura está dominada por un store. IF propaga inicialización solo si ambas ramas la demuestran; ningún loop la propaga a su suffix porque puede ejecutar cero rondas. TRY/SWITCH que mencionen el local quedan fuera. Checker/layout/emisión usan el mismo predicado puro; slot inicial vacío solo mientras NIL es inobservable, con destructor string-array existente. No es retyping general ni nuevo ownership.

Gate48: cuatro fuentes x cinco modos=20ejecuciones exactas frescas, cuatro balances finales cero,16rechazos de perfil y ocho límites.137/149rondas, tokenización reiterada, ambas ramas, foreach/input vacío y FOR de cero rondas, LOOP/EXIT. Rechaza lectura inicial, lectura posterior a loop potencialmente vacío, rama única, retyping, inline assignment, captura, @ y excepción con estado no probado. Fuente/hash,hbmk2/hash,argv/cwd,rc/stdout/stderr separados.

La combinación Empty(iterador) descubrió omisión de dependencia del blob timestamp: sus calls usan tab y el detector de helpers date buscaba espacio. Se admite ambas grafías en ese detector. Fallo inicial de ensamblado hbc_date_days conservado; la prueba final vuelve a usar Empty y ejecuta los cinco modos, no solo la variante sin Empty. Otra prueba de cero rondas usaba Dyn fuera de foreach como input ATokens y fue rechazada correctamente; fixture ajustado a string tipado. Nada de esos intentos cuenta como PASS.

105suites nativas previas completas conciliadas; Rust104; LLVM21exactas frescas; Linux1177stdout/golden; PE emisión1912PASS/22conocidas/0FAIL; negativos622 con mismos16desajustes; censo57/1041. uc16_gen avanza a cGenCat Dyn usado en '$', línea48. big5_gen conserva el límite del préstamo cLine. Ningún original nuevo cerrado ni afirmación de velocidad/política numérica/RC.

Árbol Harbour extraído sin git, commit no verificado. ORACLE.txt conserva versión/hash hbmk2. Paquete sin binarios/objetos/assembly desechable; sin push/publicación/workflows.

python tests/atokens-delayed/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

## Corrección de redeclaración dentro de loop

El revisor encontró FAIL en e84477b6: el atajo bare_tokens ponía ptr/len a cero sin liberar el array vivo de la ronda previa. Las cuatro fuentes originales declaraban el slot fuera del loop. Reproducción propia previa al fix: redeclare-flow daba stdout correcto y DELTA=3170. Ahora bare_tokens llama hbc_sfree null-safe antes del cero. El slot ya se inicializa a cero en prologue, así que la primera entrada y las siguientes comparten la liberación segura.

Gate ampliado68:20exactas intactas anteriores,10ejecuciones contra harness de reset adaptado,6balances finales cero,24rechazos perfil y8límites. Dos fuentes nuevas: redeclaración mínima3rondas y127rondas anidadas con LOOP/EXIT. Harbour rechaza LOCAL tardío E0004; el harness explícito declara el local arriba y ejecuta a:=NIL en cada entrada. La fuente native conserva LOCAL dentro del loop. Es equivalencia del reset adaptado más balance native, no ejecución intacta de esa sintaxis en Harbour. Ambas fuentes/hashes y comandos quedan separados.

Regresión del fix:106suites nativas completas (incluye gate68), Rust104, LLVM21exactas frescas, Linux1177stdout/golden, PE emisión1912PASS/22conocidas/0FAIL, negativos622 mismos16desajustes y censo57/1041 idéntico. Fallos de Harbour E0004 y balance previo retenidos, no cuentan PASS. No push/publicación/workflows. Investigación Dyn containment pausada sin commit durante esta corrección.

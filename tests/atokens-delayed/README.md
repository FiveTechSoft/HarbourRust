# Delayed ATokens con inicialización demostrada

MIT propio sobre76a2b5e2f341dda99a7bfad53df6967627577b1f. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada/cambio.diff. Harbour upstream es oráculo.

Linux nativo ordinario, LOCAL NIL sin @/captura/inline writes. El slot puede ser DArrS desde declaración si todos sus stores son hb_ATokens(otra variable,separador literal) y cada lectura está dominada por un store. IF propaga inicialización solo si ambas ramas la demuestran; ningún loop la propaga a su suffix porque puede ejecutar cero rondas. TRY/SWITCH que mencionen el local quedan fuera. Checker/layout/emisión usan el mismo predicado puro; slot inicial vacío solo mientras NIL es inobservable, con destructor string-array existente. No es retyping general ni nuevo ownership.

Gate48: cuatro fuentes x cinco modos=20ejecuciones exactas frescas, cuatro balances finales cero,16rechazos de perfil y ocho límites.137/149rondas, tokenización reiterada, ambas ramas, foreach/input vacío y FOR de cero rondas, LOOP/EXIT. Rechaza lectura inicial, lectura posterior a loop potencialmente vacío, rama única, retyping, inline assignment, captura, @ y excepción con estado no probado. Fuente/hash,hbmk2/hash,argv/cwd,rc/stdout/stderr separados.

La combinación Empty(iterador) descubrió omisión de dependencia del blob timestamp: sus calls usan tab y el detector de helpers date buscaba espacio. Se admite ambas grafías en ese detector. Fallo inicial de ensamblado hbc_date_days conservado; la prueba final vuelve a usar Empty y ejecuta los cinco modos, no solo la variante sin Empty. Otra prueba de cero rondas usaba Dyn fuera de foreach como input ATokens y fue rechazada correctamente; fixture ajustado a string tipado. Nada de esos intentos cuenta como PASS.

105suites nativas previas completas conciliadas; Rust104; LLVM21exactas frescas; Linux1177stdout/golden; PE emisión1912PASS/22conocidas/0FAIL; negativos622 con mismos16desajustes; censo57/1041. uc16_gen avanza a cGenCat Dyn usado en '$', línea48. big5_gen conserva el límite del préstamo cLine. Ningún original nuevo cerrado ni afirmación de velocidad/política numérica/RC.

Árbol Harbour extraído sin git, commit no verificado. ORACLE.txt conserva versión/hash hbmk2. Paquete sin binarios/objetos/assembly desechable; sin push/publicación/workflows.

python tests/atokens-delayed/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

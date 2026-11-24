# FOR sobre un LOCAL Dyn existente

MIT propio sobre 94c041e0aad2285b739322db48e084667b7ccd0e. Los programas MIT de Julio Ponce son especificaciones, no implementación copiada. No se usa cambio.diff.

Forma acotada Linux nativo ordinario: FOR con START/TO I64 y LOCAL Dyn visible no-byref, no-static y no capturado por bloques en ninguna parte de la función. El slot sigue Dyn, incluido NIL observable antes del bucle. START se evalúa una vez, luego libera el payload antiguo mediante cg_dyn_free_old y almacena el entero etiquetado. TO se evalúa en cada condición. Compare/NEXT usan payload; NEXT escribe tag entero cero. No se abre retyping global ni se cambia RC.

Se rechazan stores/++/byref/captura del contador en body/TO y reutilización como contador anidado. Se conserva el control overflow de FOR entero existente, sin afirmar nueva paridad de ese extremo. Bounds Dyn/float, parámetros y perfiles windows/macho/macho-arm64/LLVM permanecen fuera. El layout ya reservaba el slot visible, no se añade uno nuevo.

Gate103: nueve fuentes intactas Harbour por cinco modos nativos =45 comparaciones exactas;9 balances estrictos cero;36 rechazos de perfil;12 límites y1 error runtime nativo sin paridad de handlers. Cubre NIL previo/posterior, strings/float owned anteriores, cero iteraciones, descenso, nested distintos, LOOP/EXIT, START lee entero previo, START una vez y TO repetido. Fuentes/hash, hash hbmk2, comandos/cwd y rc/stdout/stderr separados. t793/t795 anteriores se copian intactos y comparan con Harbour. t794 inicialmente NIL se conserva como error runtime rc1 propio, no se afirma equivalencia de handlers por defecto.

Regresión del compilador final:110 suites nativas previas reconciliadas por nombre; Rust104; LLVM21 exactas frescas; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL. Negativos622:19 discrepancias combinadas, antes16. Las3 nuevas son t793/t794/t795, antiguas restricciones de admisión ahora abiertas en Linux; no se ocultan ni se cambia manifiesto. Censo57/1041, sin cierre nuevo. big5_gen avanza de FOR a índice leído Dyn line89; uc16_gen @Dyn sigue aparcado. Sin afirmación nueva de velocidad ni decisión numeric-cell/RC.

Las regresiones intermedias quedan fuera del paquete final; un lote final se interrumpió por tiempo y se retomó solo desde logs PASS completos. Árbol fuente Harbour extraído sin git; commit no verificado. Sin push/publicación/workflows.

Reproducir:
python tests/dyn-for-counter/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

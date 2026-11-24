# hb_StrFormat literal %s / %% acotado

MIT propio sobre6fd8d7a8ee4662851c742ba1afe86c7a2e41a77c. Programas MIT de Julio Ponce solo especificaciones, sin implementación copiada ni cambio.diff. Harbour upstream es oráculo.

Solo Linux nativo ordinario sin threads, macros, blocks ni shared arrays. Formato literal con %s y %% y número exacto de argumentos. Argumentos: variables string/Dyn/entero/lógico, literales string/entero/lógico/NIL, y getter __enumKey activo sin argumentos. No admite formato calculado, flags, anchos, otros directives, calls, expresiones, índices ni @. %s sobre valor no-string produce vacío, según oráculo fresco. El signo de un entero literal puede plegarse por el parser y está medido. Float en variable Dyn está medido; literal float sigue límite. PRIVATE activa el perfil macro y se rechaza, no se afirma compatibilidad MEMVAR.

Acumulador owned nuevo, sin modificar/mover variables de entrada. Getter enumKey temporal se libera tras copiarlo. Borrow string Dyn admite tags2 y4, sin confundir string de FOR EACH array con NIL. El primer gate ampliado encontró esa diferencia y se corrigió antes de esta entrega; solo gate final cuenta como PASS. Protección FOR EACH permite este observador de hojas, manteniendo rechazo de mutadores del hash/array. Landing pad interno bajo SEQUENCE conserva limpieza del acumulador; no se admiten calls de argumentos que requieran probar orden de evaluación de efectos. No cambia RC ni división numérica de arrays.

Gate56:4 fuentes intactas propias por5 modos =20 comparaciones exactas frescas;4 balances finales cero;16 rechazos de perfil;16 límites. Repite asignación/copia/consumo/retorno, cadena vacía, %%/%s, owned strings reutilizados, Dyn string/número/float/lógico/NIL, enumKey más valor de hash y FOR EACH array de strings. Incluye SEQUENCE sin error. No se afirma prueba dinámica del landing pad por error, pues calls/expresiones quedan rechazadas. Comandos/cwd, inputs/hash, rc/stdout/stderr separados y hash hbmk2.

Regresión final114 suites nativas previas, reconciliadas por nombre y SHA del compilador donde figura. Rust106; LLVM21 exactas frescas; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 mismos18 exactos; censo57/1041. Base64.prg intacto avanza a unknown hb_base64Decode. No hay cierre original ni claim de velocidad.

Árbol Harbour sin git, commit fuente no verificado. Sin push/publicación/workflows. Paquete reducido de texto, sin binarios/objetos/assembly desechable.

python tests/strformat-literal/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

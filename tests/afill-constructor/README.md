# AFill de un constructor temporal

Incremento MIT propio sobre 014e9ea833d74d0e0f7d07a8bd6cf72ab241266b. Los programas MIT de Julio Ponce son especificaciones, no implementación copiada. Harbour upstream se usa como oráculo de comportamiento. No se usa cambio.diff.

Se admite como expresión AFill(Array(n), valor) con una dimensión ya aceptada por Array y un valor plegado constante entero, lógico o NIL. Devuelve el buffer propio recién creado, rellenado con las celdas escalares existentes. La dimensión se evalúa una vez; después no hay expresiones con efectos ni payloads que retener/liberar. El AFill statement anterior queda intacto. No se cambia el modelo de celdas numéricas ni la política RC.

Solo Linux nativo ordinario, sin contexto macro/threads/shared-array. Siguen cerrados como expresión AFill sobre variable, multidimensional, valor calculado, cadena, float y rangos opcionales. No se amplían las reglas existentes para consumidores, retornos o tipos de asignación. AFill queda reservado como los demás nombres builtin. El oráculo no enlaza una redefinición propia de AFill; ese intento se conserva como experimento fallido.

Gate35: tres fuentes propias, quince comparaciones exactas con Harbour fresco en cinco modos nativos; tres balances finales estrictos cero; nueve rechazos de perfil; ocho rechazos de forma. Cubre 65536 celdas, índices primero/último, independencia de celdas, cero longitud, NIL/lógicos/enteros, extremos de entero, plegado de constante, dimensión con salida visible y 257 reasignaciones de buffers. Cada fuente conserva copia/hash, hash hbmk2, argv/cwd y rc/stdout/stderr separados.

96 suites nativas previas completas; LLVM21 exactas frescas; Rust104; Linux stdout/golden1177; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 combinados con los mismos16 desajustes exactos. Censo57/1041. big5_gen y uc16_gen superan el rechazo de función desconocida y llegan a otro rechazo existente por asignación de array a local inicialmente NIL. No hay nuevo original cerrado ni afirmación de velocidad.

Intentos fallidos retenidos: el primer gate detectó un tag incorrecto para NIL, corregido antes del gate final; el siguiente detectó una dimensión float producida por %, sustituida por un entero sin cambiar el compilador; la redefinición de AFill no enlazó en Harbour. La primera regresión amplia agotó disco durante enlace del oráculo. Se conservan esos logs, se repitieron las 96 suites completas con una suite a la vez y se eliminaron solo objetos/assembly generados. Un lote fue interrumpido por tiempo y se reanudó usando únicamente logs PASS completos; ningún fallo/timeout se cuenta como éxito.

El árbol extraído de Harbour no tiene git, su commit no está verificado. ORACLE.txt conserva versión/hash hbmk2. Paquete sin ejecutables, objetos ni assembly desechable. Sin push/publicación/workflows.

Reproducir:
python tests/afill-constructor/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

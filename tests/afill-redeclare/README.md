# Liberación al redeclarar AFill diferido

MIT propio sobre 4640939d2125525de2b3f6de6120061c75cfc0c8. Los programas MIT de Julio Ponce son especificaciones, no implementación copiada. No se usa cambio.diff.

La optimización bare_arr de AFill-delayed reinicializaba el slot con cero cuando LOCAL se ejecutaba otra vez, perdiendo el array anterior. Reproducer anidado con LOOP/EXIT antes del arreglo: stdout correcto, rc99 y DELTA=694. Corrección: antes del cero, liberar celdas con el destructor existente y liberar el array si el puntero no es cero. Mismo patrón existente de reemplazo y epílogo DArr; no cambia RC, inferencia ni admisión.

Harbour rechaza LOCAL tardío dentro del bucle. Por ello TODOS los positivos de este gate usan un oráculo de reset adaptado: LOCAL a al inicio de Main y a:=NIL en cada entrada. No se afirma compatibilidad de esas fuentes intactas. Las dos entradas se copian y hashean; argv/cwd y rc/stdout/stderr de build/run se conservan por separado.

Gate41: cuatro fuentes, veinte ejecuciones en cinco modos nativos (normal, external-as, no-vas-arrays, no-escape-analysis, no-prune), cuatro balances finales estrictos cero, dieciséis rechazos de perfil y un rechazo de celda float. Cubre entero, NIL, lógico, array vacío, primera entrada de puntero cero y bucle anidado LOOP/EXIT. La prueba float fue rechazada, no cuenta como cobertura positiva; conserva ese límite. Los balances usan memdelta_guard.py, con comandos emit/as/ld/run y clasificación estricta de dos estados; el emisor instrumentado usa no-prune.

Regresión completa: 109 suites nativas previas, reconciliadas por nombre; Rust104; LLVM21 exactas frescas; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 exactamente los mismos16 desajustes; censo57/1041 byte a byte idéntico. No se cierra ningún original ni se afirma velocidad.

Árbol Harbour extraído sin git; commit fuente no verificado. Hash hbmk2 en ORACLE.txt. Evidencia del fallo inicial, del intento float rechazado y del gate final se conserva. Solo commits nuevos, sin publicación/push/workflows.

Reproducir:
python tests/afill-redeclare/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

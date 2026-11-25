# hb_FileExists / hb_DirExists Linux

MIT propio sobre 452807779d711041d14e21acd5c8569674005146. Programas MIT de Julio Ponce usados solo como especificaciones; sin implementación copiada ni cambio.diff. Harbour upstream es oráculo fresco. El árbol del oráculo no tiene git y su commit fuente no está verificado; hash hbmk2 incluido.

Una expresión string tipada, resultado Bool, Linux x86-64 nativo ordinario sin threads/macros. hb_FileExists reconoce archivo regular; hb_DirExists reconoce directorio. newfstatat sigue symlinks. No glob, no búsqueda SET DEFAULT/PATH, no cambio de FError. No añade FILE(). Copia terminada en NUL de cada path; strings con NUL embebido se truncan, medido con Harbour. Buffer propio liberado; resultado temporal string del argumento se libera, variable se presta y conserva. No cambios de objetos/RC.

Gate25: 2 fuentes propias intactas por 5 modos = 10 exactas con Harbour fresco; 2 balances finales cero; 8 rechazos de perfil; 5 límites. Casos archivo, directorio, dotfile, symlinks a ambos, enlace roto, ausente, wildcard sin expansión, cwd, vacío, slash sobre archivo, FIFO y /dev/null. Owned Lower/concatenación, variable reutilizada, función con parámetro string inferido y NUL. La fixture aislada se replica para la medición de balance. No se afirma prueba de permisos denegados, sockets, races ni exhaustividad filesystem.

Regresión: 120 suites nativas previas reconciliadas por nombre, 117 registros con SHA del compilador verificado cuando existe; Rust106, LLVM21 exactas frescas, Linux1177 stdout/golden. PE solo emisión1912PASS/22conocidas/0FAIL, no ejecución PE. Negativos622 mismos18 exactos; censo58/1041 sin cambios. Sin cierre original nuevo, sin medición de velocidad. División numérica y RC/objetos siguen aparcados. Sin push/publicación/workflows/rebase.

python tests/path-exists/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

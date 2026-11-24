# hb_MemoRead binario acotado

MIT propio sobre d32cc7a95d4238d28326465d504d04e32f02d121. Los programas MIT de Julio Ponce son especificaciones, no implementación copiada. Harbour upstream es oráculo. No se usa cambio.diff.

Una ruta string tipada, Linux nativo ordinario sin macros/threads. Devuelve cadena propia de archivo regular seekable hasta 1048576 bytes, conservando NUL/Ctrl-Z/CRLF y FError. Ruta faltante, directorio, vacío o error de lectura devuelve vacío. Abre no bloqueante para no colgarse con FIFO y comprueba archivo regular; no abre soporte a streams. Reintenta read tras EINTR, cierra fd y conserva FError. Path temporal propio se libera tras leer, variable path se toma prestada. Inferencia de parámetro string incluida. Archivos mayores que el límite observado al abrir salen con diagnóstico explícito rc1, nunca se presentan truncados como éxito. No hay snapshot atómico ante cambios concurrentes del archivo; leer mientras cambia queda fuera de lo comprobado. No se añaden formas sin argumento, Dyn ni argumentos opcionales.

Gate22: dos fuentes propias x cinco modos = diez exactas frescas; dos balances finales estrictos cero; seis rechazos de perfil; tres rechazos de forma; un límite runtime explícito. Archivo binario de65799 bytes, frontera exacta1MiB, faltante/vacío/directorio, path temporal/variable, función con parámetro string,137 lecturas repetidas y FError previo. Fixtures deterministas generados por el runner; copia/hash del programa transformado, hash hbmk2, comando/cwd y rc/stdout/stderr separados. Los experimentos previos verifican que Harbour conserva FError incluso al fallar.

98 suites nativas previas completas; LLVM21 frescas; Rust104; Linux1177 stdout/golden; PE emisión1912PASS/22conocidas/0FAIL; negativos622 mantienen exactamente16 desajustes; censo57/1041. big5_gen/uc16_gen alcanzan rechazo existente de hb_ATokens con temporal propio y argumento posterior que puede lanzar. No hay original nuevo cerrado, afirmación de velocidad ni cambio RC/numeric-cell.

Intentos fallidos conservados: inferencia string omitida inicialmente, fixture con move indebido y edición de cabecera incorrecta, escape assembly no admitido, sección .text faltante que causaba segfault, directorio con seek extraño que exigió fstat. Todos corregidos antes del gate final. Rust y enlace LLVM agotaron disco; se liberaron solo ELF/objetos/assembly/caché generados y se repitieron completos. Un lote temporalmente interrumpido se reanudó solo desde PASS completos. Ningún intento fallido cuenta como PASS. Rust final CARGO_INCREMENTAL=0 RUSTFLAGS=-C debuginfo=0.

El árbol de Harbour no tiene git, commit upstream no verificado. ORACLE.txt guarda versión/hash hbmk2. Paquete sin ejecutables/objetos/assembly desechable; memoread_linux.s es fuente propia necesaria. Sin push/publicación/workflows.

python tests/memoread/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

# Getter __enumIndex del iterador activo

MIT propio sobre 079f7d52a0c67054ef4f500e4241a08758223bad. Los programas MIT de Julio Ponce son solo especificaciones; no se copia implementación ni cambio.diff. Harbour upstream es el oráculo diferencial.

Linux nativo ordinario: variable Dyn readonly de FOR EACH activo, getter :__enumIndex() o :__enumIndex sin argumentos. Devuelve el contador oculto 1-based como entero, sin crear proxy, transferir el elemento ni cambiar ownership. El checker mantiene una pila léxica y la emisión una pila de offsets; readonly por sí solo no demuestra un iterador. Restaura ambas al salir del bucle. La prueba de préstamos trata únicamente este getter escalar como observación. Otros mensajes siguen sus rutas y rechazos anteriores.

Quedan fuera: setter/argumentos, fuera del bucle o después de NEXT, captura en bloque, shared-local, iterador string o subarray tipado, Windows, Mach-O y LLVM. Los métodos de objetos conocidos mantienen su ruta anterior, esta ruta requiere receptor Dyn activo.

Gate45: cuatro fuentes x cinco modos =20 ejecuciones exactas contra Harbour fresco, cuatro balances finales cero,16rechazos de perfil y cinco rechazos de forma/contexto. Anidación con iteradores iguales y distintos, restauración, LOOP/EXIT, getter con/sin paréntesis, resultado asignado a entero e índice de escritura array,513 rondas. El rechazo de captura es el límite previo de cuerpo codeblock, no una prueba de ejecución del getter en bloques. Cada prueba conserva fuente/hash, hbmk2/hash, argv/cwd y rc/stdout/stderr separados.

Regresión del compilador final:103 suites nativas previas completas, Rust104, LLVM21 exactas frescas, Linux1177 stdout/golden, PE solo emisión1912PASS/22conocidas/0FAIL, negativos622 con los mismos16desajustes, censo57/1041. big5_gen sigue rechazado, ahora índice no entero en línea71. No se cierra ningún original nuevo, ni se afirma velocidad o nueva política numérica/RC.

Incidencias retenidas: prototipo inicial basado en readonly sustituido por prueba léxica explícita antes de entrega; error de tipo Rust usize/i32 corregido; fixture de captura esperaba diagnóstico demasiado concreto, ajustado al rechazo codeblock real; falta de espacio en enlaces del oráculo y lotes interrumpidos. Se retiraron solo objetos/ELFs/assembly generados y se repitió toda la regresión del compilador final. Ningún fallo o parcial cuenta como PASS. La batería final vuelve a conciliar las103suites contra sus logs.

Árbol Harbour extraído sin git, commit no verificado. ORACLE.txt conserva versión/hash hbmk2. Paquete sin ejecutables/objetos/assembly desechable. Sin push/publicación/workflows.

python tests/foreach-enumindex/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

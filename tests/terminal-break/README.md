# Cierre tras BREAK terminal

Cambio MIT propio. Los programas y salidas de Julio Ponce son especificaciones, no implementación copiada. Harbour upstream se usa como oráculo de comportamiento.

El parser admite que una función/procedimiento termine sin RETURN explícito si su último statement de nivel superior es BREAK y sigue una frontera de función/procedimiento, STATIC FUNCTION, INIT/EXIT o EOF. Se añade el RETURN NIL inalcanzable que requiere el IR existente sin consumir la siguiente cabecera. No se cambia el runtime de excepciones ni la política de ownership/RC.

No se abre fallthrough implícito general, condicionales terminales ni métodos sin RETURN. No se afirma compatibilidad nueva de INIT/EXIT fuera de sus límites previos. BREAK con sintaxis de llamada usa el mismo statement existente. No se añaden nuevos perfiles de ejecución.

Comprobación propia: 20 resultados: 10 comparaciones exactas con Harbour fresco en cinco modos nativos, dos balances finales estrictos cero, seis emisiones de otros targets sin ejecución y dos rechazos nombrados. Las fuentes prueban frontera normal/static/EOF, BREAK desnudo y valor propio de cadena durante 513 rondas; el otro caso hace 117 rondas con tres recuperaciones. Se guardan copia/hash de entrada, hash de hbmk2, argv/cwd y rc/stdout/stderr separados. Pruebas rechazadas inicialmente por nombres predefinidos del oráculo se conservan como intento fallido, no como evidencia favorable.

Regresión con el compilador final: 95 suites nativas previas completas; LLVM 21 comparaciones frescas; Rust 104; Linux stdout/golden 1177; PE solo emisión 1912 PASS, 22 desajustes conocidos, 0 FAIL. Los 622 negativos combinados Linux/Windows mantienen exactamente los mismos 16 desajustes. Censo upstream 57/1041, sin nuevo original cerrado. begin.prg cambia del rechazo por RETURN al rechazo existente de STATIC etiquetado en línea 101.

El primer cargo test agotó espacio escribiendo caché incremental. Se conservan los logs fallidos y el reintento completo PASS con CARGO_INCREMENTAL=0. También se repitieron las 95 suites y las baterías Linux/negativos/censo con el SHA final tras un ajuste exclusivamente de formato del código. No se cuenta la ejecución incompleta como PASS.

Sin afirmación nueva de velocidad ni cambios en decisiones numéricas/RC pendientes. Sin publicación, push ni workflows.

Reproducción:
python tests/terminal-break/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

El árbol extraído de Harbour no tiene metadatos git; el commit upstream no está verificado. Conservar el hash hbmk2 de ORACLE.txt. El paquete omite ejecutables, objetos y assembly desechable. increment.bundle e increment.patch contienen solo el commit nuevo sobre b16060cf0d42cbfef71236a7f8445a7e274b918e.

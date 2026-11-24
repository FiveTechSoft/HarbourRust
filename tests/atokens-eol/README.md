# hb_ATokens con hb_eol posterior

MIT propio sobre 8aa76b51398d7fc77ed9ac63ee0eef02fd83af6a. Los programas MIT de Julio Ponce son especificaciones, no implementación copiada. Harbour upstream es oráculo; no se usa cambio.diff.

Solo hb_eol() builtin exacto sin argumentos se admite como argumento posterior quieto mientras hb_ATokens retiene un temporal string propio. Su emisión existente es dirección/longitud constante, no llamada runtime, sin error ni ownership. No se abre cleanup general ni llamadas arbitrarias y no se modifica val_quiet_arg compartido.

Gate11: una fuente propia x cinco modos nativos = cinco comparaciones exactas con Harbour fresco; un balance final estricto cero; tres emisiones de otros targets sin ejecución; dos rechazos de forma. Cubre separador EOL, líneas vacías y513 reasignaciones. Fuente/hash, hash hbmk2, argv/cwd y rc/stdout/stderr separados. El primer intento esperaba rechazo en otros targets, pero ya admiten este caso: corregido a emisión únicamente, nunca se afirma ejecución PE/Mach-O.

99 suites previas completas con una adaptación declarada: limit-foreach-unknown de afill-delayed antes usaba hb_memoRead como desconocida. Al añadirse la función y ahora habilitar EOL, ese programa compila. Se cambia solo ese callee por ad_missing_read para conservar la prueba de diagnóstico unknown-callee sin panic; su suite vuelve a PASS26. No se cuenta como nueva compatibilidad. El intento con la negativa obsoleta queda guardado.

Rust104; LLVM21 frescas; Linux1177stdout/golden; PE emisión1912PASS/22conocidas/0FAIL; negativos622 exactamente16 desajustes previos; censo57/1041. big5_gen avanza a hb_At tipado; uc16_gen a Empty sobre Dyn. No nuevo original cerrado ni afirmación de velocidad/RC. La batería atokens-bb adicional se inició pero no terminó dentro del límite de ejecución; su log parcial no se cuenta como PASS. La batería Linux1177 sí completó.

Árbol Harbour sin git, commit upstream no verificado. ORACLE.txt conserva versión/hash hbmk2. Sin push/publicación/workflows. Paquete sin ejecutables/objetos/assembly desechable.

python tests/atokens-eol/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

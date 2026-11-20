# Left/Right con fuente Dyn y longitud I64 tipada

Incremento MIT propio. Solo fuente que sea variable Dyn o resultado Dyn de hb_defaultValue; longitud I64 tipada; Linux ordinario sin threads/macros. No se añade ABI generica, longitud Dyn/F64 ni asignacion inline string/Dyn. Las rutas tipadas anteriores y helpers de corte por bytes permanecen intactos.

La fuente se evalua y toma como snapshot propio antes de evaluar longitud. Si longitud lanza, un landing pad local libera el snapshot y continua el unwind exterior. El resultado guarda su propia cadena antes de liberar entrada. Longitudes negativas/cero dan vacio, mayores que la fuente se limitan a su tamaño. No se promete corte por puntos Unicode.

Solo se soportan fuentes runtime cadena. El resto termina con limite fatal explicito DESPUES del efecto de longitud, no es paridad de error. El oracle demuestra que Left no-string lanza error recuperable mientras Right no-string devuelve vacio; no se supone que comparten semantica. Los20 limites fatal no se cuentan como resultados iguales a Harbour. Los4 casos RHS-throw si comparan resultado rc/stdout/stderr exacto, con traduccion declarada de TRY solo en oracle.

Desde la raiz, rutas absolutas y directorios de salida nuevos:

    python3 tests/dyn-string-slice/check.py --compiler FINAL --baseline BASE --hbmk2 HBMK2 --output OUT-exact
    python3 tests/dyn-string-slice/safety.py --compiler FINAL --output OUT-safety
    python3 tests/dyn-string-slice/diagnostic.py --compiler FINAL --hbmk2 HBMK2 --output OUT-limits
    python3 tests/dyn-string-slice/mutants.py --compiler FINAL --rustc RUSTC --hbmk2 HBMK2 --output OUT-mutants
    python3 tests/dyn-string-slice/guard_selftest.py --compiler FINAL --hbmk2 HBMK2 --output OUT-guards

check.py:34 fuentes propias,68 pares int/ext exactos con oracle fresco, sin adaptadores.30 de estas fuentes se midieron antes del prototipo. Las otras4 reemplazan durante el desarrollo intentos con asignacion inline string/Dyn fuera del dialecto por setters existentes dentro de comparaciones. No se amplia ese dialecto para hacer pasar una prueba. El baseline rechaza todas34. Se conserva por separado la captura inicial44 y12 probes preprototipo con adaptador de errores.

safety.py:47 controles, tres modos instrumentados100 warmup+10000 vueltas medidas, reemplazo de fuente con cache de igual longitud y20000 excepciones RHS recuperadas, delta hb_memcheck cero. Otros12 son limites de perfil y32 de forma. Esto no es comparacion de salida con Harbour.

mutants.py:4 mutantes propios, ambas compilaciones rc0 y divergencia runtime rc0 obligatorias. Direccion equivocada, mover/vaciar fuente, no liberar entrada normal y no liberar entrada al lanzar RHS. Los dos primeros controles usan oracle; los dos de memoria usan instrumentacion propia y fixture corta para medir fuga antes de OOM. Un primer intento de fixture larga produjo OOM y NO cuenta como mutante valido. guard_selftest.py exige fallar cerrado en4 simulaciones proxy, cuatro caught=False cada una. Rechazos, timeout, OOM o salida igual nunca cuentan.

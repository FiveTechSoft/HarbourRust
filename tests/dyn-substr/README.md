# SubStr con fuente Dyn

Incremento MIT propio, dos o tres argumentos. Fuente variable Dyn o resultado hb_defaultValue, posicion/longitud I64 tipadas, Linux ordinario sin threads/macros. No se abre ABI generica, indices Dyn/F64, asignacion inline string/Dyn ni otros productores Dyn. Los helpers y caminos tipados anteriores permanecen intactos. Corte por bytes, no por puntos Unicode.

La fuente se toma como snapshot antes de posicion y longitud, que se evaluan una vez y en orden. Si cualquiera lanza, un landing pad local libera snapshot y reanuda unwind exterior. Si se omite longitud se usa el extremo I64 positivo. Cero/negativos/extremos siguen el helper existente, medidos con oracle externo.

Solo fuente runtime cadena soportada. Otros tipos tienen limite fatal explicito DESPUES de todos los efectos numericos, no paridad con el error recuperable Harbour. diagnostic separa20 limites fatales de6 casos RHS-throw exactos. Solo el oracle de diagnostic usa traduccion declarada TRY a BEGIN SEQUENCE/RECOVER.

Desde raiz, ejecutables absolutos y directorios nuevos:

    python3 tests/dyn-substr/check.py --compiler FINAL --baseline BASE --hbmk2 HBMK2 --output OUT-exact
    python3 tests/dyn-substr/safety.py --compiler FINAL --output OUT-safety
    python3 tests/dyn-substr/diagnostic.py --compiler FINAL --hbmk2 HBMK2 --output OUT-limits
    python3 tests/dyn-substr/mutants.py --compiler FINAL --rustc RUSTC --hbmk2 HBMK2 --output OUT-mutants
    python3 tests/dyn-substr/guard_selftest.py --compiler FINAL --hbmk2 HBMK2 --output OUT-guards

check.py:28 fuentes propias intactas medidas ANTES del prototipo,56 pares int/ext exactos de rc/stdout/stderr con Harbour fresco, sin adaptadores. Base rechaza28. Incluye aridad2/3, posiciones y longitudes limites I64, NUL, reemplazo de fuente con setters existentes durante posicion/longitud, cache de igual longitud, propiedad del resultado y orden de llamadas.

safety.py:33controles,3modos instrumentados100warmup+10000vueltas con30000errores de operandos recuperados,delta hb_memcheck0. Otros6limites perfil y24forma. No se confunde instrumentacion con salida Harbour.

mutants.py:4mutantes propios, Rust0,PRG0,runtime0 divergente obligatorios:posicion equivocada,mover/vaciar fuente,omitir liberacion normal,omitir liberacion al lanzar. Dos controles semanticos usan oracle fresco;dos memoria usan fixture corta propia para observar fuga sin OOM. El primer fixture semantico sobrescribia luego la fuente y dejaba sobrevivir move-input;un segundo tenia posicion1 y dejaba sobrevivir wrong-position. Gate los rechazo correctamente. Fixture final posicion2 imprime fuente retenida y distingue ambos. guard_selftest exige gate1 y4caught=False en4proxies de rechazo/timeout/salida igual. No cuentan como mutantes validos.

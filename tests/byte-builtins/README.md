# hb_BChar I64 / hb_BCode cadena tipada

Aliases propios de las rutas byte ya existentes Chr/Asc. hb_BChar toma I64 y devuelve cadena propia de1byte con n&255,incluido NUL. hb_BCode toma cadena tipada prestada y devuelve primer byte sin signo,o0si vacia. Se usan los helpers y reglas de propiedad existentes,sin nueva implementacion runtime. Las comparaciones de nombres son case-insensitive y unidireccionales. Los nombres se reservan para evitar colision con funciones de usuario.

No se abre F64,Dyn,NumLocal,coercion default ni conversion Unicode. Las rutas Chr/Asc son byte-codepage en este compilador,no una afirmacion de equivalencia general a Chr/Asc Harbour bajo otras codepages. No se añade soporte de nombres dentro de texto macro interpretado. Se conservan limites LLVM de las expresiones Chr/Asc originales. Un limite de tipo puede nombrar Chr/Asc porque es el mismo chequeo existente.

Comandos desde raiz,ejecutables absolutos y directorios nuevos:

    python3 tests/byte-builtins/check.py --compiler FINAL --baseline BASE --hbmk2 HBMK2 --output OUT-exact
    python3 tests/byte-builtins/safety.py --compiler FINAL --output OUT-safety
    python3 tests/byte-builtins/identity.py --compiler FINAL --baseline BASE --output OUT-identity
    python3 tests/byte-builtins/mutants.py --compiler FINAL --rustc RUSTC --hbmk2 HBMK2 --output OUT-mutants
    python3 tests/byte-builtins/guard_selftest.py --compiler FINAL --hbmk2 HBMK2 --output OUT-guards

check:23fuentes intactas creadas/medidas ANTES del prototipo,46pares int/ext exactos rc/stdout/stderr con oracle fresco,sin adaptador.256roundtrips cubren todos los bytes. Tambien I64min/max,negativos,wrap,NUL,FF,UTF8 como bytes,propiedad,parametros y efectos.
safety:37controles,3modos instrumentados100warmup+10000vueltas,delta hb_memcheck0,30rechazos de forma/nombre y4limitesLLVM. No paridad de errores runtime.
identity:23fuentes x4targets=92filas.89compilan ASM/binario;3rechazan en ambos por owned-string comma list fuera de Linux. ASM exacto y binarios Linux/MachO exactos frente base Chr/Asc,misma ruta fuente. PE registra SHA brutos y permite SOLO timestampCOFF y checksum dependiente;ningun byte de codigo se normaliza. No se confunde con ejecucion oracle en otros targets.
mutants:2mutantes propios de ruta,BChar→Space y BCode→Len. Rust0,PRG0 y runtime0 divergente obligatorios;controles iguales a Harbour fresco. No se mutan helpers existentes para atribuirles cobertura del nuevo producto.4proxies fail-closed exigen gate1 y2caught=False cada uno. Rechazos,timeout,OOM y salida igual nunca cuentan.

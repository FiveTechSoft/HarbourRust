# Lower/Upper/AllTrim sobre cadenas Dyn locales

Incremento MIT propio. Solo se admiten variables Dyn y resultados Dyn de hb_defaultValue como argumento unico, en Linux ordinario sin threads/macros. El valor de ejecucion debe ser una cadena. No se añade una ABI de cadenas generica ni inferencia especulativa. Los caminos tipados anteriores y sus helpers ASCII permanecen intactos. No se promete conversion Unicode. La entrada se toma como snapshot independiente y se libera tras guardar el resultado propio.

El tipo incorrecto es un limite fatal explicito, NO un error Harbour recuperable. diagnostic.py lo demuestra: 30 compilaciones positivas con nil/int/float/bool/array, dos ensambladores; Harbour recupera y continua, este incremento termina con rc1. Solo el oracle lleva la traduccion declarada TRY a BEGIN SEQUENCE/RECOVER. Los casos funcionales positivos no tienen adaptadores.

Comandos desde la raiz, sustituyendo rutas de ejecutables y directorios nuevos:

    python3 tests/dyn-string-unary/check.py --compiler FINAL --baseline BASE --hbmk2 HBMK2 --output OUT-exact
    python3 tests/dyn-string-unary/safety.py --compiler FINAL --output OUT-safety
    python3 tests/dyn-string-unary/diagnostic.py --compiler FINAL --hbmk2 HBMK2 --output OUT-limits
    python3 tests/dyn-string-unary/mutants.py --compiler FINAL --rustc RUSTC --hbmk2 HBMK2 --output OUT-mutants
    python3 tests/dyn-string-unary/guard_selftest.py --compiler FINAL --hbmk2 HBMK2 --output OUT-guards

check.py compara 36 fuentes propias intactas, 72 pares internos/externos de rc/stdout/stderr con Harbour externo. Incluye NUL, vacio, espacios, propiedad de cadenas, parametros tras default setter y orden de efectos. Las mismas 36 fuentes se probaron antes de implementar el incremento, con rechazo del baseline y oracle compilando/ejecutando rc0.

safety.py exige delta de memoria cero tras calentamiento y 10000 vueltas, tambien 10000 fallos RHS anidados recuperados, en tres modos. Ademas exige 18 rechazos de perfil y 33 de forma. No confunde esta instrumentacion con igualdad de salida Harbour.

mutants.py exige Rust rc0, compilacion PRG rc0 y divergencia de ejecucion rc0 para tres mutantes propios: helper equivocado, mover/vaciar entrada, omitir liberacion del snapshot. Los controles semanticos usan Harbour; el control de memoria usa instrumentacion propia. guard_selftest.py simula rechazo/timeout de compilacion, timeout de ejecucion y salida identica. Los tres caught deben quedar False y el gate debe fallar en las cuatro simulaciones. Estas simulaciones no cuentan como mutantes Rust validos.

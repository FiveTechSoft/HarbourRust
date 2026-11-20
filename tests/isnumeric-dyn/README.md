# hb_isnumeric de variable Dyn

Extiende sólo Expr::Var con tipo Dyn al test prestado de tag. I64 tags0/9 y heapfloat kind5 son numéricos;NIL,lógico,cadena y contenedores no. No se evalúa/mueve/clona el contenido. El clasificador de celdas indexadas queda intacto. No abre RefDyn ni expresiones Dyn genéricas. No cambia hb_isarray ni sus bytes emitidos. La adición kind5 es local a want_num dentro del caso Dyn.

25fuentes propias pre-fix:19defaultValue(incluidos parámetros/reutilización/secuencia) y6locales directas;50pares int/ext exactos rc/stdout/stderr con oracle Harbour externo fresco. Captura inicial checker-only descubrió F64Dyn mal clasificado,se conserva fuera del producto. Una fuente inicial hb_memcheck inválida para oracle y unaDate bloqueada antes se separaron;reuse tiene captura corregida independiente anterior al fix final. No son pares aprobados.

    python3 tests/isnumeric-dyn/check.py --compiler FINAL --baseline BASE --hbmk2 HBMK2 --output OUT
    python3 tests/isnumeric-dyn/safety.py --compiler FINAL --output OUT-safety
    python3 tests/isnumeric-dyn/profiles.py --compiler FINAL --output OUT-profiles
    python3 tests/isnumeric-dyn/mutants.py --compiler FINAL --rustc RUSTC --hbmk2 HBMK2 --output OUT-mutants
    python3 tests/isnumeric-dyn/guard_selftest.py --compiler FINAL --hbmk2 HBMK2 --output OUT-guards

safety15:3modos instrumentados100warmup+10000loops de5tags,delta hb_memcheck0;10límites de forma y2límitesLLVM. Primeras hipótesis de límite sobre1+2constante y función que sólo imprime fueron aceptadas legítimamente por plegado/préstamo;no se contabilizan como rechazos y los controles se ajustaron a formas realmente no admitidas.
profiles24:6locales directas x4targets,sólo ASM,no runtime cross-target. Las19fuentes defaultValue rechazan en57perfiles noLinux por límite previo del productor,no soporte ni defecto de hb_isnumeric. Evidencia exploratoria conservada.
mutants2:omitirfloat y clasificarlogical como float;Rust0+PRG0+runtime0 divergente obligatorios.4proxies fail-closed,ninguno simula mutante Rust válido ni cuenta como prueba de semántica del producto.

## Corrección de revisión v2

V1admitía PRIVATE/PUBLIC como Dyn pero emitía carga del slot0(frame),no lookup.8probes oracle capturados muestran4errores numéricos y4coincidencias accidentales no-numéricas. V2rechaza admisión nueva cuando MACRO_CONTEXT está activo:diagnóstico explícito para PRIVATE/PUBLIC ycontexto macro,incluso localDyn no-memvar en ese programa. hb_isarray queda sin cambios. No se implementa resolución memvar.

    python3 tests/isnumeric-dyn/memvar_limits.py --compiler FINAL --hbmk2 HBMK2 --output OUT-limits

10límites explícitos:8PRIVATE/PUBLIC(I64,F64,lógico,cadena) y2controles localDyn conmemvar/contexto macro. Oracle compila/ejecuta fresco;compilador rechaza sin ejecutar binario. No es paridad runtime. Las capturasV1se conservan como defecto,no éxito.

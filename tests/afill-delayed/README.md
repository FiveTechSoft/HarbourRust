# Inicialización diferida de un array nuevo

MIT propio sobre d399b9bdc01def556a4d243295ee08f261a59f37. Los programas MIT de Julio Ponce son especificaciones, no implementación copiada. Harbour upstream es oráculo de comportamiento. No se usa cambio.diff.

Forma acotada: LOCAL a inicialmente NIL, seguido de asignación incondicional de nivel superior a:=AFill(Array(n),constante). n debe ser entero constante no negativo; relleno entero/lógico/NIL. Antes del primer store solo se aceptan declaraciones/asignaciones de hoja sin mención de a u otros constructores constantes de la misma forma. Sin lectura, captura, byref, llamadas calculadas ni control-flow antes del store. Solo Linux nativo ordinario sin shared-array. El slot comienza como array vacío, un estado inobservable dentro de esta forma, y usa la propiedad/liberación DArr existente. Checker, layout y emisión comparten el mismo predicado. No se abre retyping Dyn general ni se cambia RC/modelo numérico.

Al alcanzar FOR EACH en los originales apareció un panic previo: apply_moves recorría la colección antes de type_expr y una llamada desconocida abortaba. La validación ahora precede el recorrido de ownership. No se añade hb_memoRead ni se silencian rechazos. Se conserva el panic inicial y un reproducer cuyo resultado final es el rechazo nombrado por función desconocida.

Gate26: dos fuentes propias por cinco modos nativos, diez comparaciones exactas con Harbour fresco; dos balances finales cero; seis rechazos de perfil; ocho rechazos de forma. Cubre declaraciones múltiples, 65536 celdas, 31 frames, NIL/lógicos/enteros, vacío y reasignación. Rechazos por lectura previa, condicional, dimensión calculada, autorreferencia, llamada previa, RECOVER y byref; también unknown callee en FOR EACH. Copia/hash de entrada, hash hbmk2, argv/cwd y rc/stdout/stderr separados.

Regresión completa: 97 suites nativas previas; LLVM21 frescas; Rust104; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 combinados exactamente los mismos16 desajustes; censo57/1041. big5_gen/uc16_gen alcanzan rechazo nombrado hb_memoread y siguen sin cerrarse. Sin afirmación nueva de velocidad.

Dos lotes se interrumpieron por tiempo; se conservaron los parciales y se reanudaron solo desde PASS completos. Primer cargo test agotó disco; reintento completo PASS con CARGO_INCREMENTAL=0 y RUSTFLAGS=-C debuginfo=0. Los fallos no cuentan como PASS. Solo se descartaron cachés/objetos/assembly generados y duplicados de paquetes verificados. El paquete no contiene ejecutables/objetos/assembly desechable.

El árbol de Harbour no tiene git; commit upstream no verificado. ORACLE.txt registra versión y hash hbmk2. Sin publicación/push/workflows.

Reproducir:
python tests/afill-delayed/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

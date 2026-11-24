# Precedencia NOT por debajo de comparación

MIT propio sobre e22592924c844861fca6576c18e812d1326470c6. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada ni cambio.diff. Harbour upstream es oráculo.

El parser aplicaba NOT solo a factor(), y el comentario afirmaba erróneamente precedencia superior a comparación. Oráculo fresco: !x==NIL con x NIL produce .F.; .NOT.1==2 produce .T. Corrección de una llamada: NOT consume cmp_expr(), no factor(), conservando AND/OR fuera de su operando. Abarca ! y .NOT.; no cambia checker ni semántica de runtime/RC.

Gate20:3 fuentes intactas por5 modos nativos =15 comparaciones exactas con Harbour fresco;3 balances cero;2 rechazos NOT directo numérico/string. Cubre NIL, entero, float, strings/$, operadores dobles NOT, paréntesis, AND/OR y orden/cortocircuito con llamadas visibles. Inputs/hash, hash hbmk2, argv/cwd y rc/stdout/stderr separados. Cambio de parser global, PE solo se ha emitido, no ejecutado en este trabajo; LLVM21 regresiones propias previas, no gate NOT específico LLVM.

Regresión final113 suites previas reconciliadas por nombre y compiler SHA cuando el formato lo incluye; Rust106; LLVM21 exactas frescas; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 mismos18 exactos; censo57/1041. directry.prg avanza al rechazo upper sobre Dyn, no cierre original. Sin nueva velocidad ni decisiones numeric-cell/RC/@Dyn.

Un primer nombre de salida npfinal colisionó con evidencia antigua: se detectó el SHA distinto inmediatamente, no se usó como regresión y se repitieron TODAS las suites con prefijo nuevo notprec20261124. Solo esas ejecuciones nuevas están en el paquete final. Oráculo de reproducción anterior al fix en before-fix; árbol fuente Harbour sin git, commit no verificado. Sin push/publicación/workflows/rebase.

python tests/not-precedence/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

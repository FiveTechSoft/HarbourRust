# Literal string dentro de variable Dyn

MIT propio sobrec4accbccf2bbc3c42ba87d29cad5df30ee57fb20. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada/cambio.diff. Harbour upstream es oráculo.

Linux nativo ordinario: literal string $ variable Dyn. Runtime acepta tags2/4, obtiene bytes contados y usa scan existente. Ambos operandos son leaves sin efectos; no hay llamada/alloc entre carga y scan, ni traslado de ownership. Empty needle sigue .F., búsqueda case-sensitive y bytewise. No admite needle Dyn, haystack calculado/call, array membership ni otros perfiles/shared/macro. NIL/número/logical usan error de tipo existente, sin afirmar identidad del handler predeterminado.

Gate42: cuatro fuentes x cinco modos=20ejecuciones exactas frescas, cuatro balances finales cero,16rechazos perfil y dos límites.163/139/127/137rondas, strings propios/prestados FOR EACH, empty/ausente/presente/case/NUL, condición/asignación/AND/NOT, errores recuperables con BEGIN SEQUENCE WITH explícito en ambas ejecuciones. Fuente/hash,hbmk2/hash,argv/cwd,rc/stdout/stderr separados.

106suites nativas previas completas conciliadas, incluida corrección redeclare ATokens gate68; Rust104, LLVM21exactas frescas, Linux1177stdout/golden, PE emisión1912PASS/22conocidas/0FAIL, negativos622 mismos16desajustes, censo57/1041. Cambian diagnósticos, no rc, de tests/uc16_gen.prg y contrib/hbnf/metaph.prg. uc16_gen avanza a hb_bitor con Dyn línea49. Sin original nuevo cerrado, velocidad, política numérica/celdas/RC.

Trabajo pausado al llegar FAIL del revisor sobre delayed ATokens, restaurado después sobre el fix c4accbcc. No se incluyó el experimento en ese fix. Árbol Harbour extraído sin git, commit no verificado; ORACLE.txt conserva versión/hash hbmk2. Sin binarios/objetos/assembly desechable ni push/publicación/workflows.

python tests/dyn-contains/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

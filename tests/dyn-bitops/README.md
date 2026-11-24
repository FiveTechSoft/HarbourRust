# Bitops sobre operandos Dyn hoja

MIT propio sobre980f9a4bdd2c3d7783ae82d25a5d609ad0767b89. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada/cambio.diff. Harbour upstream es oráculo.

hb_bitOr/And/Xor/Not admite variable Dyn en ordinary Linux cuando todos los argumentos son integer literals o variables. Usa Int(Dyn) existente: enteros0/9 exactos, floats truncados hacia cero. No cambia bitindex ni helper general integer-only, ni política de almacenamiento numérico. Args calculados/calls en esta nueva ruta se rechazan, evitando efectos posteriores adelantados al error. Operandos hoja sin temporales; variables strings/float siguen prestadas, no se consumen. Typed F64, shared/macro y otros perfiles siguen fuera de esta ruta nueva.

Gate42: cuatro fuentes x cinco modos=20ejecuciones exactas frescas,4balances finales cero,16rechazos perfil,2límites.1.9/-1.9, integer extremes, unary/n-ary, Dyn a izquierda/derecha, NIL/logical/string y repetición157/151rondas de errores recuperables con BEGIN SEQUENCE WITH explícito en ambos. No igualdad de handler predeterminado. Fuente/hash,hbmk2/hash,argv/cwd,rc/stdout/stderr separados.

107suites nativas previas completas conciliadas, incluidos ATokens gate68 y Dyn containment42. Rust104, LLVM21exactas frescas, Linux1177stdout/golden, PE emisión1912PASS/22conocidas/0FAIL, negativos622 mismos16desajustes, censo57/1041. uc16_gen avanza hasta @sobre Dyn línea125, dentro del área de sharing/RC aparcada. No se abre ese límite, no cierre original nuevo ni velocidad/RC.

Árbol Harbour extraído sin git, commit no verificado; ORACLE.txt conserva versión/hash hbmk2. Sin binarios/objetos/assembly desechable ni push/publicación/workflows.

python tests/dyn-bitops/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

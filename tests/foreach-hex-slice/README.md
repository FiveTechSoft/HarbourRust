# HexToNum de SubStr sobre iterador prestado

MIT propio sobre7c81f7eed95fa76f110665801a32422bb36ffb40. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada/cambio.diff. Harbour upstream es oráculo.

Prueba de préstamos FOR EACH admite composición exacta hb_HexToNum(SubStr(iterador,start[,count])) en output inmediato o asignación del entero a otro local. Bounds solo integer literals/variables y árboles +,-,* sin calls/escrituras ni referencia al iterador. No amplía type checking de SubStr/HexToNum: los bounds siguen tipados I64. La emisión existente clona snapshot string independiente, libera snapshot tras SubStr y libera temporal tras HexToNum. Sin nuevo runtime/ownership/RC ni paso del préstamo a funciones arbitrarias.

Gate23: dos fuentes x cinco modos=10exactas frescas, dos balances cero, ocho rechazos perfil y tres límites.149/137rondas, hex upper/lower/vacío/inválido, substring positivo/negativo/cero/fuera de bounds, counts negativos y bounds aritméticos. Rechazos call/escritura en bound y escape a función. Fuente/hash,hbmk2/hash,argv/cwd,rc/stdout/stderr separados. No se afirma handler no-string Dyn: la ruta SubStr anterior mantiene su límite fatal nombrado.

108suites nativas previas completas conciliadas, incluidos ATokens gate68 y Dyn bitops42. Rust104, LLVM21exactas frescas, Linux1177stdout/golden, PE emisión1912PASS/22conocidas/0FAIL, negativos622 mismos16desajustes, censo57/1041. big5_gen avanza hasta FOR con slot n Dyn línea87. uc16_gen mantiene @Dyn en área sharing/RC aparcada. Sin original nuevo cerrado, velocidad o política numérica/RC.

Árbol Harbour extraído sin git, commit no verificado; ORACLE.txt conserva versión/hash hbmk2. Sin binarios/objetos/assembly desechable ni push/publicación/workflows.

python tests/foreach-hex-slice/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

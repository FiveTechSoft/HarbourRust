# hb_base64Decode estándar canónico acotado

MIT propio sobrecb9e3910. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada ni cambio.diff. Decoder assembly escrito aquí, sin copiar runtime Harbour. Harbour upstream solo oráculo. Su árbol no tiene git, commit fuente no verificado; hash hbmk2 incluido.

Linux nativo ordinario sin threads/macros/blocks/shared arrays. Un argumento typed string (incluye temporal) o variable Dyn con string en runtime. Resultado owned independiente; snapshot de entrada liberado, no mueve variable original. FOR EACH permite observación decoder del valor sin almacenar préstamo; mutadores de colección siguen rechazo. Reconoce también observadores hoja del formatter dentro de wrappers de salida simpleio.ch, sin permitir mutación ni calls de argumento del formatter.

Solo base64 estándar canónico con longitud múltiplo de4, padding final correcto de0/1/2 signos, alfabeto A-Z/a-z/0-9/+/ y bits sobrantes cero. Vacío admitido. NUL/bytes altos/whitespace/unpadded/URL-safe/padding interno o excesivo/bits no canónicos fallan explícitamente en runtime con Limit y rc1. Harbour admite algunas entradas laxas con comportamiento distinto: se midió el hueco, no se afirma equivalencia fuera del subconjunto ni se cuenta su rechazo como salida Harbour. Fallo fatal no pretende semántica de ErrorBlock ni balance cero de esa ruta.

Gate90 final:5 fuentes por5 modos =25 exactas frescas Harbour;5 balances finales cero;20 rechazos de perfil;10 límites de compilación;30 límites runtime explícitos (15 fuentes por2 modos). Cuatro fuentes propias: cadenas vacías, RFC4648,256 bytes roundtrip,44 vectores deterministas de0..513 bytes, owned/string/Dyn, retorno, FOR EACH array. Quinta es tests/base64.prg upstream INTACTO con include simpleio.ch real, hash de entrada, build/run oráculo separados, stdout/rc/stderr exactos por5 modos y balance cero. Por tanto cierre de ESE original, no del decoder completo. Prueba SEQUENCE/error nueva no afirmada.

Los rechazos @/iif/inline := ocurren en límites anteriores identificados, no se presentan como comprobaciones nuevas del decoder. PRIVATE activa macro y se rechaza. Los comandos de balance del original usan un wrapper que añade -I al compilador, no modifica el PRG. Los intentos previos de gate con includes o expectativas de diagnóstico incorrectos no cuentan como PASS.

Regresión115 suites previas reconciliadas por nombre y SHA del compilador donde existe; Rust106; LLVM21 exactas frescas; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 mismos18 exactos; censo58/1041, única admisión nueva tests/base64.prg. Sin afirmación de velocidad. RC/objetos y división numérica siguen aparcados. Sin push/publicación/workflows.

python tests/base64-decode/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

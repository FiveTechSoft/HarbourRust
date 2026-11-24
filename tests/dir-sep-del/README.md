# hb_DirSepDel Linux

MIT propio sobre7fc92ffd0f3a71ad3793c490b29735bfeb9416c4. Programas MIT de Julio Ponce solo especificaciones, sin implementación copiada ni cambio.diff. Harbour upstream oráculo fresco; árbol sin git, commit fuente no verificado, hash hbmk2 incluido.

Un string tipado, Linux x86-64 nativo ordinario sin threads/macros. Elimina bytes slash finales conservando raíces / y //. No interpreta backslash como separador Linux. Copia owned independiente incluso si no cambia. Procesa bytes contados, incluidos NUL interiores, medido con Harbour. Variables se prestan y mantienen; argumentos temporales string se liberan tras la copia. No normaliza separadores interiores ni resuelve paths, no toca filesystem/RC/objetos.

Gate25:2 fuentes propias intactas por5 modos=10 exactas frescas Harbour,2 balances cero,8 rechazos perfil,5 límites. Vacío, /,//,///,/////,múltiples slash finales,slash interior,backslash,espacios,drive-like y NUL;owned Lower/concatenación,variable repetida,retorno y composición con hb_DirSepAdd. Solo entrada string tipada, no Dyn ni conversión de tipos.

Regresión121 suites nativas previas reconciliadas por nombre y118 registros SHA del compilador donde existe. Rust106,LLVM21 exactas frescas,Linux1177 stdout/golden,PE solo emisión1912PASS/22conocidas/0FAIL,negativos622 mismos18 exactos,censo58/1041 sin cambios. Sin cierre original, sin medición de velocidad. RC/objetos y división numérica siguen aparcados. Sin push/publicación/workflows/rebase.

Incidencia de infraestructura: una llamada de regresión excedió el tiempo del comando y mató el global parcial; Linux,censo,PE y Rust se repitieron completos. Un primer reintento LLVM encontró directorio existente, no se contó; LLVM repetido en directorio nuevo dio21 exactas. Solo resultados completos finales sustentan los recuentos.

python tests/dir-sep-del/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

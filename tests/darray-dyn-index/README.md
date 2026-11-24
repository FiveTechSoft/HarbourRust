# Índice Dyn variable en store DArr

MIT propio sobre24d056978c83c39e61624837a44bdb95fcbad86f. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada ni cambio.diff. Harbour upstream es oráculo.

Linux nativo ordinario: a[index] := value para root tipado DArr, con index variable Dyn. Usa la ruta ya existente Int(Dyn) para extraer enteros tags0/9 exactamente y truncar float hacia cero. Rechaza NIL/string/logical mediante el error de tipo existente, luego comprueba bounds1..len. No modifica el helper general dyn_to_i64 ni los reads/roots distintos. RHS sigue evaluado antes del índice y el guard existente protege el valor pendiente en errores recuperables. Sin nuevo formato de celdas ni política división/RC.

No admite nuevo índice Dyn calculado/call, índice F64 tipado, root fixed/string-array ni perfiles Windows/Mach-O/LLVM. Los contextos shared/macro quedan fuera de esta nueva ruta. Que se trunque el índice no permite almacenar resultados fraccionarios en celdas integer.

Gate63: seis fuentes x cinco modos =30 ejecuciones exactas frescas, seis balances finales cero,24rechazos de perfil y tres rechazos de forma.257/139/137/131/127rondas, entero, Dyn RHS, copia/reemplazo de strings, RHS con efecto antes del fallo de índice, NIL/logical/string, bounds,1.99/2.01/3.9,-0.99/-1.9/4.01 y100000000000000000000.5. Errores probados con BEGIN SEQUENCE WITH explícito en ambas ejecuciones, no se afirma igualdad del handler predeterminado. Fuente/hash,hbmk2/hash,argv/cwd,rc/stdout/stderr separados.

El primer prototipo solo abría el checker y conservaba dyn_to_i64. Falló prueba fresca: Harbour acepta Dyn1.5 como índice1 y ese helper lo rechazaba. Se retiró sin commit; /tmp/ddi-rejected-experiment contiene el patch no aplicado y evidencia. Este incremento reemplaza esa conversión localmente por Int(Dyn), y scalar-errors ahora coincide. Las falsas pruebas negativas con inline assignment/i+0 se corrigieron: ya son I64 y no prueban el límite de Dyn calculado; el caso final usa retorno Dyn de función.

Regresión final completa:104suites nativas previas conciliadas, Rust104, LLVM21 exactas frescas, Linux1177stdout/golden, PE emisión1912PASS/22conocidas/0FAIL, negativos622 con mismos16desajustes, censo57/1041. big5_gen sigue rechazado, ahora préstamo de cLine en llamada fuera del observador admitido línea60. Ningún original nuevo cerrado; no velocidad ni RC. Regresiones del prototipo retirado son parciales y no cuentan como éxito de este incremento.

Árbol Harbour extraído sin git, commit no verificado; ORACLE.txt conserva versión/hash hbmk2. Archivo sin ejecutables/objetos/assembly desechable. Sin push/publicación/workflows.

python tests/darray-dyn-index/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

# Índice de store desde celda DArr prestada

MIT propio sobre85a92daa5f18f74873dfcd6cee6435121145aa3a. Programas MIT de Julio Ponce solo especificaciones, sin implementación copiada ni cambio.diff. Harbour upstream es oráculo.

Forma Linux nativo ordinario: a[src[leaf]]:=rhs con target/src tipados DArr y leaf literal/variable. No llamadas/stores dentro de las direcciones. RHS se evalúa primero según la ruta existente y no puede mencionar src (límite conservador incluso cuando esa lectura sería segura): así no puede consumir su owner antes del índice. Root target conserva sus comprobaciones existentes contra moves. El valor de celda se toma prestado, no se copia ni libera. Int(Dyn) se factoriza en conversión de par ya cargado; se usa para índice interno Dyn y para valor externo. Trunca floats hacia cero, rechaza otros tags y comprueba ambos bounds. No modifica lecturas generales, helper dyn_to_i64, política RC ni formato de celdas. Es una ampliación de store, NO de read: el diagnóstico big5 atribuido a line89 provenía del store calculado siguiente.

Gate75:7 fuentes intactas Harbour por5 modos =35 comparaciones exactas frescas;7 balances estrictos cero;28 rechazos de perfil;5 límites. Enteros, self-index, índice interno Dyn fraccional, RHS owned/effects, NIL/logical/string y bounds recuperables. Casos1.99/2.01/3.9, negativos y valor fuera de i64, heredados de la prueba de conversión medida. BEGIN SEQUENCE WITH explícito en ambos oráculos de error, no paridad del handler predeterminado. Fuentes/hash, hash hbmk2, argv/cwd y rc/stdout/stderr separados. Los límites cubren calls, Set interno, fixed target y RHS que menciona source.

Regresión del compilador final:111 suites nativas previas reconciliadas por nombre; Rust106; LLVM21 exactas frescas; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 mismos18 exactos. Censo57/1041. big5_gen llega a @Dyn, territorio de sharing/RC aparcado igual que uc16_gen; no se abre ni se cierra ningún original. Sin afirmación de velocidad.

Se conservan límites de balance conocidos en suites previas, incluido método/control I64 DELTA2 de FOR Dyn; no son balance cero nuevo. Regresiones intermedias anteriores al guard RHS no se usan como evidencia final. Instrumentación temporal para localizar el checker se retiró antes del cambio; no está en el commit. Árbol Harbour sin git, commit fuente no verificado. Sin push/publicación/workflows.

python tests/darray-cell-index/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

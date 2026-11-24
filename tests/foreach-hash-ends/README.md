# Hash FOR EACH __enumIsFirst/__enumIsLast

MIT propio sobrec9c2ca84a0dbab6b104da7218568070314ad19b6. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada ni cambio.diff. Harbour upstream oráculo fresco; árbol sin git, commit fuente no verificado, hash hbmk2 incluido.

Getters sin argumentos del iterador hash léxicamente activo y readonly, Linux nativo ordinario sin threads/macros/blocks/shared arrays. Devuelven Bool por comparación del índice oculto contra1 o longitud oculta. Sin allocation/transferencia/lifetime nuevo; utiliza la pila léxica hash existente para no tomar un hash exterior si un loop array interior reutiliza el nombre. No añade setters, enumValue, enumBase, DESCEND ni soporte de objetos o arrays para estos dos getters.

Gate46:4 fuentes intactas propias por5 modos=20 exactas Harbour;4 balances finales cero;16 rechazos de perfil;6 límites. Hash3 elementos, vacío, singleton, nested nombres distintos con LOOP/EXIT, nested hash con mismo nombre y recuperación del getter exterior al salir. Límites outside,array,args,shadow-array,mutación de hash,captura. Captura falla en límite codeblock existente, no se presenta como protección nueva. La colección sigue protegida contra mutadores por el análisis anterior.

Regresión119 suites previas reconciliadas por nombre y SHA del compilador donde existe, incluida local-array-declaration C2 gate42; Rust106,LLVM21 exactas frescas,Linux1177 stdout/golden,PE solo emisión1912PASS/22conocidas/0FAIL,negativos622 mismos18 exactos,censo58/1041 sin cambios. Sin cierre original nuevo ni afirmación de velocidad. RC/objetos y división numérica siguen aparcados. Sin push/publicación/workflows/rebase.

python tests/foreach-hash-ends/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

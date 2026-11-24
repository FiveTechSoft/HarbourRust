# Getter __enumKey de FOR EACH hash activo, revisión C2

MIT propio sobre184304122947131d6f01f11eb0d17553a2d48c1c. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada ni cambio.diff. Harbour upstream es oráculo.

Linux nativo ordinario: getter :__enumKey / :__enumKey() del iterador Dyn readonly de un hash activo. Devuelve una COPIA owned StrOwn de la clave mediante hbc_strcpy, no un préstamo. Las rutas existentes de salida, asignación, retorno y consumidor string liberan/mueven esa copia. Stack léxico específico registra TODOS los iteradores con marca hash para que un loop array interno con el mismo nombre no use el hash exterior por error. No cambia la representación hash ni la política RC. Otros perfiles/shared/macro/blocks, setters y argumentos quedan fuera.

Gate45:3 fuentes intactas Harbour por5 modos =15 comparaciones exactas frescas;3 balances finales cero;12 rechazos de perfil;15 límites. Clave vacía, orden, nested distintos con LOOP/EXIT, copia guardada tras hb_HClear(owner), retorno desde función con hash local y consumidores hb_base64Encode/Len. Límites outside, array, args, captura y shadow-array de mismo nombre. ValType de getter directo sigue rechazo existente: el primer intento de fixture lo encontró y se retiró esa expresión, no se amplió ValType ni se cuenta el intento como PASS. Comandos/cwd, inputs/hash, hash hbmk2 y rc/stdout/stderr separados.

Regresión final112 suites nativas previas por nombre; Rust106; LLVM21 exactas frescas; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 mismos18 exactos; censo57/1041. base64.prg avanza desde __enumKey a unknown hb_strformat, no se cierra. Big5/uc16 @Dyn y demás RC siguen aparcados. Sin afirmación de velocidad.

El árbol Harbour no tiene git, commit fuente no verificado. Sin push/publicación/workflows. Paquete reducido de texto, sin binarios/objetos/assembly desechable.

python tests/foreach-enumkey/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

C2 halló hueco real previo en protección de colección: Stmt::HClear/HDel/HSet y demás mutadores hash caían en default true de foreach_coll_untouched. Se añaden rechazos explícitos para clear/delete/delat/fill/set/case/merge/copy; la ruta expresión también rechaza mutadores de hash y recorre .AND./.OR./.NOT./Send, byref y captura. Nueve fixtures nuevos de mutación en cuerpo con getter posterior, incluido hb_HSetDef bajo .AND., comprueban el mensaje de colección no modificable. No se afirma que el análisis previo ya los cubría.

Claves numéricas quedan rechazo explícito string-only, compartiendo el guard existente de hb_HKeys/HKeyAt: getter no devuelve bytes de key codificado ni afirma tipos numéricos. Fixture inserta h[1]:=2 antes del loop para alcanzar realmente ese guard; el intento literal {1=>2} se rechazaba antes en parser/tipo y no probaba esa ruta. No se añade soporte numérico.

Paquete C2 acumulado desde18430412 incluye2b3afacc y este fix como commits nuevos, sin rebase. Regresión final de C2112 suites/Rust106/LLVM21/Linux1177/PE1912-22-0/negativos622 mismos18/censo57-1041. Gate final /tmp/ekc2-gate3 (rutas locales solo para reproducir evidencia). Paquetes/regresiones intermedias no sustituyen evidencia final.

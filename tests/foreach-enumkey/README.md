# Getter __enumKey de FOR EACH hash activo

MIT propio sobre184304122947131d6f01f11eb0d17553a2d48c1c. Programas MIT de Julio Ponce solo especificaciones; sin implementación copiada ni cambio.diff. Harbour upstream es oráculo.

Linux nativo ordinario: getter :__enumKey / :__enumKey() del iterador Dyn readonly de un hash activo. Devuelve una COPIA owned StrOwn de la clave mediante hbc_strcpy, no un préstamo. Las rutas existentes de salida, asignación, retorno y consumidor string liberan/mueven esa copia. Stack léxico específico registra TODOS los iteradores con marca hash para que un loop array interno con el mismo nombre no use el hash exterior por error. No cambia la representación hash ni la política RC. Otros perfiles/shared/macro/blocks, setters y argumentos quedan fuera.

Gate35:3 fuentes intactas Harbour por5 modos =15 comparaciones exactas frescas;3 balances finales cero;12 rechazos de perfil;5 límites. Clave vacía, orden, nested distintos con LOOP/EXIT, copia guardada tras hb_HClear(owner), retorno desde función con hash local y consumidores hb_base64Encode/Len. Límites outside, array, args, captura y shadow-array de mismo nombre. ValType de getter directo sigue rechazo existente: el primer intento de fixture lo encontró y se retiró esa expresión, no se amplió ValType ni se cuenta el intento como PASS. Comandos/cwd, inputs/hash, hash hbmk2 y rc/stdout/stderr separados.

Regresión final112 suites nativas previas por nombre; Rust106; LLVM21 exactas frescas; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 mismos18 exactos; censo57/1041. base64.prg avanza desde __enumKey a unknown hb_strformat, no se cierra. Big5/uc16 @Dyn y demás RC siguen aparcados. Sin afirmación de velocidad.

El árbol Harbour no tiene git, commit fuente no verificado. Sin push/publicación/workflows. Paquete reducido de texto, sin binarios/objetos/assembly desechable.

python tests/foreach-enumkey/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

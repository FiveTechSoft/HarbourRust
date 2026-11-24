# hb_ATokens prestado del iterador

MIT propio sobre7f2790880f1452e2233fd35c2d6d409dfca88b83. Programas MIT de Julio Ponce solo como especificaciones, no implementación copiada/cambio.diff. Harbour upstream es oráculo.

Linux nativo ordinario: hb_ATokens(variable Dyn readonly del iterador, separador string literal), exactamente dos argumentos. La comprobación runtime acepta tag string2/4 y toma prestados sus bytes solo durante tokenizado; resultado array string propio. No hay separador calculado/argumento posterior que pueda mutar el owner o lanzar entre préstamo y uso. No se admite LOCAL Dyn ordinario ni se cambia RC/modelo numérico. La prueba de préstamos permite asignar ese resultado propio a otro local existente, sin almacenar el valor prestado ni capturarlo.

Gate20: dos fuentes x cinco modos=10 exactas frescas, dos balances finales cero, seis rechazos de perfil y dos rechazos de forma.137 rondas de líneas con tokens/vacíos y73 rondas de elementos no string que disparan error recuperable; array destino anterior permanece válido. El harness de error usa BEGIN SEQUENCE WITH {|b|Break(b)}, explícito tanto en oráculo como nativo. Primer intento sin WITH colgó el handler por defecto de Harbour y no se cuenta como PASS. Fuente/hash, hbmk2/hash, comando/cwd y rc/stdout/stderr separados.

101 suites previas completas; Rust104,LLVM21frescas,Linux1177stdout/golden,PE solo emisión1912PASS/22conocidas/0FAIL,neg622exactamente16desajustes previos,censo57/1041. uc16_gen avanza a type mismatch al asignar resultado a aline inicialmente NIL. big5_gen mantiene hb_At tipado. No original nuevo cerrado ni afirmación de velocidad. Rust inicial agotó disco, se conservaron logs y el reintento completo PASS tras eliminar solo caché/ELFs/objetos generados. Ningún fallo se cuenta como éxito.

Árbol Harbour sin git, commit no verificado; ORACLE.txt registra versión/hash hbmk2. Paquete sin ejecutables/objetos/assembly desechable. Sin push/publicación/workflows.

python tests/foreach-atokens/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

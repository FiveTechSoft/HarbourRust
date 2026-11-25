# Empty prestado de FOR EACH

MIT propio sobre2ebd49f1aa9ec10bf1f32b367f84c2355bdf6c40. Julio Ponce: programas MIT usados solo como especificaciones; no implementación copiada ni cambio.diff. Harbour upstream es oráculo.

Empty(x) se admite para variable Dyn readonly de iteración en Linux nativo ordinario sin macros/threads. Usa el helper escalar ya medido por timestamp, sin activarlo globalmente. No posee ni libera x, no admite temporales propios ni Empty de un LOCAL Dyn ordinario. Los comportamientos DBF/timestamp previos conservan prioridad. La prueba de préstamos permite solo Empty(variable exacta) como observación inmediata en output. No abre llamadas/almacenamiento/capturas arbitrarias ni RC/modelo numérico.

Gate19: dos fuentes x cinco modos=10 comparaciones exactas frescas, dos balances finales cero, seis rechazos de perfil, un rechazo de LOCAL Dyn. Cubre NIL,0,1,-1,lógicos, strings de tokens vacíos/blancos/no vacíos y73 rondas de lectura de células; los valores externos del iterador siguen restaurados. Fuente/hash, hbmk2/hash, comando/cwd y rc/stdout/stderr separados. Intentos anteriores rechazaron fixtures fuera del subconjunto, incluido literal heterogéneo/computado y declaraciones tardías; se conservan sin contar como éxito.

100 suites previas completas con compilador final; Rust104; LLVM21frescas; Linux1177stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 exactamente16desajustes previos; censo57/1041. uc16_gen avanza al rechazo de hb_ATokens con argumento Dyn, big5_gen conserva hb_At tipado. No nuevo original cerrado, velocidad ni RC. Un lote previo antes del ajuste final no se cuenta como la regresión final, repetida completa.

Árbol Harbour sin git, commit no verificado; ORACLE.txt conserva versión/hash hbmk2. Sin publicación/push/workflows. Paquete sin ejecutables/objetos/assembly desechable.

python tests/foreach-empty/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

## C2 follow-up for754426b5 scalar-literal LOCAL admission

754426b5intentionally admits Empty on LOCALDyn whose stores are all literal
scalars. Existing unchangedlimit-local.prg(LOCALx:=NIL,x:="a",Empty(x))is
a real newly admitted fixture under that exact rule,not genericDyn. Its
old filename is preserved for traceability,but gate now explicitly routes
that one fixture to5freshHarbourcomparisons+strictzero+3profile rejections.
All otherlimit-prefixfixtures remain negative. Newlimit-computed-local
usesUpper("a")and must still rejectgenericDyn,retaining an adjacent frontier.
No source rewriting of oldfixture,no compiler change or relaxed assertion.
Currentgate28=15exact+3zero+9profileREJ+1computedDynREJ.
This is fixtureadmission,not new upstreamoriginal closure. Historicalgate19
above described the earliercompiler and is superseded here. JulioPonceMIT
specifications credited,no implementation/cambio.diff copied. NoASort,
numericdivision,RC/objectpolicy,workflow,push,publication,rebase.

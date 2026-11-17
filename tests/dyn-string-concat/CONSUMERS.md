# Inventario de consumidores del resultado StrOwn

El resultado de Dyn/string entra por los consumidores StrOwn existentes.
Auditoria posterior al revisor: las rutas de DATA sinSTATIC y Break tenian
fugas reales, se reprodujeron antes del fix y ahora tienen controlesN1/500/1000.
No basta la paridad de stdout para afirmar propiedad correcta.

## Rutas y evidencia

| Consumidor | Contrato de este corte | Gate |
| --- | --- | --- |
| QOut/QQOut/OutStd/OutErr, print | consume temporal, sin consumir sus operandosDyn | consumers.py canales, N1/500/1000; oracle principal |
| LOCAL/assign StrOwn, assign Dyn | mueve el resultado fresco; overwrite libera el viejo | check.py local/grow/selfDyn/chain |
| STATIC persistente string, RefStrOwn/@ | conserva copia/propiedad segun la ruta existente; @ directo probado | consumers.py byref-store; root module-static-owned |
| DATA store externo, Self:store, INIT scalar | DATA clona a propiedad propia; el temporal fresco se libera siempre, sin condicion STATIC | check.py nueveformas DATA, incluido Self:Touch; baseline3 igual al control |
| Break(expresion), throw a catch | transfiere StrOwn fresco, literal copia, variable move+null | check.py dosordenesBreak con e:=NIL; oracle break_result |
| User function typedstring, Dyn argument | transferencia/copia del boundary existente | consumers.py user-arg ydyn-arg |
| Method y constructor stringargument | misma transferencia del call existente | consumers.py method-arg/constructor-arg; NIL-aware con Dynleaf rechazado por gate existente |
| return, resultado descartado | transfiere al caller; discard libera | consumers.py return/discard |
| Str+Str o Dyn/Str concat anidado | copia ambos y libera temporales | check.py chains/nested; sigue abierto el temporal interno antiguo que lanza antes de completar RHS |
| Comparacion, $ | borra temporales despues de comparar | consumers.py compare/contains |
| IIF stringbranch | branch seleccionado entregaowned normal | consumers.py iif |
| SWITCH selector string | libera selector temporal | consumers.py switch |
| FOR EACH directo sobre concat | rechazo nombrado previo: requiere variable o functionresult | consumers.py foreach-result negativo |
| DArrS cellstore/AAdd | mueve owned al array; overwrite/shrink libera | consumers.py array-store/array-add |
| Dynarray AFill | clona por celda y libera fuente temporal | consumers.py array-fill |
| Sharedmodulearray store/AAdd | rechazo previo: no acepta StrOwn fresco en esa ruta | consumers.py negativos ambos |
| Hashkey en HSet/HGet/HDel | clona o toma prestado y libera temporal | consumers.py hash-key/hash-get/hash-del |
| Hashliteral key/value, arrayliteral ownedexpresion | rechazo previo | consumers.py hash-literal/array-literal |
| PUBLIC/MEMVAR store | toma temporal y libera tras boundary existente | consumers.py public-store |
| CExtend EXTERNAL args | rechazo NUEVO explicito para este productor, tambien anidado | consumers.py external/external-nested; no se afirma marshalling libre de fugas |
| Blockcapture/commaexpr ownedtail | rechazos previos | consumers.py block-result/sequence |
| ValType/HB_ISSTRING productor directo | rechazo previo de expresion no medida | consumers.py dosnegativos |
| Numeric/date/container-only builtins y otros slots incompatibles | typechecker previo, no se ensancha ninguna firma | root negatives; PEcompilegate |

## Builtins que reciben strings

Se probaron con contador actual/controlN1/500/1000: Len, Empty, Upper, Lower,
Left, Right, AllTrim, SubStr, PadL/PadR/PadC, At/RAt, Val, StrTran, Asc,
AScan y File. Otros builtins mantienen sus guardas/cleanup de StrOwn existentes;
no se afirma haber ejecutado cada combinacion posible de builtin, aridad y
expresion con efectos. El rootmanifest y gates previos se repiten, pero no
sustituyen esa limitacion. Un consumidor nuevo requiere su propia prueba.

consumers.py contiene149filas: rutas admitidas se miden con control de la
misma estructura, N1/500/1000 y delta0 (o2 del pool de clase para metodos y
canales). Las rutas negativas se verifican por rc1 y diagnostico esperado,
no por ausencia de DELTA. Todas las fuentes y raws se preservan. check.py
agrega93filas de memoria:66simples delta0 y27DATA baseline3.

No se promete cleanup de una funcion que lanza desde dentro del cuerpo,
ni cleanup general de temporales de un RHS antiguo que falla a medio evaluar,
ni de argumentos previos si otro argumento o receiver falla. Los paresbase/new
de esos limites siguen separados de las rutas equilibradas. Tampoco se han
implementado Dyn+Dyn, DIRMAKE o INKEY. No ampliar estas mediciones a todoStrOwn.

## Orden de validacion CExtend

La guarda deproductores usa expr_ty solo DESPUES de type_expr de TODOSlos
argumentos. Elcandidato9fb04404 violaba esteprecondicion: unknown/IIFmalformado/
Min0/Eval0/forwardreturn dabanpanic101. Se reprodujeron antesdelcambio.
validation.py ejecuta13programasdefrontend:10paresdirecto/envuelto con
diagnosticorc1identico, unargumentoposteriorinvalido queganaprecedencia,
forwardDynreturn conlimitenombrado yforwardStrreturn queemiteasmcorrecta.
No se consideran elpanic nirechazogenerico comoresultadoaceptable.

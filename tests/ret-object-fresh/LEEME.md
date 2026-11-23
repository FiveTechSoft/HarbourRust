# RETURN de objeto fresco: transferir, no retener de nuevo

Reparación propia MIT sobre24fd8472, independiente de AScan y Bin. No incorpora
el main posterior. Harbour es sólo ejecutable oráculo externo.

Un resultado Obj de Call/Send ya trae una referencia propia para el consumidor.
Retenerlo otra vez al hacer RETURN deja una referencia sin dueño. El Ret ahora
usa obj_fresh ya existente para transferir esa referencia. Variables locales,
parámetros y Self prestados siguen reteniéndose antes del epílogo. No cambia
admisión, ABI, epílogos, Cmp, Bin, trace, runtime de objetos, LLVM ni workflows.
La decisión es común a los destinos existentes, sin añadir código de plataforma.
Mac se comprueba como emisión ASM, no ejecución nativa.

Antes de editar: factories, relay, método fresco, método relay y byref muestran
11bloques pendientes tras1503iteraciones y warmup3 en nuestros probes directos.
Los bloques son del pool, no una asignación por objeto. Local/parámetro/Self
prestados ya daban0. Los mismos controles dan0 con el prototipo.

Gates durables:
- check.py:13fuentes x5modos Linux exactos contra Harbour, más13base.
- safety.py:13formas x1/503/1503iteraciones x5modos con0pendientes, más atribución
  base. Un objeto nuevo pisa campos de otro slot antes de leer resultado y dueño;
  se comprueban valor, string e identidad para detectar retorno colgante.
- errors.py:5transiciones x4modos, salida/error exactos base/final y0pendientes
  en1503transiciones capturadas. Incluye throw antes del Ret, throw del consumidor,
  finally antes del retorno, rethrow numérico y retorno desde catch.
- mutants.py:3mutantes reales del Ret,2sobre-retención y1sin retain prestado.
  Todos requieren compiler/program build0 y run0; fallo de build o crash no cuenta.
- guard_selftest.py:4proxies del gate, nunca mutantes del producto.
- limits.py:4rechazos iguales y4destinos con emisión válida. Secuencias de objeto,
  RETURN dentro de TRY y nuevo observador polimórfico de objeto fresco siguen
  fuera. No se cambia su admisión para esconder un problema de ownership.

Límite separado: rethrow de un string capturado ya pierde un bloque por vuelta
sin esta reparación; el primer probe lo conserva como historial y no lo anuncia
como0. El gate de transición usa rethrow numérico, no pretende arreglar el
ownership de la excepción string. Tampoco repara AAdd/DATA string, fecha ValType,
ni Bin con RHS que lanza: son paquetes separados.

Cierre exige builds optimizados postcommit idénticos, regresión completa,
NEG LIST,censo y cambios ASM documentados con raw y hashes. Ninguna ejecución
de este directorio autoriza publicar o integrar en main.

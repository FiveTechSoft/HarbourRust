# Concatenacion con un operando Dyn

Corte acotado sobre base `0ec46d86cc7361e5bd3655a96f1ce7a6b93ae793`.
Codigo y pruebas propios MIT. Harbour se usa solo como ejecutable oracle externo;
no se incorpora codigo GPL. El oracle disponible es Harbour3.2.1dev
r2610242111, no Harbour4.

## Causa

Un LOCAL sin inicializador conserva tipo Dyn aunque despues reciba un string.
Por eso `cDIR + "\\" + cMONAT` fallaba en main: no habia despacho runtime
para Dyn/string. El error aritmetico del foro corresponde a un diagnostico
anterior; la base actual ya rechazaba esta combinacion por nombre.

`x` dinamica como indice no era el problema. Tampoco `y` implicita del FOR:
los probes aislados compilan y corren en ambos compiladores. Inicializar
cDIR/cMONAT como strings sorteaba el limite, pero no era una correccion
semantica del compilador.

## Contrato del corte

Se admite `Str/StrOwn + Dyn` y `Dyn + Str/StrOwn`; resultado StrOwn.
Solo los tags2/4 de string son validos. Los dos operandos se evaluan una vez,
de izquierda a derecha, incluso cuando el primero tiene tipo runtime invalido.
Se toma una copia propia antes de evaluar el siguiente: una reasignacion,
resize de array o cambio de DATA no invalida el snapshot anterior.

Las copias y temporales se liberan despues de copiar el resultado y antes de
lanzar `Argument error: +` para un valor no-string. Bajo un TRY ya activo,
un landing pad interno libera el snapshot izquierdo si la evaluacion derecha
lanza o llama Break. Propaga la misma excepcion, sin consumirla. Fuera de TRY
no agrega entradas al stack de handlers. El resultado usa la ruta StrOwn
normal de asignacion, return y consumidores. `s := s + Dyn` ya no puede
saltar esta comprobacion pasando un tag a `hbc_strgrow` como si fuera puntero.

No cambia Dyn+Dyn, la aritmetica numerica, el pin de fecha vacia, las politicas
de QOut, workflows, ni las funciones de filesystem/input.

## Gate reproducible

    python3 tests/dyn-string-concat/check.py --compiler /path/hbc \
      --hbmk2 /path/hbmk2 --wine /path/wine --tree SHA --output NEW_DIRECTORY

19 programas,38comparaciones byte-exact con oracle fresco en Linux/Wine.
22 formas simples mas9stores DATA por N1/500/1000:93controles actual/control,186ejecuciones
con contadores reales y parser fail-closed. Las66mediciones simples exigen delta0; las27deDATA exigen delta3 constante
igual al control (pool/template de clase), nunca crecimiento porN. Todas exigen, salida y retorno exactos. `e := NIL` despues de cada catch evita medir
el limite previo de overwrite de CatchBind en vez del snapshot de +.
El rebind string por @ se mide fuera de TRY: la especializacion de llamadas
por referencia dentro de TRY tiene un fallo de inventario previo, no reparado
aqui. El resto del gate mantiene TRY para probar el landing pad nuevo.

Fixtures `forum_paths` conservan los LOCAL dinamicos y y implicita del original;
solo sustituyen las llamadas no soportadas a DIRMAKE/INKEY por salida textual.
No prueban creacion de directorios. Los bytes esperados vienen del oracle,
no de una captura usada para esconder diferencias.

La anterior negativa `t_dyn_str_concat` pasa a positiva. Tambien el probe de
clases `neg15_dyn_concat`, cuyo nombre se conserva por trazabilidad. Inventario
root1257ejecutables; total nativo esperado1313. Clases27ejecutables+16rechazos.
El runner se actualiza en el mismo corte y mantiene los tests de inventario
real/truncado para ambos targets.

## Limites abiertos, no exitos

- Dyn+Dyn con strings conserva la ruta numerica previa y falla. Requiere otro
  corte de despacho runtime y contrato de resultado dinamico.
- DIRMAKE no existe aun en este compilador. El original compila en el parser
  Harbour, pero el oracle local no tiene libhbct instalada para enlazarlo.
- El unwind general de frames sigue abierto. Un callee que reserva Space y
  luego lanza pierde ese local: deltaN tanto en base como en este corte.
- Un RHS estatico parcialmente construido, `Space(7)+boom()`, pierde su propio
  temporal si boom lanza. Agregar `d + (...)` no agrega fugas: deltaN identico
  al RHS solo en base. El landing pad nuevo libera el snapshot d, no arregla
  los temporales internos de la ruta estatica antigua.
- Devolver un Dyn-array ya lanza dentro del callee antes de llegar a + y pierde
  ese frame: deltaN en ambos. El control corregido declara xDyn para evitar
  confundir ese limite con una incompatibilidad estatica del destino.
- Reutilizar `catch e` sin soltar el Break string anterior produce deltaN-1
  en ambos. No se cambia CatchBind aqui.
- @ dentro de TRY puede emitir una llamada a especializacion ausente incluso
  con Str+Str en base. No se atribuye ese fallo a esta concatenacion.
- Descripcion-string en catch, no Error objectHarbour; failure-mode registrado.
  La profundidad maxima del stack de handlers sigue256, compartida con TRY.

Los raws y comparaciones base/new de los limites se entregan por separado del
gate verde acotado. No se afirma cleanup general ni cierre total del programa
del foro. ARM64/Intel locales solo prueban emision. El revisor y ejecucion
macOS nativa siguen siendo necesarios antes de publicar.

## Siguientes cortes propuestos

1. DIRMAKE/hbct: pequeno-medio, un ciclo separado. Hace falta oracle hbct
   enlazable, medir retorno0/-1 y errores (existente, parent ausente, permisos,
   argumento invalido), Linux/Windows/Darwin, limpieza temporal y paridad de
   separadores. No hay helper mkdir en el runtime actual. No basta un alias.
2. Dyn+Dyn: medio-alto, al menos otro ciclo de diseno y gates. El resultado
   puede ser numero o string, por lo que toca el tipo del resultado, tags,
   formato numerico/DBF y consumidores, ademas de propiedad y errores. Mantener
   casos numericos exactos es parte del coste. No se mezcla con DIRMAKE.

Son estimaciones de alcance, no compromisos de tiempo ni autorizacion para
implementar esos cortes.

Revision posterior al revisor: el paquete9b8d14e4 esta retirado. Se corrige
la fuga real DATA sinSTATIC (cg_data_value no condiciona el drop a STATIC) y
Break transfiere StrOwn fresco en vez de clonarlo y perderlo. Los dos se
reprodujeron primero conN1/500/1000 y control. Ver CONSUMERS.md y consumers.py
para inventario y gate ampliado. CExtend rechaza temporalDyn/string directo
o anidado; materializar en local primero. No se cambia su marshalling general.

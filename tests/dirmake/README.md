# DIRMAKE: corte POSIX acotado

Base: `871b8636b03f1170d7da526f6e019bad81c5b8dc`.
Codigo y pruebas propios MIT. Harbour se usa solo como ejecutable externo;
no se incorpora codigo GPL. Oracle disponible: Harbour 3.2.1dev r2610242111,
revision externa `4a01714e17a75594f14b9678359c5bb6747fb0c9`, no Harbour 4.

## Contrato

- Backend ordinario Linux y Darwin Intel/ARM64. Windows y LLVM se rechazan
  por nombre antes de emitir codigo. No hay CreateDirectoryW ni gate PE nuevo.
- Cero o un argumento escalar: Str, StrOwn, Dyn, i64, logical, f64 y Date.
  No-argumento/NIL/no-string produce -2. El argumento se evalua una sola vez,
  incluso si no es string. Dyn admite strings runtime tags 2/4; otros tags
  producen -2. Los agregados estaticos y argumentos extra se rechazan.
- Retorno i64: 0 si crea el directorio, negativo del errno NATIVO si falla.
  No normaliza errno entre Linux y Darwin. No es un contrato 0/-1.
- Un solo mkdir, modo 0777 sujeto al umask del proceso. No crea parents.
  Backslash es literal en POSIX; separadores, symlinks, permisos y path limits
  pertenecen al sistema operativo. Embedded NUL termina el path.
- No integra FError, SET DEFAULT ni SET PATH. No cambia Dyn+Dyn ni INKEY.

El oracle Windows externo previo muestra errores diferentes (-183/-3), pero
no se implementa Windows en este corte. En el oracle Linux se midieron, entre
otros, EEXIST -17, ENOENT -2, ENOTDIR -20 y ENAMETOOLONG -36.
No se atribuyen esos numeros particulares a Darwin sin ejecucion nativa.

## Implementacion y ownership

La base rechazaba DIRMAKE como unknown function. Se registra como builtin,
se valida su argumento antes de consultar tipos post-check y se conserva el
prestamo en apply_moves. El resultado numerico no introduce ownership nuevo.

Los strings del compilador son counted strings, no necesariamente C strings.
Un helper propio reserva len+1 con hbc_stralloc (que reserva solo len+16 de
cabecera, sin garantia de byte 0), copia con rep movsb, escribe el terminador
NUL explicito, ejecuta mkdir
Linux 83 y libera el snapshot preservando el resultado. Los backends Darwin
traducen a mkdir 136 y conservan su tratamiento existente de carry/errno.
Referencia ABI consultada: https://github.com/apple-oss-distributions/xnu/blob/main/bsd/kern/syscalls.master
No se copia implementacion XNU, solo se verifica el numero y la firma ABI.

El callsite libera temporales StrOwn; los nombres StrOwn se prestan.
Dyn usa cg_data_value; si el Dyn es dueño (dyn_expr_owned) se libera con
cg_concat_drop, que llama hrobj_release en objetos tag13 (identity(o)); si no,
con cg_dyn_stack_release. Antes de la correccion el owner del objeto se perdia. No se reclama reparar retornos Dyn-array ni el unwind
general de callees, que son limites heredados. Si el unico argumento lanza,
no existe aun snapshot del helper que limpiar. Esto se mide con Break en un
producer sin locales owned; no prueba unwind general de frames ajenos.

## Gates

`check.py` exige --hbmk2 y --hbct externos. Genera fixtures propios y usa
cwd desechable separado por ejecutable. Compara stdout, stderr, exit y arbol
filesystem (incluidos permisos) con el oracle Linux, sin normalizacion.
Total 179 checks, desglose medido en results.json:

- 16 casos filesystem contra oracle (incluye page-lengths y cache-poison).
- 32 emisiones Darwin, NO ejecuciones nativas.
- 11 rechazos: 7 de validacion (aridad, agregados, malformado/unknown/forward)
  y 4 perfiles Windows/LLVM.
- 114 rutas ownership: 19 formas x N=1/500/1000 x actual/control. Incluye
  literal, temp/nombre StrOwn, Dyn literal/owned/float/return, concat Dyn-string
  existente, input desde array/hash, module STATIC, IIF, DATA, object-identity
  (DIRMAKE(identity(o)) con Dyn dueño tag13), wrapper-return y producer que
  lanza Break. 17 formas tienen delta 0 en actual y control. DATA y
  object-identity tienen delta fijo 2 en ambos, con N=1/500/1000: es el
  baseline heredado del fixture de objetos, no una fuga por llamada DIRMAKE.
- 6 ejecuciones poison-*: tras hbc_stralloc el clon se rellena con 'y'; solo el
  NUL explicito mantiene los nombres exactos (len 1, 3, 4079, 4080, 4081, 4095).
  No fuerza una lectura fuera de mapping; prueba que no se depende del relleno.

`check_native.py` es un gate de ejecucion contra el OS local, NO oracle
Harbour. Ejecuta seis casos (paths/owned/scalar x umask 022/077), exige bytes,
exit, stderr y filesystem identicos al reference generado con os.mkdir.
Ejemplo para el puente, sobre un host Mac real:

```
python3 tests/dirmake/check_native.py --compiler ./hbc --target macho-arm64 --tree SHA --output /tmp/dirmake-native-arm
python3 tests/dirmake/check_native.py --compiler ./hbc --target macho --tree SHA --output /tmp/dirmake-native-intel
```

No agrega filas al manifest raiz. Se mantiene el inventario 1257 ejecutables
/ 1313 filas totales y el gate dedicado se entrega aparte. No se llama verde
nativo a la mera emision. El reporte del paquete registra los gates realmente
ejecutados y su SHA/tree, no este documento como sustituto de los raws.

# FILE(), SET DEFAULT y SET PATH

Incremento nativo Linux x86-64 y Windows x86-64. La implementación es propia,
freestanding y sin dependencia de Harbour ni libc en el ejecutable generado.
Harbour 3.2, commit `694428e1c12f726675b19324d62167fa77d68185`, es el oráculo.

## Contrato medido

`FILE(cPath)` devuelve un lógico. No equivale a `access()` ni a una simple
prueba de existencia:

- Excluye directorios, también los enlaces que apuntan a directorios.
- Linux distingue mayúsculas. Admite `*`, `?`, corchetes, rangos, negación,
  escapes, clases POSIX y equivalencias/collating symbols de un carácter
  en el locale C. El comodín se aplica al último componente, no a directorios.
- Windows usa la búsqueda Win32, incluida su comparación de nombres y sus
  reglas DOS de comodines. Excluye también los atributos hidden y system.
  Las cadenas se interpretan con la página predeterminada EN/CP437 de Harbour,
  no como UTF-8. Esto importa para nombres no ASCII.
- En Linux se siguen enlaces. Un enlace colgante o cíclico cuenta como archivo
  si el propio enlace existe. Windows conserva la conducta medida de Win32.
- Una ruta explícita evita DEFAULT y PATH. Un nombre sin directorio busca
  primero en DEFAULT y después en cada entrada de PATH, en orden.
- DEFAULT vacío significa cwd. Después de cambiar DEFAULT no hay una búsqueda
  adicional automática en cwd. Una entrada vacía de PATH sí representa cwd,
  incluso `SET PATH TO ""`. Antes de ejecutar SET PATH no existe esa entrada.
- El separador de listas es `:` en Linux y `;` en Windows. No se intercambian.
- Se conserva el truncado medido de Harbour: entrada de nombre hasta 263 bytes,
  nombre combinado hasta 262 bytes, cadenas SET hasta 65535 bytes; NUL termina
  la ruta. Una ruta larga no se rechaza simplemente por longitud.
- NIL, lógicos, enteros, floats y fechas devuelven `.F.`; se evalúa el argumento.
  Los temporales y cadenas Dyn se liberan con el protocolo existente.

Formas de comando admitidas:

```harbour
SET DEFAULT TO default/subdir
SET DEFAULT TO "default"
SET DEFAULT TO (cDirectory)
SET DEFAULT TO
SET PATH TO missing;search
SET PATH TO "missing:search"
SET PATH TO (cSearchPath)
SET PATH TO
```

Una variable requiere paréntesis, como en Harbour. DEFAULT/PATH con una
expresión NIL reinicia a cadena vacía; un escalar no string/no NIL conserva
el valor anterior. SET PATH conserva los `;` de una lista sin comillas,
en vez de interpretarlos como separadores de sentencias.

## Límites explícitos

- SET DEFAULT/PATH y operaciones DBF en el mismo programa se rechazan. La capa
  DBF todavía tiene resolución de rutas separada. No se afirma que SET afecte
  al RDD. La combinación con threads también se rechaza: este estado es de
  programa y todavía no tiene la semántica de herencia por hilo de Harbour.
- FILE acepta strings y los escalares indicados. Arrays, objetos y codeblocks
  se rechazan por tipo en este incremento, aunque Harbour devuelve falso para
  esos argumentos. No se afirma compatibilidad universal de tipos.
- SET mediante macro `&` se rechaza; usar una expresión string entre paréntesis.
  No se añade la función genérica `Set()` ni selección dinámica de codepage.
- Mach-O y el backend LLVM experimental tienen rechazo explícito.
- Las pruebas ejecutadas aquí son Wine; hay un reporte externo acotado abajo.
  La publicación Windows necesita además ese segundo ejecutor.
- El matcher Linux cubre el locale C de la referencia. No se añade semántica
  de colación multicaracter ni selección de locale del proceso Harbour.

## Fuentes y regeneración

`runtime/hrfile.c` es la fuente propia. `tests/generate_file_asm.py` genera los
blobs y sus recipes con versión del compilador, flags y hashes SHA-256.
La regeneración necesita GCC Linux y MinGW64, no la ejecución normal de hbc.

```sh
HR_MINGW_CC=x86_64-w64-mingw32-gcc python3 tests/generate_file_asm.py
```

Los adaptadores conservan la ABI interna y el shadow space Win64. Solo se
emite el runtime cuando aparece FILE o un comando de rutas. Los ejecutables
sin estas llamadas no cambian por la presencia de los blobs en el compilador.

## Reporte nativo aportado por colaborador

`tests/file-native-windows/` guarda un reporte de FILE() en Windows real: fecha 16-nov, base a77bdd22, NTFS, 35
llamadas comparadas entre PE/COFF de hbc y Harbour, con salida identica byte a
byte. Contribuido por Julio Ponce, licencia MIT. No es nuestra gate y no sustituye las pruebas
Wine. Limites: no hay logs originales; no cubre SETDEFAULT, PATH ni CP437.
Sin codigo de runtime.

## Pruebas

La suite tiene su propio manifiesto, porque construye un filesystem aislado
con enlaces, archivos ocultos, nombres especiales y rutas límite. Los expected
son bytes del oráculo, con CRLF de Windows conservado mediante `.gitattributes`.
El gate nunca actualiza expected ni normaliza salidas.

```sh
python3 tests/file-compat/check.py --compiler ./hbc --output /tmp/file-new-run \
  --wine /path/to/wine
python3 tests/file-compat/check_match.py
```

Para contrastar otra vez con Harbour se añaden `--hbmk2 /path/to/hbmk2`,
`--oracle-commit 694428e1c12f726675b19324d62167fa77d68185` y, si está instalado
su runtime cross, `--oracle-windows`. En ese caso se proporciona
`HB_CCPREFIX=x86_64-w64-mingw32-`. Para el ensamblador externo Windows se usan
PATH y `HBC_MINGW_LIB` como en el compilador. El gate fija LC_ALL=C.UTF-8 para
que Wine traduzca de manera determinista los nombres del filesystem anfitrión.
Esto no cambia el locale C del matcher libc de la sonda auxiliar.

El resultado medido es 56 checks: 10 ejecuciones Harbour, 24 ejecuciones hbc
con ambos ensambladores/plataformas, 14 rechazos, cuatro rechazos de backends
y cuatro ejecuciones de salida opcional. La sonda auxiliar contrasta 1.995.500
pares patrón/nombre (7.675 patrones) con fnmatch del locale C.

La salida opcional no es nueva: ya existía en v0.11.4. Se verificaron los assets
reales Linux y Windows: `MixedTest.prg` crea `MixedTest` o `MixedTest.exe`,
respectivamente. El nombre explícito conserva prioridad.

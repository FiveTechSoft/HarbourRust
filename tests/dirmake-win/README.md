# DIRMAKE en Windows PE (bajo Wine)

Base 5ea21e80. Codigo y pruebas propios MIT; Harbour 3.2.1dev r2610242111 + hbct (mingw) solo como oraculo externo, no Harbour 4.

Contrato Windows: un solo `CreateDirectoryW(path, NULL)`. El string contado se corta en el primer NUL y se
ensancha con la pagina OEM (`MultiByteToWideChar(CP_OEMCP)`), la que el oraculo midio. Devuelve 0 o `-GetLastError`.
Sin argumento, NIL o no-string: -3 (ERROR_PATH_NOT_FOUND; en Linux es -2). El argumento se evalua una vez.
No integra FError, SET DEFAULT ni SET PATH; no crea parents; separadores, nombres reservados y limites los decide el SO.
LLVM sigue rechazado por nombre.

Medido contra el oraculo: ya existe -183, padre inexistente -3, "" -3, "." -183, `parent\child` y `/` 0, barra final 0,
espacio/punto final (Windows los recorta), bytes >= 0x80, Chr(1) -123, `* ? a:b` -123 / -2, longitud 255 ok, 256/259/260 -2, unidad inexistente -3.

Limites honestos: solo Wine (no Windows nativo). Bajo locale C Wine rechaza no-ASCII con -2 tanto en el oraculo como en
CreateDirectoryW directo; el gate corre con LC_ALL=C.UTF-8 y con C. La pagina OEM nativa depende del sistema (no medida).
Sin gate PE de memoria nativo: el balance allocs/frees se mide con asm parcheado + ld de mingw (mismo codigo emitido) y un mutante
sin `hbc_freestr` que el guard debe detectar. Sin ejecucion en Windows real.

Gate: `python3 tests/dirmake-win/check.py --compiler HBC --hbmk2 HBMK2 --hbct-win hbct-win.a --mingw-lib DIR --tree SHA --output DIR`.

## Limits and conversion failures (stubbed, choices not oracle-measured)

- Path length is counted as 64-bit; MultiByteToWideChar takes int32. A counted length above 0x7ffffffe returns -206
  (ERROR_FILENAME_EXCED_RANGE) before any allocation and creates nothing. Stubs patch the length register in the emitted
  asm (2^32+1 and 0x7fffffff); no GiB is reserved. The old build fails both stubs.
- If MultiByteToWideChar returns 0 for a non-empty path, DIRMAKE returns -3, frees the snapshot and does not call
  CreateDirectoryW. The stub forces a 0 return. The old build also prints -3 here (an empty path gives -3 from
  CreateDirectoryW), so this stub proves the result and the memory balance, not the skipped call.
- The oracle (Harbour 3.2.1dev + hbct, mingw, Wine) cannot be driven into a conversion failure or a >2 GiB path, so -206 and
  -3 for these two cases are documented choices, not oracle measurements.

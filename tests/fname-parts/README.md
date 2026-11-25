# hb_FNameExt / hb_FNameName / hb_FNameDir Linux

MIT propio sobre048576ea. Programas MIT de Julio Ponce solo especificaciones, sin implementación copiada ni cambio.diff. Oráculo Harbour fresco; árbol sin git, commit fuente no verificado; hash hbmk2 incluido.

Una expresión string tipada, Linux x86-64 nativo ordinario sin threads/macros. Tres getters de partes del path, sin consultar filesystem. En esta plataforma solo slash separa directorios. Último punto del basename separa extensión, salvo primer punto de basename. Extensión incluye el punto. Dotfiles sin otro punto conservan nombre completo y extensión vacía. Dir incluye slash final. Backslash y colon son bytes ordinarios Linux.

Corta en primer NUL y limita el prefijo a263 bytes, según oráculo medido (no se presenta como constante universal de Harbour ni otros targets). Escanea el prefijo, no el string truncado después del split. Copia owned independiente del segmento, incluso vacío. Variables se prestan y mantienen, temporales string se liberan. Sin cambio RC/objetos.

Gate35:3 fuentes propias intactas por5 modos=15 exactas frescas,3 balances cero,12 rechazos perfil,5 límites. Vacío,nombre simple,múltiples puntos,dotfiles,punto final,slash,backslash,colon,espacios,NUL interior;longitudes255/259/260/261/262/263/264/511/4096,Lower/concatenación,variable repetida,retorno,param string y composición DirSepAdd. No Dyn ni coerción de argumentos. No se afirma compatibilidad Windows/locale/paths de sistema no medidos.

Regresión122 suites previas reconciliadas por nombre y119 registros SHA del compilador donde existe;Rust106,LLVM21 frescas exactas,Linux1177 stdout/golden,PE solo emisión1912PASS/22conocidas/0FAIL,negativos622 mismos18 exactos,censo58/1041 sin cambios. Sin cierre original ni velocidad nueva. RC/objetos y división numérica siguen aparcados. Sin push/publicación/workflows/rebase.

python tests/fname-parts/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

Boundary follow-up on aaba4f6f,tests only: boundary-paths.prg adds slash
positions259..264,extension positions and directory prefixes near the cap,
NUL before/after cap,UTF-8 byte paths,all-slash oversized paths. This is
byte behavior of the measured Linux oracle,not Unicode normalization or
character-counting support. Gate expands35 to45:20exact,4strict-zero,
16profile rejects,5limits. Compiler unchanged13f71f9fabf999778014a6b829efab171c2e4d55eb1201d0b9d314d3c6830e6b.

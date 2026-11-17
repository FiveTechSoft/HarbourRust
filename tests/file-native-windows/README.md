# FILE() en Windows nativo: reporte de colaborador

Contribuido por Julio Ponce, licencia MIT. No es una gate de este repositorio
ni sustituye los tests Wine de `tests/file-compat/`. No contiene codigo de runtime.

Contenido: `file-exists.prg`, tres salidas `*.stdout` con CRLF crudo (Harbour,
PE principal, COFF principal; identicas, sha256 882f28ce...), `comprobar.py`
(repetidor para Windows real; solo cambiaron las rutas relativas al aplanar
el directorio) y `validacion.json` (metadatos del reporte).

Reporte: fecha 16-nov, base a77bdd22, Windows 11 x64 con NTFS, oraculo Harbour
3.2.0dev MSVC; 35 llamadas FILE comparadas PE/COFF contra Harbour, byte a byte.
Limites: no se aportaron logs originales;
no cubre SET DEFAULT, PATH ni CP437 ni nombres no ASCII.

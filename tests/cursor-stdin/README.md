# Cursor y teclado bloqueante Linux GTSTD

Codigo y pruebas propios MIT. Harbour externo fijado por corpus/harbour-694428e1-inventory.json
se usa solamente como oraculo ejecutable. No se copia ni enlaza codigo suyo.

Solo Linux x86-64 ordinario. SetCursor() devuelve modo actual, inicialmente1.
SetCursor(entero tipado) devuelve modo anterior y guarda0..4; fuera de rango
normaliza1. Se admiten expresiones con efectos, evaluadas una sola vez.
NIL, double, string, dinamicos y otros perfiles se rechazan antes de emitir.
No controla un cursor visual del terminal. Este es estado GTSTD.

Inkey(0), incluso0.0 literal numerico plegado, espera un byte stdin no NUL.
Entrega bytes0x01..0xff sin interpretar ESC ni Unicode. EOF, stdin cerrado
y errores no son teclas: espera y reintenta con pausas10ms. No hay deadline.
No hay raw/termios ni soporte de terminal interactivo mas alla de PTY cocinado.
La ruta anterior Inkey()/timeout positivo no cambia. Windows0 sigue rechazado.

check.py --compiler HBC --hbmk2 HBMK2 --harbour-core CORE --output DIR

Compara el original cursor.prg sin cambios (stdin12345), estado/limites,
argumento con efecto y secuencias de bytes usando ELF interno y as/ld externo.
Comprueba espera con pipe abierto, NUL ignorado, EOF, PTY cocinado y rechazos.
Guarda capturas, rc, SHA del compiler y de cada fuente. El parche actualiza
solo dos rechazos del viejo gate Linux de Inkey: zero/zerof son positivos aqui.
No afirmar que los timeouts matados probaron un retorno correcto.

La directiva .globl _start del helper bloqueante mantiene el export en un
bloque vivo para as/ld cuando ya no se referencia hbc_inkey; no cambia prune.
EOF y NUL usan timeout y kill intencional, y se registran como espera, no exit0.
EOF no prueba EINTR ni la rama de error: esas ramas siguen sin sonda directa.

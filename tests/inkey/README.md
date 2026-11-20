# INKEY: corte Linux stdin acotado

Base: `fb30165b191da0a7519457d70bede59c0bfb02bc`.
Codigo y pruebas propios MIT. Harbour se usa solo como ejecutable externo
(oracle Harbour 3.2.1dev r2610242111, no Harbour 4); no se incorpora codigo GPL.

## Contrato

- Solo backend ordinario Linux x86-64, comportamiento GTSTD con stdin NO tty.
  Darwin (ambos), Windows y LLVM se rechazan por nombre antes de emitir.
- `INKEY()`: sondeo no bloqueante (poll de fd 0 con timeout 0) de un byte.
  Devuelve el byte 0..255 o 0 si no hay. Sin decodificar (UTF-8 es byte a byte).
- `INKEY(n)` con n literal numerico o expresion constante plegada (p. ej. `0.5+0.5`, probado contra el oracle con `inkey(0.1+0.1)`) de 0.01 a 86400 segundos: poll con timeout
  en ms (redondeo al ms). Devuelve el byte o 0. Con EOF, /dev/null, stdin
  cerrado o hangup se duerme solo el tiempo RESTANTE hasta un deadline CLOCK_MONOTONIC fijado a la entrada (un pipe que cierra a 0.2 s con timeout 1 s devuelve a 1.0 s, no a 1.2 s) y devuelve 0, como el oracle. poll, read y nanosleep se reintentan en EINTR con el tiempo restante.
- Retorno i64, sin ownership nuevo.
- Rechazados por nombre: INKEY(0), cero/negativos, NIL, no numericos (string,
  logico, array), timeout no constante (variable local, `INKEY(n)`, rechazado por nombre; una expresion constante plegada si se admite), literal < 0.01
  (el oracle espera para siempre), > 86400, mascara (2o arg) y 3+ args.
  INKEY(0) y similares bloquean para siempre en el oracle con EOF; no se
  reproduce ese cuelgue.
- No hay LASTKEY, NEXTKEY, KEYBOARD, SET KEY, typeahead, GTCGI (que devuelve 13
  fijo) ni modo raw/termios. En tty cocinado la entrada es por lineas (la
  tecla llega con Enter y el terminal hace eco); el oracle usa modo raw.

## Hechos del oracle (medidos, raws en el gate)

Con 1 arg, o >1 con el primero numerico, hay espera; con 0 args no. Un timeout
< 0.01 s se convierte en espera infinita; 0.01..0.019 mide ~0.02 s. INKEY con 3
args no compila en el oracle.

## Gate

`check.py --compiler HBC --output DIR --tree SHA --hbmk2 HBMK2` compara con el
oracle stdout/exit/stderr y el tiempo (tolerancia 0.35 s): 6 expresiones x 8
stdin (vacio, Z, AB, ESC, CRLF, LF, UTF-8, bytes ff/00) con stdin desde fichero,
secuencia de lecturas, /dev/null, stdin cerrado y pipe abierto con espera,
6 casos de deadline (pipe que cierra a 0.2/0.8 s con timeout 1 s, SIGSTOP/SIGCONT,
tecla diferida, pipe abierto sin datos; el build anterior falla con 1.2/1.8 s),
pty (tecla diferida con newline), 2 hangs del oracle bajo 0.01 s, 14 rechazos
de validacion y 6 perfiles rechazados. El forum original se ejecuta SIN
modificar con un script del paquete (stdin vacio: 10.0 s en ambos).

Limite: no hay forma de entregar una senal con handler a un programa compilado, asi que la rama EINTR del helper se revisa por codigo y no se ejercita por ejecucion; SIGSTOP/SIGCONT se mide y el kernel reinicia poll con el mismo deadline.

## Ampliacion cursor-stdin

INKEY(0) y (0.0), solo en Linux ordinario, ahora leen el siguiente byte no NUL
y esperan indefinidamente al EOF. La ruta de tiempos positivos no cambia.
Los antiguos rechazos zero/zerof se sustituyen por los casos bloqueantes
del gate tests/cursor-stdin/check.py. Windows sigue rechazando cero.

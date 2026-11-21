# Concatenación tipada: limpieza al lanzar el lado derecho

Implementación propia MIT sobre 24fd8472. No incorpora AScan e576 ni el delta posterior de main. Harbour sólo ejecutable oráculo externo.

## Reparación acotada

El camino tipado de string `+` conserva un temporal izquierdo fresco mientras evalúa el derecho. Antes, una excepción del derecho saltaba su liberación. Un guard local de expresión protege ese temporal únicamente bajo un TRY ya activo. En la captura libera ese propietario y propaga la misma excepción. Las concatenaciones anidadas limpian su propio temporal en orden. La evaluación izquierda y derecha permanece una sola vez y de izquierda a derecha.

Se selecciona Linux ordinario sin macros, DBF, externs ni threads; izquierdo StrOwn no variable, derecho Str/StrOwn con posible llamada/error. Otros caminos y admisión quedan iguales. Los caminos Dyn ya tienen sus propios snapshots y pads. Un literal o variable prestada izquierda no se libera por este guard. Arena-root conserva su flag y sus llamadas normales. No se modifican Ret, epílogos, Cmp, trace, runtime de objetos, LLVM ni workflows.

El guard no promete limpiar cualquier temporal de otro builtin situado dentro del derecho: cada emisor sigue siendo responsable de sus propios temporales. No arregla AAdd de string desde DATA escalar, retorno de objeto fresco ni ValType de fecha.

## Medición antes de editar

Doce fuentes propias, 113 capturas tras warmup3. Temporales izquierdos simples pierden 113 pendientes y dos concatenaciones pendientes pierden 226 en p11. Los controles literal/prestado/throw izquierdo ya tienen cero. Rechazo de compilación nunca se cuenta como divergencia funcional.

## Gates

- safety.py: quince formas, 1/503 iteraciones tras warmup3 y cinco modos. Cero pendientes con comprobaciones de propietarios tras sobrescribir caché. Base con pendientes heredados se registra por separado.
- check.py: dieciocho fuentes normales, rc/stdout/stderr exactos con Harbour en cinco modos más base. Sin normalización de salida.
- errors.py: valor de excepción, rethrow, finally, catch/finally interno en RHS, cruce de marcos y trazas, cuatro modos. Comparación exacta base/final, no equivalencia del diálogo de error de Harbour.
- mutants.py: dos mutantes reales de fuga (eliminar free de captura y desactivar ruta), uno de salida. Todos requieren compiler/program build0 y run0 antes de contar el fallo.
- guard_selftest.py: cuatro proxies sólo del gate, nunca mutantes del producto.

El cierre exige además builds optimizados postcommit idénticos, barrido completo y filas ASM cambiadas explícitas con ambos brutos y patches propios. No se anuncia integración ni publicación por producir este paquete local.

# IIf con NIL o arreglo vacío, vista opcional de sólo lectura

Implementación y pruebas propias MIT. Harbour se usa sólo como ejecutable externo.
No se leen, aplican ni traducen parches externos.

## Contrato acotado

En Linux ordinario, sin hilos, macros/MEMVAR ni extensiones C, se admite:

```harbour
FUNCTION Copia(aDatos)
   LOCAL a := IIf(aDatos == NIL, {}, aDatos)
RETURN Len(a)
```

También se admiten `=`, los operandos invertidos de la comparación y `!=` con
las ramas intercambiadas. El parámetro recibe una vista prestada. NIL u omisión
reciben un descriptor privado con clase 5; un arreglo real, incluso vacío,
conserva su descriptor normal. La selección convierte sólo el NIL a una vista
vacía de longitud cero, alojada en el marco de la función. No se crea una
asignación de heap para ese vacío: es inobservable dentro de este contrato,
porque el único uso admitido del resultado es `Len`.

Antes de inferir tipos se examina todo el cuerpo. El parámetro sólo puede
aparecer en esas inicializaciones LOCAL de nivel superior. Las variables
resultado sólo pueden aparecer como argumento directo de `Len`; ese entero
puede participar en cálculos, condiciones, salida o llamadas normales. No se
admiten modificación, índice, escape, copia, captura, reasignación ni envío
del arreglo a otra función. Los contadores de bucle tampoco pueden reemplazar
el parámetro ni el resultado. Los métodos y las funciones tomadas por referencia
no usan este ABI.

Las llamadas aceptan NIL explícito, omisión o una variable arreglo ordinaria.
El llamador mantiene la propiedad; el control de préstamos existente impide que
otro argumento mencione el mismo arreglo. No se amplía el cruce de arreglos por
Dyn. Las fuentes persistentes, temporales, `@`, objetos y escalares no-NIL
siguen cerradas. Tampoco se generaliza IIf entre dos arreglos cualesquiera.
Windows, Mach-O y LLVM mantienen sus límites anteriores.

## Pruebas

- `check.py`: 24 programas propios y, opcionalmente, p05 externo sin cambios;
  cinco modos Linux, comparación exacta de rc/stdout/stderr con Harbour. El
  compilador base debe rechazar cada forma nueva. No se normaliza la salida.
- `safety.py`: 31 rechazos de forma, siete perfiles excluidos y 15 mediciones
  propias de asignaciones pendientes, con tres iteraciones de calentamiento y
  1/17/503 iteraciones medidas. Cada iteración hace tres selecciones y conserva
  el arreglo original de dos cadenas. La suma debe ser 4*n y la diferencia de
  asignaciones pendientes cero. No es una comparación de memoria con Harbour.
- `mutants.py`: dos contrafactuales funcionales, selección invertida y longitud
  vacía incorrecta. Exigen build del compilador y del programa con rc0,
  ejecución rc0 y salida diferente del control recién construido. Un tercer
  contrafactual elimina la admisión y debe rechazar al compilar, por separado.
- `guard_selftest.py`: cuatro proxies del banco, no mutantes del producto.

Los intentos inválidos de preparación y sus repeticiones se conservan en la
entrega. Las pruebas no leen código fuente de Harbour. Los módulos Rust
contrafactuales se construyen de forma aislada, no sobre el árbol del producto.

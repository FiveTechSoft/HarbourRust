# Inferencia de parámetros bajo NOT de comparación

MIT propio sobrea22d0319a9e803a4c5253160b90e4b745ae48c56. Programas MIT de Julio Ponce solo especificaciones, sin implementación copiada ni cambio.diff. Harbour upstream oráculo, árbol sin git y commit fuente no verificado; hash hbmk2 incluido.

Fix de3 líneas en pin_vars: un contexto Bool no propaga Bool a los operandos de Expr::Cmp. La comparación ya produce Bool; su walk infiere sus operandos con sus propios tipos (incluido NIL que fija Dyn). Antes, !(s==NIL) intentaba fijar s como Bool antes de fijarlo Dyn, el pin fallaba y el checker posterior veía el placeholder I64, de ahí el engañoso Upper expects a string. No se amplía Upper, su ruta Dyn ya existía. !b sin comparación conserva evidencia lógica y el rechazo de string a parámetro lógico sigue probado.

Gate19:3 fuentes intactas propias por5 modos =15 exactas Harbour;3 balances finales cero;1 límite. Numéricos, comparación de strings con NIL, Upper solo en rama no-NIL, llamadas repetidas, .AND./.OR./NOT anidado y NOT de parámetro lógico. Sin nuevo soporte de runtime o perfil de salida. Los perfiles adicionales no se cuentan en gate específico.

Regresión116 suites previas reconciliadas por nombre y SHA del compilador donde figura; Rust106; LLVM21 exactas frescas; Linux1177 stdout/golden; PE solo emisión1912PASS/22conocidas/0FAIL; negativos622 mismos18 exactos; censo58/1041. Dos diagnósticos avanzan sin nuevas admisiones: directry.prg desde Upper a unknown Directory; src/rtl/einstv52.prg desde comparación a unknown ErrorNew. No se cierran esos originales. Sin afirmación de velocidad/RC/división numérica. Sin push/publicación/workflows.

python tests/not-parameter-pin/check.py --compiler target/release/hbc --hbmk2 /ruta/hbmk2 --spec-root /ruta/harbour --output /ruta/nueva

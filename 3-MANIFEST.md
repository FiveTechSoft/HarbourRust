# Corpus de sondas-oráculo Harbour (hk)

Las 99 fuentes `.prg` antes situadas en la raíz están ahora en [`tests/probes/legacy-hk/`](tests/probes/legacy-hk/README.md), conservando sus nombres numerados y sus bytes. Los identificadores hkNN de esta tabla son históricos; el índice enlaza cada identificador con su archivo real.

Cada hkNN.prg es un programa de contraste compilado con `hbmk2 hkNN.prg -gtstd -ohkNN` (Harbour 3.2.1dev). 
Salida de referencia: la de su ejecución headless (timeout 5s) con esa misma cadena, regenerada el 26 oct 2026 tras la pérdida del workspace. 
Estados: `verificado` = la salida regenerada coincide byte a byte con la medida publicada/citada en README.md o docs/BATTERY.md; 
`dialogo-sin-oraculo` = el programa abre el diálogo de error de Harbour y cuelga headless (modo de fallo registrado, NUNCA un oráculo); 
`medida-fresca` = fuente verbatim recuperada del transcript y re-ejecutada con la misma cadena; la medida original del transcript no se extrajo para contraste byte a byte en este lote; 
`borrador-superado` = fuente recuperada que ya no compila (borrador temprano superado por sondas posteriores).

Números sin fuente recuperable en el transcript: hk10, hk72, hk74, hk75 (planificados o creados fuera del registro; sus medidas, si las hubo, permanecen solo donde se citaron).

| sonda | estado | salida (escapada) |
|---|---|---|
| hk1 | borrador-superado | (no compila con hbmk2 actual) |
| hk100 | medida-fresca | \nuno\ndos\nuno\n |
| hk101 | medida-fresca | \n         2\nuno\n         0\ntres\n         3 |
| hk102 | medida-fresca | \n        42\n        44 |
| hk103 | medida-fresca | \n         2\n         2\n         2\n         2\nNIL\n        99\nNIL\nA\nU |
| hk104 | medida-fresca | \nV\nI1\nI2\nI3\nI4\n        99 |
| hk105 | medida-fresca | \n         2\n         3\n         8\n         1\n         7 |
| hk106 | medida-fresca | \nI1\nI2\nI3\nI4\n        99 |
| hk107 | medida-fresca | \n         5\n         2 |
| hk108 | medida-fresca | \nI1\nI2\nI3\nV\n         3\n         8 |
| hk109 | medida-fresca | \n         7\n         8\n         2\n         2\n         7 |
| hk11 | medida-fresca | \n         2\n         2\n         2 |
| hk110 | medida-fresca | \nI1\nI2\nI3\n         5\nNIL |
| hk111 | medida-fresca | \n        42\n        42 |
| hk112 | medida-fresca | \n         2\n         2\n         9\nNIL |
| hk113 | medida-fresca | \n\nsep\n         2 |
| hk114 | medida-fresca | \nA\nA\nA\nU\nN |
| hk115 | medida-fresca | \n         3\n         9\n         1\nNIL |
| hk116 | medida-fresca | \n         2\n        77\n        77 |
| hk117 | medida-fresca | \n>\nA\nA\nA\nU\nN\n< |
| hk118 | medida-fresca | \nA\nA\n         5\nNIL |
| hk119 | medida-fresca | \n         9\n         9\nNIL |
| hk12 | medida-fresca | \n         1\n         7 |
| hk120 | verificado | \n         4\n         3\nNIL |
| hk121 | verificado | \n         8\n         8\n         8\nNIL |
| hk122 | verificado | \n         5\nNIL\n         6\n         6 |
| hk123 | verificado | \n         7\n         7 |
| hk124 | verificado | \n.T.\n.F.\n.T.\n.F.\n.F.\n.F.\n.T.\n.T. |
| hk125 | dialogo-sin-oraculo | \n.T.\n.F.\n\n\n\n\n\n\n                   ����������������������������������������Ŀ\n                   �   Error BASE/1071  Argu [cuelga: diálogo] |
| hk126 | verificado | \n.T.\n.F.\n.T. |
| hk127 | medida-fresca | \n         2 |
| hk128 | verificado | \n.T.\n.F.\n.F.\n.F. |
| hk129 | verificado | \n.F.\n.F.\n.T.\n.F.\n.F. |
| hk13 | medida-fresca | \n         2\none\ntwo\n         4\nNIL |
| hk130 | verificado | \n.T.\n.F.\n.T. |
| hk131 | verificado | \n.T.\n.F. |
| hk14 | medida-fresca | \n         3\nnew\n         3\nNIL\n         2\none |
| hk15 | medida-fresca | \n         4\nx\nNIL |
| hk16 | medida-fresca | \n |
| hk17 | medida-fresca | \none\ntwo |
| hk18 | medida-fresca | \n         1\n         2 |
| hk19 | medida-fresca | \none\ntwo |
| hk2 | borrador-superado | (no compila con hbmk2 actual) |
| hk20 | medida-fresca | \n          5\n         5\n\n\n          7 |
| hk21 | medida-fresca | \n         5           6\n          5\nx  y |
| hk22 | medida-fresca | \nab\nab            5\n\n          9 |
| hk23 | medida-fresca | \n\n         2\n         1\n\n         2\n        10 |
| hk24 | medida-fresca | \nab\nab            3\n\n          4\n\n          8 |
| hk25 | medida-fresca | \nab\nab            5\ncd ab |
| hk26 | medida-fresca | \n        10\n        20\n        30\n         3\n        20\none\n         1\none |
| hk27 | medida-fresca | \none\nNIL\nNIL |
| hk28 | medida-fresca | \nafter empty\nafter empty hash\n         5\nafter exit\nNIL |
| hk29 | medida-fresca | \n         5\n         6\n         7\nafter natural\n        99 |
| hk3 | borrador-superado | (no compila con hbmk2 actual) |
| hk30 | medida-fresca | \n         5\nNIL\nNIL |
| hk31 | medida-fresca | \n         1\nNIL\n         3 |
| hk32 | medida-fresca | \n        10\n        12\nchanged |
| hk33 | medida-fresca | \ndistinta\nigual\nno-es-b |
| hk34 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n                   ����������������������������������������Ŀ\n                   �   Error BASE/1071  Argument e [cuelga: diálogo] |
| hk35 | medida-fresca | \nigual-a\nno-a\ndistinto-de-a |
| hk36 | medida-fresca | \nno-menor\nmenor-que-b |
| hk37 | medida-fresca | \ncorta-der-igual\nlarga-der-distinta\nexacta-igual |
| hk38 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n                  �����������������������������������������Ŀ\n                  �   Error BASE/1072  Argument er [cuelga: diálogo] |
| hk39 | medida-fresca | \n.F. .F. .T. .T.\n.F. .T. .T. .F.\n.T. .F. .F. .T. |
| hk4 | medida-fresca | \n         3\nbeta\nAlpha\ngamma |
| hk40 | medida-fresca | \n.F. .F. .T. .T.\n.T. .F. .T. .F.\n.F. .F. .T. .T.\n.F. .F. .T. .T. |
| hk41 | dialogo-sin-oraculo | \n.F. .F.\n\n\n\n\n\n\n\n                   ����������������������������������������Ŀ\n                   �   Error BASE/1073  Arg [cuelga: diálogo] |
| hk42 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n                   ����������������������������������������Ŀ\n                   �   Error BASE/1073  Argument e [cuelga: diálogo] |
| hk43 | medida-fresca | \n-- vs 'ab' --\n.F. .F. .T. .T.\n.F. .F. .T. .T.\n.F. .F. .T. .T.\n.F. .F. .T. .T.\n-- vs 'abc' --\n.F. .F.\n.T. .F.\n.F. .T.\n.T. .F.\n-- empty right --\n.F. .F. .T. |
| hk44 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n                   ����������������������������������������Ŀ\n                   �   Error BASE/1075  Argument e [cuelga: diálogo] |
| hk45 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n                  �����������������������������������������Ŀ\n                  �   Error BASE/1074  Argument er [cuelga: diálogo] |
| hk46 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n                  �����������������������������������������Ŀ\n                  �   Error BASE/1076  Argument er [cuelga: diálogo] |
| hk47 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n                   ����������������������������������������Ŀ\n                   �   Error BASE/1075  Argument e [cuelga: diálogo] |
| hk48 | medida-fresca | \n.F. .F. .T.\n.F. .F. .T. |
| hk49 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n                  �����������������������������������������Ŀ\n                  �   Error BASE/1074  Argument er [cuelga: diálogo] |
| hk5 | medida-fresca | \n         2\none\n         9 |
| hk50 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n                  �����������������������������������������Ŀ\n                  �   Error BASE/1076  Argument er [cuelga: diálogo] |
| hk51 | medida-fresca | \n-- 'ab' OP c --\n.T. .F. .T. .F.\n.F. .F. .T. .T.\n.T. .F. .T. .F.\n.T. .F. .T. .F.\n-- 'b' OP c --\n.F. .T.\n.F. .T.\n.F. .T.\n.F. .F. |
| hk52 | medida-fresca | \nb\na |
| hk53 | medida-fresca | \n         1\n         2\n         3\n         4 |
| hk54 | medida-fresca | \n         1\n         2\n         2 |
| hk55 | medida-fresca | \nb\nfin |
| hk56 | medida-fresca | \nret-a\nfin |
| hk57 | medida-fresca | \n        10         20 |
| hk58 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n             ���������������������������������������������������Ŀ\n             �   Error BASE/1068  Argument er [cuelga: diálogo] |
| hk59 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n             ���������������������������������������������������Ŀ\n             �   Error BASE/1068  Argument er [cuelga: diálogo] |
| hk6 | medida-fresca | \n         0 |
| hk60 | medida-fresca | \n         1\n         2\n         3\n         4 |
| hk61 | medida-fresca | \n         1\n         2\n         2\n         1 |
| hk62 | medida-fresca | \n         1\nfin |
| hk63 | dialogo-sin-oraculo | \n\n\n\n\n\n\n\n\n             ���������������������������������������������������Ŀ\n             �   Error BASE/1068  Argument er [cuelga: diálogo] |
| hk64 | medida-fresca | \neval\neval\n         1\n         2 |
| hk65 | medida-fresca | \n         1\n         3\n         2\nNIL |
| hk66 | medida-fresca | \n         2\n         5\n         6 |
| hk67 | medida-fresca | \neval\nval\n         2 |
| hk68 | medida-fresca | \n         2\nNIL\n.T. |
| hk69 | medida-fresca | \n         2\n         2\nNIL |
| hk7 | medida-fresca | \n         2\n         3\ntres\nnueva\ntwo\n         2\n         1 |
| hk70 | medida-fresca | \n        99 |
| hk71 | medida-fresca | \n |
| hk73 | medida-fresca | \n         2\n         1          2 |
| hk76 | medida-fresca | \n\n |
| hk77 | medida-fresca | \n |
| hk78 | medida-fresca | \n         3\n         9 |
| hk79 | medida-fresca | \n         3\n         7 |
| hk8 | medida-fresca | \n         2\nchanged\ntwo |
| hk80 | medida-fresca | \n        42 |
| hk81 | medida-fresca | \n        42 |
| hk82 | medida-fresca | \n        42 |
| hk83 | medida-fresca | \n        42 |
| hk84 | medida-fresca | \n          5\n         6\n |
| hk85 | medida-fresca | \nA\nA\nN |
| hk86 | medida-fresca | \n        99\n         2 |
| hk87 | medida-fresca | \n         1 |
| hk88 | medida-fresca | \nA\nA\nN\nN\nC\nU |
| hk89 | medida-fresca | \neval          1\nA\neval          2\nN |
| hk9 | medida-fresca | \nhola\nhola |
| hk90 | medida-fresca | \nA |
| hk91 | medida-fresca | \nU\nU |
| hk92 | medida-fresca | \nC\nN\nU\nU |
| hk93 | medida-fresca | \n         2\n         2\n         1\n         0 |
| hk94 | medida-fresca | \n         0\n         3\n         2\n         8 |
| hk95 | medida-fresca | \n         0\n        42 |
| hk96 | medida-fresca | \n         0\n         1\n         2 |
| hk97 | medida-fresca | \nA\nA\nN\nU\n         0 |
| hk98 | medida-fresca | \n         3\n         0\n        99\n         4 |
| hk99 | medida-fresca | \n         3\n         2\n        99\n         4 |

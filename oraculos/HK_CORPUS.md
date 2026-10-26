# Corpus consolidado de sondas-oráculo Harbour (hk)

Cada bloque ```` ```harbour hkNN ```` contiene el programa de contraste hkNN.prg VERBATIM
(compilar: `hbmk2 hkNN.prg -gtstd -ohkNN`, Harbour 3.2.1dev). Las salidas de referencia y
el estado de cada sonda están en MANIFEST.md (mismo directorio, cuando exista) y en la
tabla al final de este archivo. Extracción: cada bloque entre la línea ```harbour hkNN y
la línea ``` siguiente es el .prg byte a byte.

```harbour hk1
PROCEDURE Main()
   LOCAL h := {=>}
   LOCAL k
   h["beta"] := 1
   h["Alpha"] := 2
   h["gamma"] := 3
   k := HGetKeys(h)
   ? LEN(k)
   ? k[1]
   ? k[2]
   ? k[3]
RETURN
```

```harbour hk100
function main()
  local a := {}
  local x := ""
  AAdd(a, "uno")
  AAdd(a, "dos")
  for each x in a
    ? x
  next
  ? a[1]
  ? x
return NIL
```

```harbour hk101
function mut(x)
  ? len(x)
  ? x[1]
  x[1] := "tres"
  AAdd(x, "cuatro")
return 0
function main()
  local a := {}
  AAdd(a, "uno")
  AAdd(a, "dos")
  ? mut(a)
  ? a[1]
  ? len(a)
return NIL
```

```harbour hk102
function applyit(b, x)
  ? eval(b, x)
return eval(b, x + 1)
function main()
  local dup := {|v| v * 2}
  local r := applyit(dup, 21)
  ? r
return NIL
```

```harbour hk103
function main()
    local a := Array(2, 2, 2, 2)
    ? len(a)
    ? len(a[1])
    ? len(a[1,2])
    ? len(a[1,2,1])
    ? a[1,2,1,2]
    a[1,2,1,2] := 99
    ? a[1,2,1,2]
    ? a[2,1,2,1]
    ? valtype(a[1,2,1])
    ? valtype(a[1,2,1,1])
return nil
```

```harbour hk104
function v()
    ? "V"
return 99
function i1()
    ? "I1"
return 1
function i2()
    ? "I2"
return 2
function i3()
    ? "I3"
return 1
function i4()
    ? "I4"
return 2
function main()
    local a := Array(2, 2, 2, 2)
    a[i1(), i2(), i3(), i4()] := v()
    ? a[1, 2, 1, 2]
return nil
```

```harbour hk105
function main()
    local a := Array(2, 2, 2, 2)
    a[1,2,1,1] := 7
    ? len(a[1,2,1])
    AAdd(a[1,2,1], 8)
    ? len(a[1,2,1])
    ? a[1,2,1,3]
    ASize(a[1,2,1], 1)
    ? len(a[1,2,1])
    ? a[1,2,1,1]
return nil
```

```harbour hk106
function i1()
    ? "I1"
return 1
function i2()
    ? "I2"
return 2
function i3()
    ? "I3"
return 1
function i4()
    ? "I4"
return 2
function main()
    local a := Array(2, 2, 2, 2)
    a[1,2,1,2] := 99
    ? a[i1(), i2(), i3(), i4()]
return nil
```

```harbour hk107
function main()
    local a := Array(2, 2, 2, 2)
    a[1][2][1][2] := 5
    ? a[1][2][1][2]
    ? len(a[2][1][2])
return nil
```

```harbour hk108
function v()
    ? "V"
return 8
function i1()
    ? "I1"
return 1
function i2()
    ? "I2"
return 2
function i3()
    ? "I3"
return 1
function main()
    local a := Array(2, 2, 2, 2)
    AAdd(a[i1(), i2(), i3()], v())
    ? len(a[1, 2, 1])
    ? a[1, 2, 1, 3]
return nil
```

```harbour hk109
function main()
    local a := Array(2, 2, 2, 2)
    local x
    a[1, 2, 1, 1] := 7
    a[1, 2, 1, 2] := 8
    for each x in a[1, 2, 1]
        ? x
    next
    ? len(a[1, 2, 1])
    ? len(a)
    ? a[1, 2, 1, 1]
return nil
```

```harbour hk11
function main()
local h := {"one" => 1}
addkey(h)
? len(h)
? h["two"]
return nil

function addkey(p)
p["two"] := 2
? len(p)
return nil
```

```harbour hk110
function i1()
    ? "I1"
return 1
function i2()
    ? "I2"
return 2
function i3()
    ? "I3"
return 1
function main()
    local a := Array(2, 2, 2, 2)
    local x
    a[1, 2, 1, 1] := 5
    for each x in a[i1(), i2(), i3()]
        ? x
    next
return nil
```

```harbour hk111
function muta(a)
    a[1, 2, 1, 1] := 42
    ? a[1, 2, 1, 1]
return nil
function main()
    local a := Array(2, 2, 2, 2)
    muta(a)
    ? a[1, 2, 1, 1]
return nil
```

```harbour hk112
function mk()
    local a := Array(2, 2, 2, 2)
    a[2, 1, 2, 1] := 9
return a
function main()
    local b := mk()
    ? len(b)
    ? len(b[2, 1, 2])
    ? b[2, 1, 2, 1]
    ? b[1, 1, 1, 1]
return nil
```

```harbour hk113
function main()
    local a := Array(2, 2, 2, 2)
    ? a
    ? "sep"
    ? len(a)
return nil
```

```harbour hk114
function main()
    local a := Array(2, 2, 2, 2)
    ? ValType(a[1])
    ? ValType(a[1, 2])
    ? ValType(a[1, 2, 1])
    ? ValType(a[1, 2, 1, 1])
    a[1, 2, 1, 1] := 5
    ? ValType(a[1, 2, 1, 1])
return nil
```

```harbour hk115
function main()
    local a := Array(2, 2, 2)
    AAdd(a[1, 2], 9)
    ? len(a[1][2])
    ? a[1][2][3]
    ASize(a[1, 2], 1)
    ? len(a[1][2])
    ? a[1][2][1]
return nil
```

```harbour hk116
function main()
    local b := {1, 2}
    local a := {{9}, {8}}
    a[1] := b
    ? a[1][2]
    b[2] := 77
    ? a[1][2]
    ? b[2]
return nil
```

```harbour hk117
function main()
    local a := Array(2, 2, 2, 2)
    ? ">"
    ? ValType(a[1])
    ? ValType(a[1, 2])
    ? ValType(a[1, 2, 1])
    ? ValType(a[1, 2, 1, 1])
    a[1, 2, 1, 1] := 5
    ? ValType(a[1, 2, 1, 1])
    ? "<"
return nil
```

```harbour hk118
function main()
    local a := Array(2, 2, 2, 2)
    local x
    for each x in a[1, 2]
        ? ValType(x)
    next
    a[1, 2, 1, 1] := 5
    for each x in a[1, 2]
        ? x[1]
    next
return nil
```

```harbour hk119
function main()
    local a := Array(2, 2, 2, 2)
    local x
    for each x in a[1, 2]
        x[1] := 9
    next
    ? a[1, 2, 1, 1]
    ? a[1, 2, 2, 1]
    ? a[1, 1, 1, 1]
return nil
```

```harbour hk12
function main()
local h := mk()
? len(h)
? h["a"]
return nil

function mk()
local h := {"a" => 7}
return h
```

```harbour hk120
function main()
    local a := Array(2, 2, 2, 2)
    local x, y
    for each x in a[1, 2]
        for each y in a[1, 1]
            y[1] := 4
        next
        x[1] := 3
    next
    ? a[1, 1, 1, 1]
    ? a[1, 2, 1, 1]
    ? a[2, 1, 1, 1]
return nil
```

```harbour hk121
function main()
    local a := Array(2, 2, 2, 2)
    local x
    for each x in a[1, 2]
        x[1] := 8
        ? a[1, 2, 1, 1]
    next
    ? a[1, 2, 2, 1]
    ? a[1, 1, 1, 1]
return nil
```

```harbour hk122
function main()
    local a := Array(2, 2, 2, 2)
    local x, y
    for each x in a[1, 2]
        for each y in a[1, 1]
            y[1] := 5
            exit
        next
        x[1] := 6
    next
    ? a[1, 1, 1, 1]
    ? a[1, 1, 2, 1]
    ? a[1, 2, 1, 1]
    ? a[1, 2, 2, 1]
return nil
```

```harbour hk123
function main()
    local a := Array(2, 2, 2, 2)
    local x
    for each x in a[1, 2]
        x[1] := 7
    next
    for each x in a[1, 2]
        ? x[1]
    next
return nil
```

```harbour hk124
function main()
    ? 1 == 1
    ? 1 == 2
    ? "a" == "a"
    ? "a" == "a "
    ? "a " == "a"
    ? "a" = "a "
    ? "a " = "a"
    ? 1 = 1
return nil
```

```harbour hk125
function main()
    local a := {1, 2}
    local b := {1, 2}
    ? a == a
    ? a == b
    ? a = a
    ? a = b
return nil
```

```harbour hk126
function main()
    local a := Array(2)
    local b := Array(2)
    a[1] := 5
    b[1] := 5
    ? a == a
    ? a == b
    ? b == b
return nil
```

```harbour hk127
function main()
    ? 1 + 1
return nil
```

```harbour hk128
function main()
    ? NIL == NIL
    ? NIL == 1
    ? 1 == NIL
    ? NIL == ""
return nil
```

```harbour hk129
function main()
    local a := Array(2, 2)
    ? a[1] == NIL
    ? NIL == a[1]
    ? a[1][1] == NIL
    a[1][1] := 4
    ? a[1][1] == NIL
    ? a[1] == NIL
return nil
```

```harbour hk13
function main()
local h := {"one" => 1, "two" => 2, "tre" => 3}
local k := hb_HKeys(h)
ASize(k, 2)
? len(k)
? k[1]
? k[2]
ASize(k, 4)
? len(k)
? k[3]
return nil
```

```harbour hk130
function main()
    local a := Array(2, 2)
    local b := Array(2, 2)
    local c
    ? a == a
    ? a == b
    c := a
    ? a == c
return nil
```

```harbour hk131
function main()
    local x := {|n| n + 1}
    local y := {|n| n + 1}
    ? x == x
    ? x == y
return nil
```

```harbour hk14
function main()
local h := {"one" => 1}
local k := hb_HKeys(h)
ASize(k, 3)
? len(k)
k[3] := "new"
? k[3]
? len(k)
ASize(k, 5)
? k[4]
ASize(k, 2)
? len(k)
? k[1]
return nil
```

```harbour hk15
function main()
local h := {"one" => 1}
local k := hb_HKeys(h)
ASize(k, 3)
AAdd(k, "x")
? len(k)
? k[4]
? k[2]
return nil
```

```harbour hk16
function main()
local h := {"one" => 1, "two" => 2}
? h
return nil
```

```harbour hk17
function main()
local h := {"one" => 1, "two" => 2}
local k, a := hb_HKeys(h)
for each k in a
  ? k
next
return nil
```

```harbour hk18
function main()
local h := {"one" => 1, "two" => 2}
local v
for each v in h
  ? v
next
return nil
```

```harbour hk19
function main()
local h := {"one" => 1, "two" => 2}
local p
for each p in h:keys
  ? p
next
return nil
```

```harbour hk2
PROCEDURE Main()
   LOCAL h := {=>}
   LOCAL k
   h["one"] := 1
   h["one"] := 9
   h["ONE"] := 7
   k := HGetKeys(h)
   ? LEN(k)
   ? k[1]
   ? h[k[1]]
RETURN
```

```harbour hk20
function main()
local h := {"one" => 1}
local a := {1, 2}
? h, 5
? 5, h
? h, h
? a
? a, 7
return nil
```

```harbour hk21
function main()
local h := {"one" => 1}
? 5, h, 6
? h, 5, h
? "x", h, "y"
return nil
```

```harbour hk22
function main()
local s := {"a", "b"}
? "ab  "
? "ab  ", 5
? s
? s, 9
return nil
```

```harbour hk23
function main()
local h := {"one" => 1, "two" => 2}
local a := {10, 20}
? h
? len(h)
? h["one"]
? a
? len(a)
? a[1]
return nil
```

```harbour hk24
function main()
local x := "ab  "
local m := {{1}, {2}}
local e := {=>}
? x
? x, 3
? m
? m, 4
? e
? e, 8
return nil
```

```harbour hk25
function main()
local s := {"ab  ", "cd"}
? s[1]
? s[1], 5
? s[2], s[1]
return nil
```

```harbour hk26
function main()
local a := {10, 20, 30}
local h := {"one" => 1}
local k := hb_HKeys(h)
local x, c
for each x in a
    ? x
next
? len(a)
? a[2]
for each c in k
    ? c
next
? len(k)
? k[1]
return nil
```

```harbour hk27
function main()
local h := {"one" => 1}
local k := hb_HKeys(h)
local c
ASize(k, 3)
for each c in k
    ? c
next
return nil
```

```harbour hk28
function main()
local e := {}
local eh := {=>}
local a := {5, 6, 7}
local x
for each x in e
    ? "never"
next
? "after empty"
for each x in eh
    ? "neverh"
next
? "after empty hash"
for each x in a
    if x = 6
        exit
    endif
    ? x
next
? "after exit"
? x
return nil
```

```harbour hk29
function main()
local a := {5, 6, 7}
local x := 99
for each x in a
    ? x
next
? "after natural"
? x
return nil
```

```harbour hk3
PROCEDURE Main()
   LOCAL h := {=>}
   LOCAL k
   k := HGetKeys(h)
   ? LEN(k)
RETURN
```

```harbour hk30
function main()
local a := {5}
local x
ASize(a, 3)
for each x in a
    ? x
next
return nil
```

```harbour hk31
function main()
local h := {"a" => 1, "b" => NIL, "c" => 3}
local v
for each v in h
    ? v
next
return nil
```

```harbour hk32
function main()
local a := {5, 6}
local h := {"one" => 1}
local k := hb_HKeys(h)
local x, c
for each x in a
    x := x * 2
next
? a[1]
? a[2]
for each c in k
    c := "changed"
next
? k[1]
return nil
```

```harbour hk33
procedure main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c := ""
    for each c in k
        if c = "a"
            ? "igual"
        else
            ? "distinta"
        endif
        if c <> "b"
            ? "no-es-b"
        endif
    next
return
```

```harbour hk34
procedure main()
    local a := {1, 2}
    local x := 0
    for each x in a
        if x = "a"
            ? "igual-cadena"
        else
            ? "no-cadena"
        endif
    next
return
```

```harbour hk35
procedure main()
    local h := {"a" => 1}
    local k := hb_HKeys(h)
    local c := ""
    ASize(k, 2)
    for each c in k
        if c = "a"
            ? "igual-a"
        else
            ? "no-a"
        endif
        if c <> "a"
            ? "distinto-de-a"
        endif
    next
return
```

```harbour hk36
procedure main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c := ""
    for each c in k
        if c < "b"
            ? "menor-que-b"
        else
            ? "no-menor"
        endif
    next
return
```

```harbour hk37
procedure main()
    local k := hb_HKeys({"abc" => 1})
    local c := ""
    for each c in k
        if c = "a"
            ? "corta-der-igual"
        else
            ? "corta-der-distinta"
        endif
        if c = "abcd"
            ? "larga-der-igual"
        else
            ? "larga-der-distinta"
        endif
        if c = "abc"
            ? "exacta-igual"
        else
            ? "exacta-distinta"
        endif
    next
return
```

```harbour hk38
procedure main()
    local a := {1, 2}
    local x := 0
    for each x in a
        if x <> "a"
            ? "distinto"
        endif
    next
return
```

```harbour hk39
procedure main()
    local a := {"b", "a", "c"}
    local c := ""
    for each c in a
        ? c > "b", c < "b", c <= "b", c >= "b"
    next
return
```

```harbour hk4
PROCEDURE Main()
   LOCAL h := {=>}
   LOCAL k
   h["beta"] := 1
   h["Alpha"] := 2
   h["gamma"] := 3
   k := hb_HKeys(h)
   ? LEN(k)
   ? k[1]
   ? k[2]
   ? k[3]
RETURN
```

```harbour hk40
procedure main()
    local a := {"abc", "a", "abcd", "abc"}
    local c := ""
    for each c in a
        ? c < "abc", c > "abc", c <= "abc", c >= "abc"
    next
return
```

```harbour hk41
procedure main()
    local a
    local c := ""
    a := {}
    AAdd(a, "b")
    AAdd(a, NIL)
    a[2] := NIL
    for each c in a
        ? c < "b", c > "b"
    next
return
```

```harbour hk42
procedure main()
    local a := {10, 20}
    local c := ""
    for each c in a
        ? c < "b"
    next
return
```

```harbour hk43
procedure main()
    local a := {"abc", "ab", "abd", "abb"}
    local c := ""
    ? "-- vs 'ab' --"
    for each c in a
        ? c < "ab", c > "ab", c <= "ab", c >= "ab"
    next
    ? "-- vs 'abc' --"
    for each c in a
        ? c < "abc", c > "abc"
    next
    ? "-- empty right --"
    ? c > "", c < "", c = ""
return
```

```harbour hk44
procedure main()
    local a := {10}
    local c := ""
    for each c in a
        ? c > "b"
    next
return
```

```harbour hk45
procedure main()
    local a := {10}
    local c := ""
    for each c in a
        ? c <= "b"
    next
return
```

```harbour hk46
procedure main()
    local a := {10}
    local c := ""
    for each c in a
        ? c >= "b"
    next
return
```

```harbour hk47
procedure main()
    local a
    local c := ""
    a := {}
    AAdd(a, NIL)
    for each c in a
        ? c > "b"
    next
return
```

```harbour hk48
procedure main()
    local a := {"a", "ab"}
    local c := ""
    for each c in a
        ? c = "abc", c == "abc", c <> "abc"
    next
return
```

```harbour hk49
procedure main()
    local a
    local c := ""
    a := {}
    AAdd(a, NIL)
    for each c in a
        ? c <= "b"
    next
return
```

```harbour hk5
PROCEDURE Main()
   LOCAL h := {=>}
   LOCAL k
   h["one"] := 1
   h["one"] := 9
   h["ONE"] := 7
   k := hb_HKeys(h)
   ? LEN(k)
   ? k[1]
   ? h[k[1]]
RETURN
```

```harbour hk50
procedure main()
    local a
    local c := ""
    a := {}
    AAdd(a, NIL)
    for each c in a
        ? c >= "b"
    next
return
```

```harbour hk51
procedure main()
    local a := {"abc", "ab", "abd", "b"}
    local c := ""
    ? "-- 'ab' OP c --"
    for each c in a
        ? "ab" < c, "ab" > c, "ab" <= c, "ab" >= c
    next
    ? "-- 'b' OP c --"
    for each c in a
        ? "b" < c, "b" > c
    next
return
```

```harbour hk52
procedure main()
    local c := ""
    for each c in hb_HKeys({"b" => 20, "a" => 10})
        ? c
    next
return
```

```harbour hk53
procedure main()
    local a := {{1, 2}, {3, 4}}
    local x := 0
    for each x in a[1]
        ? x
    next
    for each x in a[2]
        ? x
    next
return
```

```harbour hk54
procedure main()
    local a := {{1, 2}, {3, 4}}
    local x := 0
    local t
    t := a[1]
    for each x in t
        ? x
    next
    ? len(a)
return
```

```harbour hk55
procedure main()
    local c := ""
    for each c in hb_HKeys({"b" => 20, "a" => 10})
        if c = "a"
            exit
        endif
        ? c
    next
    ? "fin"
return
```

```harbour hk56
procedure main()
    ? reco()
    ? "fin"
return
function reco()
    local c := ""
    for each c in hb_HKeys({"b" => 20, "a" => 10})
        if c = "a"
            return "ret-" + c
        endif
    next
return "sin-ret"
```

```harbour hk57
procedure main()
    local a := {{1, 2}, {3, 4}}
    local x := 0
    for each x in a[1]
        x := x * 10
    next
    ? a[1][1], a[1][2]
return
```

```harbour hk58
procedure main()
    local a := {}
    local x := 0
    AAdd(a, {1, 2})
    ASize(a, 2)
    for each x in a[2]
        ? x
    next
    ? "fin"
return
```

```harbour hk59
procedure main()
    local a := {10, {1, 2}}
    local x := 0
    for each x in a[1]
        ? x
    next
    ? "fin"
return
```

```harbour hk6
PROCEDURE Main()
   LOCAL h := {=>}
   LOCAL k
   k := hb_HKeys(h)
   ? LEN(k)
RETURN
```

```harbour hk60
// for each over a[i][j] on a three-level array
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        ? x
    next
    for each x in a[2][1]
        ? x
    next
return nil
```

```harbour hk61
// root survives depth-3 loops
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        ? x
    next
    ? len(a)
    ? a[1][1][1]
return nil
```

```harbour hk62
// exit inside a depth-3 loop
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        if x = 2
            exit
        endif
        ? x
    next
    ? "fin"
return nil
```

```harbour hk63
// NIL inner casilla at depth 3: what error?
function main()
    local a := {{{1, 2}}}
    local x := 0
    ASize(a[1], 2)
    for each x in a[1][2]
        ? x
    next
return nil
```

```harbour hk64
// index expressions evaluated once at depth 3
function ni()
    ? "eval"
return 1
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[ni()][ni()]
        ? x
    next
return nil
```

```harbour hk65
// ASize on the middle level of a three-level array: what grows?
function main()
    local a := {{{1, 2}}}
    ASize(a[1], 3)
    ? len(a)
    ? len(a[1])
    ? len(a[1][1])
    ? a[1][2]
return nil
```

```harbour hk66
// AAdd on the middle level: pins element type of the middle child
function main()
    local a := {{{1, 2}}}
    local x := 0
    AAdd(a[1], {5, 6})
    ? len(a[1])
    for each x in a[1][2]
        ? x
    next
return nil
```

```harbour hk67
// order of evaluation: indices first, value after (middle level AAdd)
function ni()
    ? "eval"
return 1
function vv()
    ? "val"
return {7, 8}
function main()
    local a := {{{1, 2}}}
    AAdd(a[ni()], vv())
    ? len(a[1])
return nil
```

```harbour hk68
// NIL middle casilla printed and compared; ASize(a,2) on the root
function main()
    local a := {{{1, 2}}}
    ASize(a, 2)
    ? len(a)
    ? a[2]
    ? a[2] == NIL
return nil
```

```harbour hk69
// AAdd on the middle with a DYNAMIC array value (call result)
function main()
    local a := {{{1, 2}}}
    local x := 0
    AAdd(a[1], Array(2))
    ? len(a[1])
    ? len(a[1][2])
    ? a[1][2][1]
return nil
```

```harbour hk7
function main()
local h := {"one" => 1, "two" => 2}
local k := hb_HKeys(h)
? len(k)
AAdd(k, "tres")
? len(k)
? k[3]
k[1] := "nueva"
? k[1]
? k[2]
? len(h)
? h["one"]
return nil
```

```harbour hk70
// AAdd on the middle with a variable: SHARE or copy in Harbour?
function main()
    local a := {{{1, 2}}}
    local b := {7, 8}
    AAdd(a[1], b)
    b[1] := 99
    ? a[1][2][1]
return nil
```

```harbour hk71
PROCEDURE Main()
   LOCAL a := {{1, 2}, {3, 4}}
   ? a[1]
RETURN
```

```harbour hk73
PROCEDURE Main()
   LOCAL a := {{1, 2}, {3, 4}}
   ShowIt(a[1])
RETURN
PROCEDURE ShowIt(x)
   ? Len(x)
   ? x[1], x[2]
RETURN
```

```harbour hk76
PROCEDURE Main()
   LOCAL a := {1, 2}
   LOCAL b := {}
   ? a
   ? b
RETURN
```

```harbour hk77
PROCEDURE Main()
   LOCAL a := {1, NIL, "x", .T., .F.}
   ? a
RETURN
```

```harbour hk78
PROCEDURE Main()
   LOCAL a := {{1, 2}, {3, 4}}
   GrowIt(a[1])
   ? Len(a[1])
   ? a[1][3]
RETURN
PROCEDURE GrowIt(x)
   AAdd(x, 9)
RETURN
```

```harbour hk79
PROCEDURE Main()
   LOCAL a := {1, 2}
   GrowRoot(a)
   ? Len(a)
   ? a[3]
RETURN
PROCEDURE GrowRoot(x)
   AAdd(x, 7)
RETURN
```

```harbour hk8
function main()
local h := {"one" => 1}
local k := hb_HKeys(h)
mut(k)
? len(k)
? k[1]
? k[2]
return nil

function mut(p)
AAdd(p, "two")
p[1] := "changed"
return nil
```

```harbour hk80
PROCEDURE Main()
   LOCAL a := {1, 2}
   Noop(a)
   ? 42
RETURN
PROCEDURE Noop(x)
   x := x
RETURN
```

```harbour hk81
PROCEDURE Main()
   LOCAL a := {1, 2}
   Noop(a)
   ? 42
RETURN
PROCEDURE Noop(x)
RETURN
```

```harbour hk82
PROCEDURE Main()
   Noop(5)
   ? 42
RETURN
PROCEDURE Noop(x)
RETURN
```

```harbour hk83
PROCEDURE Main()
   ? 42
   Noop2()
RETURN
PROCEDURE Noop2()
RETURN
```

```harbour hk84
PROCEDURE Main()
   LOCAL a := {1, 2}
   ? a, 5
   ? 6, a
   ? a, a
RETURN
```

```harbour hk85
PROCEDURE Main()
   LOCAL a := {{1, 2}, {3, 4}}
   ? ValType(a)
   ? ValType(a[1])
   ? ValType(a[1][1])
RETURN
```

```harbour hk86
PROCEDURE Main()
   LOCAL a := {{1, 2}, {3, 4}}
   SetIt(a[1])
   ? a[1][1]
   ? Len(a[1])
RETURN
PROCEDURE SetIt(x)
   x[1] := 99
RETURN
```

```harbour hk87
PROCEDURE Main()
   LOCAL a := {{1, 2}, {3, 4}}
   ShrinkIt(a[1])
   ? Len(a[1])
RETURN
PROCEDURE ShrinkIt(x)
   ASize(x, 1)
RETURN
```

```harbour hk88
function main()
  local a := {{1,2},{3}}, x
  ? ValType(a)
  ? ValType(a[i:=1])
  ? ValType(a[1][1])
  ? ValType(7)
  ? ValType("s")
  ? ValType(NIL)
return NIL
```

```harbour hk89
function bump(n)
  ? "eval", n
return n
function main()
  local a := {{1,2},{3}}
  ? ValType(a[bump(1)])
  ? ValType(a[1][bump(2)])
return NIL
```

```harbour hk9
function main()
local s := "hola"
show(s)
? s
return nil

function show(p)
? p
return nil
```

```harbour hk90
function main()
  local a := Array(2, 2)
  ? ValType(a[1])
return NIL
```

```harbour hk91
function main()
  local a := Array(2)
  ? ValType(a[1])
  ? ValType(a[2])
return NIL
```

```harbour hk92
function main()
  local a := {}
  AAdd(a, "s")
  AAdd(a, 7)
  ? ValType(a[1])
  ? ValType(a[2])
  ASize(a, 4)
  ? ValType(a[3])
  ? ValType(a[4])
return NIL
```

```harbour hk93
function showit(x)
  ? len(x)
  ? len(x[1])
  ? x[1][1]
return 0
function main()
  local a := {{{1,2},{3}},{{4}}}
  ? showit(a[1])
return NIL
```

```harbour hk94
function growit(x)
  AAdd(x, {9,8})
return 0
function main()
  local a := {{{1,2},{3}},{{4}}}
  ? growit(a[1])
  ? len(a[1])
  ? len(a[1][3])
  ? a[1][3][2]
return NIL
```

```harbour hk95
function setit(x)
  x[1][2] := 42
return 0
function main()
  local a := {{{1,2},{3}},{{4}}}
  ? setit(a[1])
  ? a[1][1][2]
return NIL
```

```harbour hk96
function shrinkit(x)
  ASize(x, 1)
return 0
function main()
  local a := {{{1,2},{3}},{{4}}}
  ? shrinkit(a[1])
  ? len(a[1])
  ? len(a)
return NIL
```

```harbour hk97
function vt(x)
  ? ValType(x)
  ? ValType(x[1])
  ? ValType(x[1][1])
  ASize(x, 3)
  ? ValType(x[3])
return 0
function main()
  local a := {{{1,2},{3}},{{4}}}
  ? vt(a[1])
return NIL
```

```harbour hk98
function mut(x)
  ? len(x)
  x[1] := 99
  AAdd(x, 7)
return 0
function main()
  local a := {1, 2, 3}
  ? mut(a)
  ? a[1]
  ? len(a)
return NIL
```

```harbour hk99
function mk()
  local a := {1, 2, 3}
return a
function main()
  local b := mk()
  ? len(b)
  ? b[2]
  b[1] := 99
  ? b[1]
  AAdd(b, 7)
  ? len(b)
return NIL
```

## Tabla de estado (idéntica a MANIFEST.md)

# Corpus de sondas-oráculo Harbour (hk)

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

### hk132

> Nota de soporte (26 oct, iteración 43): las respuestas medidas de esta sonda se reproducen en el PoC SOLO vía el adaptador dedicado DArrS (`{}` + `AAdd` + sobrescritura indexada; t508/t509), NO con la sintaxis `Array(2)` + asignación indexada escalar que usa el programa original - esa sigue rechazada por nombre. Los arrays de tipo mixto también siguen rechazados.

```harbour
function main()
    local a := Array(2)
    a[1] := "hola"
    ? a[1] == "hola"
    ? a[1] == "hola "
    ? a[1] == "hol"
    ? "hola" == a[1]
return nil
```

### hk133

> Nota de soporte (26 oct, iteración 43): las respuestas medidas de esta sonda se reproducen en el PoC SOLO vía el adaptador dedicado DArrS (`{}` + `AAdd` + sobrescritura indexada; t508/t509), NO con la sintaxis `Array(2)` + asignación indexada escalar que usa el programa original - esa sigue rechazada por nombre. Los arrays de tipo mixto también siguen rechazados.

```harbour
function main()
    local a := Array(2)
    local b := Array(2)
    a[1] := "hola"
    b[1] := "hola"
    ? a[1] == b[1]
    b[1] := "holaa"
    ? a[1] == b[1]
    ? a[1] == a[1]
return nil
```

### hk134

```harbour
function main()
    local h := {"a" => 1}
    local h2 := {"a" => 1}
    ? h == h
    ? h == h2
return nil
```

### hk135

```harbour
function main()
    local a := Array(2, 2, 2)
    local b := Array(2, 2, 2)
    local c := Array(2, 2, 2, 2)
    local d := Array(2, 2, 2, 2)
    ? a == a
    ? a == b
    ? c == c
    ? c == d
return nil
```

### hk136

```harbour
function make()
    return {|n| n + 1}
function main()
    local x := make()
    local y := make()
    ? x == x
    ? x == y
    ? make() == make()
return nil
```

### hk137

```harbour
function main()
    local x, y, i
    for i := 1 to 2
        if i == 1
            x := {|n| n + 1}
        else
            y := {|n| n + 1}
        endif
    next
    ? x == y
    ? x == x
return nil
```

### hk138

```harbour
function main()
    local a := Array(2)
    local b := Array(2)
    a[1] := 1
    b[1] := 1
    ? a[1] == b[1]
    ? a[1] == 2
    ? 1 == a[1]
    ? a[1] == a[1]
return nil
```

### hk139

```harbour
function main()
    local a := Array(2)
    local b := Array(2)
    a[1] := "hola"
    b[1] := 1
    ? a[1] == b[1]
    ? b[1] == "hola"
    ? a[1] == 1
return nil
```

### hk139b

```harbour
function main()
    local b := Array(2)
    b[1] := 1
    ? b[1] == "hola"
return nil
```

### hk139c

```harbour
function main()
    local a := Array(2)
    a[1] := "hola"
    ? a[1] == 1
return nil
```

### hk140

```harbour
function main()
    local a := Array(2)
    local b := Array(2)
    ? a[1] == b[1]
    ? a[1] == "hola"
    ? a[1] == 7
return nil
```

### hk141

```harbour
function main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c
    for each c in k
        ? c == "b"
        ? "b" == c
    next
return nil
```

### hk142

```harbour
function main()
    local h := {"b" => 20}
    local k := hb_HKeys(h)
    local c
    for each c in k
        ? c == 7
    next
return nil
```

### hk143

```harbour
function main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c1, c2
    for each c1 in k
        for each c2 in k
            ? c1 == c2
        next
    next
return nil
```

### hk144

```harbour
function main()
    local h := {"b" => 20}
    local k := hb_HKeys(h)
    local c
    for each c in k
        ? 7 == c
    next
return nil
```

### hk145

```harbour
function main()
    local h := {"a" => 1, "bb" => 2}
    local k, k2
    for each k in hb_HKeys(h)
        for each k2 in hb_HKeys(h)
            ? k = k2
        next
    next
    for each k in hb_HKeys(h)
        ? k # k
    next
return nil
```

### hk146

```harbour
function main()
    local h := {"a" => 1}
    local a := {7}
    local k
    for each k in hb_HKeys(h)
        ? k = a[1]
    next
return nil
```

### hk147

```harbour
function main()
    local h := {"a" => 1}
    local a := {NIL}
    local k
    for each k in hb_HKeys(h)
        ? k = a[1]
        ? a[1] = k
    next
return nil
```

### hk148

```harbour
function main()
    local h := {"a" => 1, "bb" => 2}
    local k, k2
    for each k in hb_HKeys(h)
        for each k2 in hb_HKeys(h)
            ? k < k2
        next
    next
    for each k in hb_HKeys(h)
        for each k2 in hb_HKeys(h)
            ? k > k2
        next
    next
    for each k in hb_HKeys(h)
        for each k2 in hb_HKeys(h)
            ? k <= k2
        next
    next
    for each k in hb_HKeys(h)
        for each k2 in hb_HKeys(h)
            ? k >= k2
        next
    next
return nil
```

### hk149

```harbour
function main()
    local h := {"a" => 1}
    local a := {7}
    local k
    for each k in hb_HKeys(h)
        ? k < a[1]
    next
return nil
```

### hk150

```harbour
function main()
    local h := {"a" => 1}
    local a := {7}
    local k
    for each k in hb_HKeys(h)
        ? k > a[1]
    next
return nil
```

### hk151

```harbour
function main()
    local h := {"a" => 1}
    local a := {7}
    local k
    for each k in hb_HKeys(h)
        ? k <= a[1]
    next
return nil
```

### hk152

```harbour
function main()
    local h := {"a" => 1}
    local a := {7}
    local k
    for each k in hb_HKeys(h)
        ? k >= a[1]
    next
return nil
```

### hk153

```harbour
function main()
    local h := {"a" => 1, "bb" => NIL, "c" => 42}
    local v := hb_HValues(h)
    ? len(v)
    ? v[1]
    ? v[2]
    ? v[3]
    v[1] := 99
    ? h["a"]
    ? v[1]
return nil
```

### hk154

```harbour
function main()
    local h := {=>}
    local v := hb_HValues(h)
    local w, k
    ? len(v)
    h["x"] := 7
    ? len(v)
    w := hb_HValues(h)
    ? len(w)
    ? w[1]
    for each k in w
        ? k
    next
return nil
```




### hk155 - hb_HDel: borrado, clave ausente y vaciado (26 oct 2026)

Fuente `sondas_ac/hkeys/hk155.prg`, compilada con
`hbmk2 hk155.prg -gtstd -ohk155` (solo librerías core). Salida verbatim:

```
\n         2\na\nc\n         1\n         3\n         2\n         0
```

Tras hb_HDel(h, "bb") len pasa de 3 a 2 y la iteración y las lecturas
saltan "bb"; borrar la ausente "zz" es un no-op (len sigue 2); borrar
todas deja len 0. Reproducido byte a byte por t521 en Linux y Wine.

### hk156 - hb_HDel: re-alta al final y clave vacía (26 oct 2026)

Fuente `sondas_ac/hkeys/hk156.prg`, compilada con
`hbmk2 hk156.prg -gtstd -ohk156` (solo librerías core). Salida verbatim:

```
\n         3\na\n         1\nc\n         3\nbb\n        22\n         3
```

Una clave borrada y re-alta ("bb") queda al FINAL - las entradas
restantes conservan su orden (a, c, bb); borrar "" sin existir es un
no-op (len sigue 3). Verificado por t522 con lecturas por clave literal
(la lectura h[k] del oráculo con variable `for each` Dyn sigue siendo
límite nombrado del incremento: las lecturas piden claves Str/StrOwn).

### hk157 - hb_HHasKey: membresía exacta y sensible a caso (26 oct 2026)

Fuente `sondas_ac/hkeys/hk157.prg`, compilada con
`hbmk2 hk157.prg -gtstd -ohk157` (solo librerías core). Salida verbatim:

```
\n.T.\n.T.\n.F.\n.F.\n.F.\n.F.\n.T.\n.F.\n.F.
```

Claves presentes .T.; ausente "zz", caso distinto "A" y prefijo "b" .F.;
"" es .F. hasta que se añade como clave (.T.); tras hb_HDel(h, "a") la
clave borrada vuelve a .F.; el hash vacío responde .F. Reproducido como
1/0 por t525/t526 en Linux y Wine (el dialecto no tiene tipo lógico:
1/0 es la superficie del PoC; la impresión .T./.F. es la familia
registrada de representación booleana).

### hk158 - hb_HGet: lectura, default inaplicado y BASE/1132 en ausente (26 oct 2026)

Fuentes `sondas_ac/hkeys/hk158*.prg`, compiladas con
`hbmk2 <f> -gtstd -o<x>` (solo librerías core), medidas por separado tras
un cuelgue inicial: hk158a (existentes 1 y 2; la ausente "zz" sin default
levanta el diálogo BASE/1132 «Bound error: array access» y CUELGA
headless, rc=124), hk158b (la ausente CON default 42 levanta el mismo
diálogo de inmediato), hk158d (hash vacío, mismo diálogo), hk158c
(rc=0, verbatim `\nNIL\nNIL`: el valor NIL existente se devuelve NIL y el
default 42 NO se aplica), hk158e (rc=0, verbatim `\n         1\n         1`:
existente con y sin default). El diálogo headless no es oráculo: t528
reproduce las lecturas medidas y t529 registra la condición de ausente
como modo de fallo con salida limpia (exit 1), nunca éxito de compat.

### hk158f - hb_HGet: el default SIEMPRE se evalúa (26 oct 2026)

Fuentes `sondas_ac/hkeys/hk158f1-f3.prg`, compiladas con
`hbmk2 <f> -gtstd -o<x>` (solo librerías core). El default es una función
con efecto (imprime EFFECT y devuelve 42). Verbatim hk158f1 (clave
presente): `\nEFFECT\n         1\nDONE`; hk158f2 (valor NIL existente):
`\nEFFECT\nNIL\nDONE`; hk158f3 (clave ausente): imprime EFFECT y DESPUÉS
levanta el diálogo BASE/1132 (dialogo-sin-oraculo, rc=124). Conclusión
medida: el argumento default se evalúa siempre - presente, NIL o
ausente, antes del error - y su valor se descarta (nunca rescata una
ausente ni anula un NIL existente, hk158b/c). Corrige la redacción
inicial de la iteración 49 («no se evalúa»), señalada en revisión: t531
fija la evaluación en ambos targets.

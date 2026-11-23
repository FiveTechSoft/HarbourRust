function main()
 local h := {=>}
 local a := {1, "x", .F.}
 local n := 42
 local s := "ab" + Chr(34) + "cd" + Chr(92) + "e"
 local d := SToD("20261122")
 local f := 2.5
 local b := .T.
 local n1 := {{1, 2}, {3}}
 local e1 := ""
 local st1 := "a" + Chr(9) + "b" + Chr(13) + "c" + Chr(1)
 local big := 9223372036854775807
 local hs := {=>}
 local m0 := {}
 local inner := {=>}
 h["i"] := 7
 h["t"] := .T.
 h["f"] := .F.
 h["z"] := nil
 inner["k"] := 5
 ? "[" + hb_jsonEncode(h) + "]"
 ? "[" + hb_jsonEncode(a) + "]"
 ? "[" + hb_jsonEncode(n) + "]"
 ? "[" + hb_jsonEncode(s) + "]"
 ? "[" + hb_jsonEncode(d) + "]"
 ? "[" + hb_jsonEncode(f) + "]"
 ? "[" + hb_jsonEncode(b) + "]"
 ? "[" + hb_jsonEncode(n1) + "]"
 ? "[" + hb_jsonEncode(e1) + "]"
 ? "[" + hb_jsonEncode(st1) + "]"
 ? "[" + hb_jsonEncode(big) + "]"
 ? "[" + hb_jsonEncode(hs) + "]"
 ? "[" + hb_jsonEncode(m0) + "]"
 ? "[" + hb_jsonEncode(inner) + "]"
return nil

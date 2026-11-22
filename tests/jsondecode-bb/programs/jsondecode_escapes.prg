function main()
 local u1 := hb_jsonDecode('"aéu"')
 local u2 := hb_jsonDecode('"a\u00e9b"')
 local u3 := hb_jsonDecode('"\u0041"')
 ? Len(u1), u1 == "a" + Chr(233) + "u"
 ? Len(u2), u2 == "a" + Chr(233) + "b"
 ? Len(u3), u3
return nil

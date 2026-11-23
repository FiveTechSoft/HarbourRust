function main()
 local u1 := hb_jsonDecode('"aéu"')
 local u3 := hb_jsonDecode('"\u0041"')
 ? Len(u1), u1 == "a" + Chr(233) + "u"
 ? Len(u3), u3
return nil

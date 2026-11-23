function main()
 local v1 := hb_jsonDecode("42")
 local v2 := hb_jsonDecode("1.5")
 local v3 := hb_jsonDecode('"txt"')
 local v4 := hb_jsonDecode("true")
 local v5 := hb_jsonDecode("null")
 local v6 := hb_jsonDecode('[1,2,3]')
 local v7 := hb_jsonDecode('["a",2,true,null]')
 local v8 := hb_jsonDecode('[[1],[2,"b"]]')
 local v11 := hb_jsonDecode('"a\nb"')
 local v12 := hb_jsonDecode('not json')
 ? ValType(v1), v1
 ? ValType(v2), v2
 ? ValType(v3), v3
 ? ValType(v4), v4
 ? ValType(v5)
 ? ValType(v6), Len(v6), v6[2]
 ? ValType(v7), Len(v7), v7[1], v7[2], v7[3], v7[4]
 ? ValType(v8), Len(v8)
 ? hb_jsonEncode(v8)
 ? Len(v11), v11 == "a" + Chr(10) + "b"
 ? ValType(v12)
 ? hb_jsonEncode(v2)
 ? hb_jsonEncode(v7)
 ? hb_jsonEncode(v12)
return nil

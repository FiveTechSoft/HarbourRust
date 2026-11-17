function main()
local s := "dyn"
? DIRMAKE("t1/"), DIRMAKE("t1/"), DIRMAKE("a\b\"), DIRMAKE("t2\"), DIRMAKE("t2\sub\")
? DIRMAKE("caf" + Chr(195)+Chr(169)), DIRMAKE("caf" + Chr(195)+Chr(169)), DIRMAKE("sp ace"), DIRMAKE("dot.")
? DIRMAKE("./rel"), DIRMAKE(".\rel2"), DIRMAKE("rel2\..\rel3"), DIRMAKE("trail "), DIRMAKE("ab"+Replicate("x",300))
? DIRMAKE(s), DIRMAKE(s), DIRMAKE("bad"+Chr(255)+"byte"), DIRMAKE("a:b"), DIRMAKE("q?"), DIRMAKE("*")
? DIRMAKE("\\\\?\\"+"C:\nope"), DIRMAKE("C:\"), DIRMAKE("Z:\nodrive\x"), DIRMAKE(Replicate("d/",5)+"e")
return nil

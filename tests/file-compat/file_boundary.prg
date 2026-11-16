procedure Main()
? "truncate",File(Replicate("a",250)+"/"+Replicate("b",11)),File(Replicate("a",250)+"/"+Replicate("b",11)+"junk"),File(Replicate("a",250)+"/"+Replicate("b",12))
set default to (Replicate("a",250))
? "join",File(Replicate("b",11)+"junk"),File(Replicate("b",12))
set path to (Replicate("missing:",600)+"search")
? "long-path",File("path.txt")
return

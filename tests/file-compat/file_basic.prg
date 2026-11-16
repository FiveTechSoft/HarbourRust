procedure Main()
? "exact",File("Exact.TXT"),File("exact.txt"),File("absent"),File("")
? "dirs",File("sub"),File("sub/"),File("."),File("..")
? "nested",File("sub/nested.txt"),File("sub\\nested.txt")
? "glob",File("*.TXT"),File("*.txt"),File("*.*"),File("noext.*"),File("Exact.???"),File("[E]xact.TXT")
? "hidden",File(".hidden"),File(".*"),File("link.txt"),File("broken")
? "type",File(NIL),File(1),File(.T.)
set default to "default"
? "default",File("only.txt"),File("Exact.TXT"),File("sub/nested.txt")
set path to "search"
? "path",File("path.txt"),File("only.txt"),File("Exact.TXT")
return

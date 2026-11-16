procedure Main()
local d := "default"
set default to (d)
? "initial",File("Exact.TXT"),File("only.txt")
set path to ""
? "empty",File("Exact.TXT"),File("only.txt")
set path to ":search:"
? "colon",File("Exact.TXT"),File("path.txt"),File("only.txt")
set path to ";search;"
? "semi",File("Exact.TXT"),File("path.txt"),File("only.txt")
set path to missing;search
? "bare-semi",File("path.txt")
set path to missing:search
? "bare-colon",File("path.txt")
set default to default/
? "bare-default",File("only.txt")
set default to
set path to
? "reset",File("Exact.TXT"),File("only.txt"),File("sub/nested.txt")
set default to "odd\"
? "backslash",File("back.txt")
return

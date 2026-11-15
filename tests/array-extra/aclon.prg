function main()
   local a := Array(2)
   a[1] := 1
   a[2] := 2
   local b := aclone(a)
   b[1] := 9
   ? a[1], b[1]
   local s := {"aa", "bb"}
   local t := aclone(s)
   t[1] := "zz"
   ? s[1], t[1]
   return nil

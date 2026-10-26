function main()
   local a := "foo" + ""  // owned (StrOwn), so line 8 can reassign
   local b := "bar"
   ? 'lit' + 'era' + 'l'
   ? a + b
   ? a + "!"
   ? a + b = "foobar"
   a = a + "X"
   ? a
   return

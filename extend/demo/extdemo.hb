// Extend-System bridge milestone-1 demo (docs/EXTEND-BRIDGE.md).
// The functions below live in myext.c, compiled with a standard C
// compiler and linked through the bridge.
EXTERNAL HBR_ADD, HBR_SHOUT, HBR_DESCRIBE

function main()
   ? hbr_add(20, 3)                 // 23 (two integer parameters)
   ? hbr_add(7)                     // 7  (omitted parameter reads NIL -> 0)
   ? hbr_shout("hello bridge")      // HELLO BRIDGE (string in, string out)
   ? hbr_describe("abc", 42, .T.)   // typed description of its parameters
   ? hbr_describe()                 // pcount 0
   return nil

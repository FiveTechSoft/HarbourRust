FUNCTION GiveArr()
   ?? "side-effect "
   RETURN { 10, 20 }
FUNCTION GiveStrs()
   ?? "strs-side "
   RETURN { "x", "y" }
PROCEDURE Main()
   GiveArr()
   GiveStrs()
   ? "done"
   RETURN

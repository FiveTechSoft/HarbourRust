// output statements with several items: the pad around the evaluation must not change order or text. Independent fixture.
STATIC entered := 0
function Boom()
 entered := entered + 1
 Break( "expected" )
return 3
function Own()
return "o" + "k"
function Main()
 local a, c, s, i
 a := 1.5
 c := 0.25
 s := "x"
 ? "ok", a * 2, c * 4, Own(), s, a
 ? a * 2, "mid", 7, Own() + "!", a * c
 for i := 1 to 2
  try
   ? a * 2, Boom()
  catch
   ? "caught-call", entered
  end
  try
   ? a * c, Own(), s, Boom()
  catch
   ? "caught-call-2", entered
  end
  try
   ? a * 2, s - 1
  catch
   ? "caught-arith"
  end
  try
   ? Own(), a, s, a * 2, a + "x"
  catch
   ? "caught-concat"
  end
 next
 ? "after", a * 2, entered
return nil

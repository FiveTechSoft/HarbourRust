PROCEDURE MAIN()
local a := {"9", "99"}
local d := CToD("01/02/2026")
local s := ""
local i := 0
FOR i := 1 TO 20000
  TRY
    s := Transform(d, "9" + a[5])
  CATCH
    s := "caught1"
  END
  TRY
    s := Transform(12.5, a[5] + "9")
  CATCH
    s := "caught2"
  END
NEXT
? s
RETURN

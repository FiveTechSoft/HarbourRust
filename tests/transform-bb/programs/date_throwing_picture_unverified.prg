PROCEDURE MAIN()
local a := {"9"}
local s := ""
TRY
  s := Transform(CToD("01/02/2026"), a[5])
CATCH
  s := "caught"
END
? s
RETURN

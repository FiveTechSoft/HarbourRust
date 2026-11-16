PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","clie.dbf","CLIE",.F.,.F.)
   ordCreate("clie", "NOMBRE", "UPPER(NOMBRE)")
   ordCreate("clie", "EDAD", "STR(EDAD,3)")
   ? ordSetFocus("NOMBRE"), "|"
   ? dbSeek("LUIS"), RecNo(), EDAD, "|"
   ? dbSeek("B", .T.), RecNo(), Eof(), "|"
   ? ordSetFocus("EDAD"), "|"
   dbGoTop()
   ? RecNo(), EDAD, "|"
   dbGoBottom()
   ? RecNo(), EDAD, "|"
   ? dbSeek(" 34"), Found(), RecNo(), "|"
   dbCloseArea()
RETURN

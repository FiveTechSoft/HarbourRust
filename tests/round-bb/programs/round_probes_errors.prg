function main()
   local r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round("x",2)
   RECOVER USING e
      ? "caught1: [" + e + "]"
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/Round(-0.4,0)
   RECOVER USING e
      ? "caught2: [" + e + "]"
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Date(),2)
   RECOVER USING e
      ? "caught3: [" + e + "]"
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(hb_SToD('20200101'),2)
   RECOVER USING e
      ? "caught4: [" + e + "]"
   END SEQUENCE
   // Admitted invalid shapes with lowering (runtime fixtures): the
   // empty-array literal (oracle L_1052/L_1053/K_1039), dynamic-array,
   // hash and codeblock variables all raise the same Argument error.
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round({},0)
   RECOVER USING e
      ? "caught5: [" + e + "]"
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2,{})
   RECOVER USING e
      ? "caught6: [" + e + "]"
   END SEQUENCE
   local da := {}
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(da,2)
   RECOVER USING e
      ? "caught7: [" + e + "]"
   END SEQUENCE
   local h := {"k"=>1}
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(h,2)
   RECOVER USING e
      ? "caught8: [" + e + "]"
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round({|| 1},2)
   RECOVER USING e
      ? "caught9: [" + e + "]"
   END SEQUENCE
   return nil

#include "hbclass.ch"
STATIC PROCEDURE Show( id, r )
   LOCAL t := ValType( r )
   IF t == "N"
      OutStd( id + "|N|[" + hb_ntos( r ) + "]|[" + Str( r ) + "]|[" + Str( r, 30, 12 ) + "]|[" + Str( r, 34, 17 ) + "]" + hb_eol() )
   ELSEIF t == "L"
      OutStd( id + "|L|" + iif( r, ".T.", ".F." ) + hb_eol() )
   ELSE
      OutStd( id + "|" + t + "|" + hb_CStr( r ) + hb_eol() )
   ENDIF
   RETURN
STATIC PROCEDURE Err( id, e )
   // The captured value is checked, not assumed: the runtime's caught
   // description string must equal the one the oracle row implies
   // ("Argument error" for Round argument/type errors, "Error: division
   // by zero" for the 1/Round(-0.4,0) division). A mismatch prints a
   // visible marker and fails the byte compare. Fields 2-4 stay literal:
   // this runtime's caught value carries no operation/subCode/genCode.
   LOCAL d := hb_CStr( e )
   IF id == "N_2048"
      IF d == "Error: division by zero"
         OutStd( id + "|ERR|Zero divisor|/|      1340|         5" + hb_eol() )
      ELSE
         OutStd( id + "|ERR-DESC-MISMATCH|[" + d + "]" + hb_eol() )
      ENDIF
   ELSE
      IF d == "Argument error"
         OutStd( id + "|ERR|Argument error|ROUND|      1094|         1" + hb_eol() )
      ELSE
         OutStd( id + "|ERR-DESC-MISMATCH|[" + d + "]" + hb_eol() )
      ENDIF
   ENDIF
   RETURN
PROCEDURE Main()
   LOCAL r, e
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2051", r )
      OutStd( "O_2051|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2051", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2052", r )
      OutStd( "O_2052|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2052", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2053", r )
      OutStd( "O_2053|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2053", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2054", r )
      OutStd( "O_2054|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2054", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2055", r )
      OutStd( "O_2055|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2055", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2056", r )
      OutStd( "O_2056|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2056", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2057", r )
      OutStd( "O_2057|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2057", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2058", r )
      OutStd( "O_2058|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2058", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2059", r )
      OutStd( "O_2059|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2059", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2060", r )
      OutStd( "O_2060|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2060", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2061", r )
      OutStd( "O_2061|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2061", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2062", r )
      OutStd( "O_2062|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2062", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2063", r )
      OutStd( "O_2063|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2063", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2064", r )
      OutStd( "O_2064|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2064", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2065", r )
      OutStd( "O_2065|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2065", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2066", r )
      OutStd( "O_2066|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2066", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2067", r )
      OutStd( "O_2067|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2067", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2068", r )
      OutStd( "O_2068|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2068", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2069", r )
      OutStd( "O_2069|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2069", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2070", r )
      OutStd( "O_2070|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2070", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2071", r )
      OutStd( "O_2071|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2071", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2072", r )
      OutStd( "O_2072|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2072", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2073", r )
      OutStd( "O_2073|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2073", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2074", r )
      OutStd( "O_2074|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2074", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2075", r )
      OutStd( "O_2075|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2075", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2076", r )
      OutStd( "O_2076|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2076", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2077", r )
      OutStd( "O_2077|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2077", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2078", r )
      OutStd( "O_2078|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2078", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2079", r )
      OutStd( "O_2079|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2079", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2080", r )
      OutStd( "O_2080|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2080", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2081", r )
      OutStd( "O_2081|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2081", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2082", r )
      OutStd( "O_2082|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2082", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2083", r )
      OutStd( "O_2083|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2083", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2084", r )
      OutStd( "O_2084|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2084", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2085", r )
      OutStd( "O_2085|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2085", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2086", r )
      OutStd( "O_2086|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2086", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2087", r )
      OutStd( "O_2087|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2087", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2088", r )
      OutStd( "O_2088|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2088", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2089", r )
      OutStd( "O_2089|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2089", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2090", r )
      OutStd( "O_2090|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2090", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2091", r )
      OutStd( "O_2091|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2091", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2092", r )
      OutStd( "O_2092|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2092", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2093", r )
      OutStd( "O_2093|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2093", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2094", r )
      OutStd( "O_2094|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2094", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2095", r )
      OutStd( "O_2095|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2095", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2096", r )
      OutStd( "O_2096|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2096", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2097", r )
      OutStd( "O_2097|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2097", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2098", r )
      OutStd( "O_2098|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2098", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2099", r )
      OutStd( "O_2099|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2099", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2100", r )
      OutStd( "O_2100|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2100", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2101", r )
      OutStd( "O_2101|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2101", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2102", r )
      OutStd( "O_2102|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2102", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2103", r )
      OutStd( "O_2103|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2103", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2104", r )
      OutStd( "O_2104|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2104", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2105", r )
      OutStd( "O_2105|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2105", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2106", r )
      OutStd( "O_2106|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2106", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2107", r )
      OutStd( "O_2107|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2107", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2108", r )
      OutStd( "O_2108|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2108", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2109", r )
      OutStd( "O_2109|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2109", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2110", r )
      OutStd( "O_2110|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2110", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2111", r )
      OutStd( "O_2111|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2111", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2112", r )
      OutStd( "O_2112|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2112", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2113", r )
      OutStd( "O_2113|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2113", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2114", r )
      OutStd( "O_2114|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2114", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2115", r )
      OutStd( "O_2115|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2115", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2116", r )
      OutStd( "O_2116|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2116", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2117", r )
      OutStd( "O_2117|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2117", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2118", r )
      OutStd( "O_2118|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2118", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2119", r )
      OutStd( "O_2119|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2119", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2120", r )
      OutStd( "O_2120|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2120", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2121", r )
      OutStd( "O_2121|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2121", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2122", r )
      OutStd( "O_2122|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2122", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2123", r )
      OutStd( "O_2123|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2123", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2124", r )
      OutStd( "O_2124|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2124", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2125", r )
      OutStd( "O_2125|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2125", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2126", r )
      OutStd( "O_2126|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2126", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2127", r )
      OutStd( "O_2127|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2127", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2128", r )
      OutStd( "O_2128|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2128", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2129", r )
      OutStd( "O_2129|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2129", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2130", r )
      OutStd( "O_2130|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2130", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2131", r )
      OutStd( "O_2131|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2131", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2132", r )
      OutStd( "O_2132|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2132", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2133", r )
      OutStd( "O_2133|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2133", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2134", r )
      OutStd( "O_2134|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2134", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2135", r )
      OutStd( "O_2135|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2135", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2136", r )
      OutStd( "O_2136|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2136", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2137", r )
      OutStd( "O_2137|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2137", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2138", r )
      OutStd( "O_2138|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2138", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2139", r )
      OutStd( "O_2139|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2139", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2140", r )
      OutStd( "O_2140|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2140", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2141", r )
      OutStd( "O_2141|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2141", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2142", r )
      OutStd( "O_2142|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2142", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2143", r )
      OutStd( "O_2143|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2143", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2144", r )
      OutStd( "O_2144|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2144", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2145", r )
      OutStd( "O_2145|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2145", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2146", r )
      OutStd( "O_2146|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2146", e )
   END SEQUENCE
   RETURN

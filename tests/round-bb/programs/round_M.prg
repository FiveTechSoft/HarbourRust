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
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,10,2)
      Show( "M_1066", r )
   RECOVER USING e
      Err( "M_1066", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,10,0)
      Show( "M_1067", r )
   RECOVER USING e
      Err( "M_1067", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,10,1)
      Show( "M_1068", r )
   RECOVER USING e
      Err( "M_1068", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,5,2)
      Show( "M_1069", r )
   RECOVER USING e
      Err( "M_1069", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,4,2)
      Show( "M_1070", r )
   RECOVER USING e
      Err( "M_1070", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,3,0)
      Show( "M_1071", r )
   RECOVER USING e
      Err( "M_1071", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,2,0)
      Show( "M_1072", r )
   RECOVER USING e
      Err( "M_1072", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,1,0)
      Show( "M_1073", r )
   RECOVER USING e
      Err( "M_1073", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,6,3)
      Show( "M_1074", r )
   RECOVER USING e
      Err( "M_1074", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,20,15)
      Show( "M_1075", r )
   RECOVER USING e
      Err( "M_1075", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,30,20)
      Show( "M_1076", r )
   RECOVER USING e
      Err( "M_1076", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,8,-1)
      Show( "M_1077", r )
   RECOVER USING e
      Err( "M_1077", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,10,3)
      Show( "M_1078", r )
   RECOVER USING e
      Err( "M_1078", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,0,0)
      Show( "M_1079", r )
   RECOVER USING e
      Err( "M_1079", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,12,6)
      Show( "M_1080", r )
   RECOVER USING e
      Err( "M_1080", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005)
      Show( "M_1081", r )
   RECOVER USING e
      Err( "M_1081", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,8)
      Show( "M_1082", r )
   RECOVER USING e
      Err( "M_1082", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,3)
      Show( "M_1083", r )
   RECOVER USING e
      Err( "M_1083", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,20)
      Show( "M_1084", r )
   RECOVER USING e
      Err( "M_1084", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,5)
      Show( "M_1085", r )
   RECOVER USING e
      Err( "M_1085", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,10,2)
      Show( "M_1086", r )
   RECOVER USING e
      Err( "M_1086", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,10,0)
      Show( "M_1087", r )
   RECOVER USING e
      Err( "M_1087", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,10,1)
      Show( "M_1088", r )
   RECOVER USING e
      Err( "M_1088", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,5,2)
      Show( "M_1089", r )
   RECOVER USING e
      Err( "M_1089", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,4,2)
      Show( "M_1090", r )
   RECOVER USING e
      Err( "M_1090", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,3,0)
      Show( "M_1091", r )
   RECOVER USING e
      Err( "M_1091", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,2,0)
      Show( "M_1092", r )
   RECOVER USING e
      Err( "M_1092", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,1,0)
      Show( "M_1093", r )
   RECOVER USING e
      Err( "M_1093", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,6,3)
      Show( "M_1094", r )
   RECOVER USING e
      Err( "M_1094", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,20,15)
      Show( "M_1095", r )
   RECOVER USING e
      Err( "M_1095", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,30,20)
      Show( "M_1096", r )
   RECOVER USING e
      Err( "M_1096", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,8,-1)
      Show( "M_1097", r )
   RECOVER USING e
      Err( "M_1097", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,10,3)
      Show( "M_1098", r )
   RECOVER USING e
      Err( "M_1098", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,0,0)
      Show( "M_1099", r )
   RECOVER USING e
      Err( "M_1099", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,12,6)
      Show( "M_1100", r )
   RECOVER USING e
      Err( "M_1100", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675)
      Show( "M_1101", r )
   RECOVER USING e
      Err( "M_1101", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,8)
      Show( "M_1102", r )
   RECOVER USING e
      Err( "M_1102", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,3)
      Show( "M_1103", r )
   RECOVER USING e
      Err( "M_1103", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,20)
      Show( "M_1104", r )
   RECOVER USING e
      Err( "M_1104", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,5)
      Show( "M_1105", r )
   RECOVER USING e
      Err( "M_1105", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,10,2)
      Show( "M_1106", r )
   RECOVER USING e
      Err( "M_1106", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,10,0)
      Show( "M_1107", r )
   RECOVER USING e
      Err( "M_1107", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,10,1)
      Show( "M_1108", r )
   RECOVER USING e
      Err( "M_1108", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,5,2)
      Show( "M_1109", r )
   RECOVER USING e
      Err( "M_1109", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,4,2)
      Show( "M_1110", r )
   RECOVER USING e
      Err( "M_1110", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,3,0)
      Show( "M_1111", r )
   RECOVER USING e
      Err( "M_1111", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,2,0)
      Show( "M_1112", r )
   RECOVER USING e
      Err( "M_1112", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,1,0)
      Show( "M_1113", r )
   RECOVER USING e
      Err( "M_1113", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,6,3)
      Show( "M_1114", r )
   RECOVER USING e
      Err( "M_1114", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,20,15)
      Show( "M_1115", r )
   RECOVER USING e
      Err( "M_1115", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,30,20)
      Show( "M_1116", r )
   RECOVER USING e
      Err( "M_1116", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,8,-1)
      Show( "M_1117", r )
   RECOVER USING e
      Err( "M_1117", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,10,3)
      Show( "M_1118", r )
   RECOVER USING e
      Err( "M_1118", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,0,0)
      Show( "M_1119", r )
   RECOVER USING e
      Err( "M_1119", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,12,6)
      Show( "M_1120", r )
   RECOVER USING e
      Err( "M_1120", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285)
      Show( "M_1121", r )
   RECOVER USING e
      Err( "M_1121", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,8)
      Show( "M_1122", r )
   RECOVER USING e
      Err( "M_1122", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,3)
      Show( "M_1123", r )
   RECOVER USING e
      Err( "M_1123", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,20)
      Show( "M_1124", r )
   RECOVER USING e
      Err( "M_1124", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,5)
      Show( "M_1125", r )
   RECOVER USING e
      Err( "M_1125", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,10,2)
      Show( "M_1126", r )
   RECOVER USING e
      Err( "M_1126", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,10,0)
      Show( "M_1127", r )
   RECOVER USING e
      Err( "M_1127", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,10,1)
      Show( "M_1128", r )
   RECOVER USING e
      Err( "M_1128", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,5,2)
      Show( "M_1129", r )
   RECOVER USING e
      Err( "M_1129", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,4,2)
      Show( "M_1130", r )
   RECOVER USING e
      Err( "M_1130", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,3,0)
      Show( "M_1131", r )
   RECOVER USING e
      Err( "M_1131", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,2,0)
      Show( "M_1132", r )
   RECOVER USING e
      Err( "M_1132", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,1,0)
      Show( "M_1133", r )
   RECOVER USING e
      Err( "M_1133", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,6,3)
      Show( "M_1134", r )
   RECOVER USING e
      Err( "M_1134", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,20,15)
      Show( "M_1135", r )
   RECOVER USING e
      Err( "M_1135", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,30,20)
      Show( "M_1136", r )
   RECOVER USING e
      Err( "M_1136", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,8,-1)
      Show( "M_1137", r )
   RECOVER USING e
      Err( "M_1137", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,10,3)
      Show( "M_1138", r )
   RECOVER USING e
      Err( "M_1138", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,0,0)
      Show( "M_1139", r )
   RECOVER USING e
      Err( "M_1139", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,12,6)
      Show( "M_1140", r )
   RECOVER USING e
      Err( "M_1140", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5)
      Show( "M_1141", r )
   RECOVER USING e
      Err( "M_1141", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,8)
      Show( "M_1142", r )
   RECOVER USING e
      Err( "M_1142", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,3)
      Show( "M_1143", r )
   RECOVER USING e
      Err( "M_1143", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,20)
      Show( "M_1144", r )
   RECOVER USING e
      Err( "M_1144", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,5)
      Show( "M_1145", r )
   RECOVER USING e
      Err( "M_1145", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,10,2)
      Show( "M_1146", r )
   RECOVER USING e
      Err( "M_1146", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,10,0)
      Show( "M_1147", r )
   RECOVER USING e
      Err( "M_1147", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,10,1)
      Show( "M_1148", r )
   RECOVER USING e
      Err( "M_1148", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,5,2)
      Show( "M_1149", r )
   RECOVER USING e
      Err( "M_1149", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,4,2)
      Show( "M_1150", r )
   RECOVER USING e
      Err( "M_1150", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,3,0)
      Show( "M_1151", r )
   RECOVER USING e
      Err( "M_1151", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,2,0)
      Show( "M_1152", r )
   RECOVER USING e
      Err( "M_1152", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,1,0)
      Show( "M_1153", r )
   RECOVER USING e
      Err( "M_1153", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,6,3)
      Show( "M_1154", r )
   RECOVER USING e
      Err( "M_1154", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,20,15)
      Show( "M_1155", r )
   RECOVER USING e
      Err( "M_1155", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,30,20)
      Show( "M_1156", r )
   RECOVER USING e
      Err( "M_1156", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,8,-1)
      Show( "M_1157", r )
   RECOVER USING e
      Err( "M_1157", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,10,3)
      Show( "M_1158", r )
   RECOVER USING e
      Err( "M_1158", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,0,0)
      Show( "M_1159", r )
   RECOVER USING e
      Err( "M_1159", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,12,6)
      Show( "M_1160", r )
   RECOVER USING e
      Err( "M_1160", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5)
      Show( "M_1161", r )
   RECOVER USING e
      Err( "M_1161", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,8)
      Show( "M_1162", r )
   RECOVER USING e
      Err( "M_1162", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,3)
      Show( "M_1163", r )
   RECOVER USING e
      Err( "M_1163", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,20)
      Show( "M_1164", r )
   RECOVER USING e
      Err( "M_1164", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,5)
      Show( "M_1165", r )
   RECOVER USING e
      Err( "M_1165", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,10,2)
      Show( "M_1166", r )
   RECOVER USING e
      Err( "M_1166", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,10,0)
      Show( "M_1167", r )
   RECOVER USING e
      Err( "M_1167", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,10,1)
      Show( "M_1168", r )
   RECOVER USING e
      Err( "M_1168", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,5,2)
      Show( "M_1169", r )
   RECOVER USING e
      Err( "M_1169", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,4,2)
      Show( "M_1170", r )
   RECOVER USING e
      Err( "M_1170", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,3,0)
      Show( "M_1171", r )
   RECOVER USING e
      Err( "M_1171", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,2,0)
      Show( "M_1172", r )
   RECOVER USING e
      Err( "M_1172", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,1,0)
      Show( "M_1173", r )
   RECOVER USING e
      Err( "M_1173", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,6,3)
      Show( "M_1174", r )
   RECOVER USING e
      Err( "M_1174", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,20,15)
      Show( "M_1175", r )
   RECOVER USING e
      Err( "M_1175", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,30,20)
      Show( "M_1176", r )
   RECOVER USING e
      Err( "M_1176", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,8,-1)
      Show( "M_1177", r )
   RECOVER USING e
      Err( "M_1177", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,10,3)
      Show( "M_1178", r )
   RECOVER USING e
      Err( "M_1178", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,0,0)
      Show( "M_1179", r )
   RECOVER USING e
      Err( "M_1179", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,12,6)
      Show( "M_1180", r )
   RECOVER USING e
      Err( "M_1180", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5)
      Show( "M_1181", r )
   RECOVER USING e
      Err( "M_1181", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,8)
      Show( "M_1182", r )
   RECOVER USING e
      Err( "M_1182", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,3)
      Show( "M_1183", r )
   RECOVER USING e
      Err( "M_1183", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,20)
      Show( "M_1184", r )
   RECOVER USING e
      Err( "M_1184", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,5)
      Show( "M_1185", r )
   RECOVER USING e
      Err( "M_1185", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,10,2)
      Show( "M_1186", r )
   RECOVER USING e
      Err( "M_1186", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,10,0)
      Show( "M_1187", r )
   RECOVER USING e
      Err( "M_1187", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,10,1)
      Show( "M_1188", r )
   RECOVER USING e
      Err( "M_1188", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,5,2)
      Show( "M_1189", r )
   RECOVER USING e
      Err( "M_1189", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,4,2)
      Show( "M_1190", r )
   RECOVER USING e
      Err( "M_1190", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,3,0)
      Show( "M_1191", r )
   RECOVER USING e
      Err( "M_1191", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,2,0)
      Show( "M_1192", r )
   RECOVER USING e
      Err( "M_1192", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,1,0)
      Show( "M_1193", r )
   RECOVER USING e
      Err( "M_1193", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,6,3)
      Show( "M_1194", r )
   RECOVER USING e
      Err( "M_1194", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,20,15)
      Show( "M_1195", r )
   RECOVER USING e
      Err( "M_1195", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,30,20)
      Show( "M_1196", r )
   RECOVER USING e
      Err( "M_1196", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,8,-1)
      Show( "M_1197", r )
   RECOVER USING e
      Err( "M_1197", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,10,3)
      Show( "M_1198", r )
   RECOVER USING e
      Err( "M_1198", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,0,0)
      Show( "M_1199", r )
   RECOVER USING e
      Err( "M_1199", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,12,6)
      Show( "M_1200", r )
   RECOVER USING e
      Err( "M_1200", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5)
      Show( "M_1201", r )
   RECOVER USING e
      Err( "M_1201", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,8)
      Show( "M_1202", r )
   RECOVER USING e
      Err( "M_1202", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,3)
      Show( "M_1203", r )
   RECOVER USING e
      Err( "M_1203", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,20)
      Show( "M_1204", r )
   RECOVER USING e
      Err( "M_1204", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,5)
      Show( "M_1205", r )
   RECOVER USING e
      Err( "M_1205", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,10,2)
      Show( "M_1206", r )
   RECOVER USING e
      Err( "M_1206", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,10,0)
      Show( "M_1207", r )
   RECOVER USING e
      Err( "M_1207", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,10,1)
      Show( "M_1208", r )
   RECOVER USING e
      Err( "M_1208", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,5,2)
      Show( "M_1209", r )
   RECOVER USING e
      Err( "M_1209", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,4,2)
      Show( "M_1210", r )
   RECOVER USING e
      Err( "M_1210", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,3,0)
      Show( "M_1211", r )
   RECOVER USING e
      Err( "M_1211", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,2,0)
      Show( "M_1212", r )
   RECOVER USING e
      Err( "M_1212", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,1,0)
      Show( "M_1213", r )
   RECOVER USING e
      Err( "M_1213", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,6,3)
      Show( "M_1214", r )
   RECOVER USING e
      Err( "M_1214", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,20,15)
      Show( "M_1215", r )
   RECOVER USING e
      Err( "M_1215", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,30,20)
      Show( "M_1216", r )
   RECOVER USING e
      Err( "M_1216", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,8,-1)
      Show( "M_1217", r )
   RECOVER USING e
      Err( "M_1217", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,10,3)
      Show( "M_1218", r )
   RECOVER USING e
      Err( "M_1218", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,0,0)
      Show( "M_1219", r )
   RECOVER USING e
      Err( "M_1219", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,12,6)
      Show( "M_1220", r )
   RECOVER USING e
      Err( "M_1220", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5)
      Show( "M_1221", r )
   RECOVER USING e
      Err( "M_1221", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,8)
      Show( "M_1222", r )
   RECOVER USING e
      Err( "M_1222", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,3)
      Show( "M_1223", r )
   RECOVER USING e
      Err( "M_1223", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,20)
      Show( "M_1224", r )
   RECOVER USING e
      Err( "M_1224", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,5)
      Show( "M_1225", r )
   RECOVER USING e
      Err( "M_1225", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,10,2)
      Show( "M_1226", r )
   RECOVER USING e
      Err( "M_1226", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,10,0)
      Show( "M_1227", r )
   RECOVER USING e
      Err( "M_1227", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,10,1)
      Show( "M_1228", r )
   RECOVER USING e
      Err( "M_1228", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,5,2)
      Show( "M_1229", r )
   RECOVER USING e
      Err( "M_1229", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,4,2)
      Show( "M_1230", r )
   RECOVER USING e
      Err( "M_1230", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,3,0)
      Show( "M_1231", r )
   RECOVER USING e
      Err( "M_1231", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,2,0)
      Show( "M_1232", r )
   RECOVER USING e
      Err( "M_1232", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,1,0)
      Show( "M_1233", r )
   RECOVER USING e
      Err( "M_1233", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,6,3)
      Show( "M_1234", r )
   RECOVER USING e
      Err( "M_1234", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,20,15)
      Show( "M_1235", r )
   RECOVER USING e
      Err( "M_1235", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,30,20)
      Show( "M_1236", r )
   RECOVER USING e
      Err( "M_1236", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,8,-1)
      Show( "M_1237", r )
   RECOVER USING e
      Err( "M_1237", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,10,3)
      Show( "M_1238", r )
   RECOVER USING e
      Err( "M_1238", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,0,0)
      Show( "M_1239", r )
   RECOVER USING e
      Err( "M_1239", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,12,6)
      Show( "M_1240", r )
   RECOVER USING e
      Err( "M_1240", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995)
      Show( "M_1241", r )
   RECOVER USING e
      Err( "M_1241", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,8)
      Show( "M_1242", r )
   RECOVER USING e
      Err( "M_1242", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,3)
      Show( "M_1243", r )
   RECOVER USING e
      Err( "M_1243", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,20)
      Show( "M_1244", r )
   RECOVER USING e
      Err( "M_1244", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,5)
      Show( "M_1245", r )
   RECOVER USING e
      Err( "M_1245", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,10,2)
      Show( "M_1246", r )
   RECOVER USING e
      Err( "M_1246", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,10,0)
      Show( "M_1247", r )
   RECOVER USING e
      Err( "M_1247", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,10,1)
      Show( "M_1248", r )
   RECOVER USING e
      Err( "M_1248", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,5,2)
      Show( "M_1249", r )
   RECOVER USING e
      Err( "M_1249", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,4,2)
      Show( "M_1250", r )
   RECOVER USING e
      Err( "M_1250", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,3,0)
      Show( "M_1251", r )
   RECOVER USING e
      Err( "M_1251", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,2,0)
      Show( "M_1252", r )
   RECOVER USING e
      Err( "M_1252", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,1,0)
      Show( "M_1253", r )
   RECOVER USING e
      Err( "M_1253", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,6,3)
      Show( "M_1254", r )
   RECOVER USING e
      Err( "M_1254", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,20,15)
      Show( "M_1255", r )
   RECOVER USING e
      Err( "M_1255", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,30,20)
      Show( "M_1256", r )
   RECOVER USING e
      Err( "M_1256", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,8,-1)
      Show( "M_1257", r )
   RECOVER USING e
      Err( "M_1257", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,10,3)
      Show( "M_1258", r )
   RECOVER USING e
      Err( "M_1258", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,0,0)
      Show( "M_1259", r )
   RECOVER USING e
      Err( "M_1259", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,12,6)
      Show( "M_1260", r )
   RECOVER USING e
      Err( "M_1260", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995)
      Show( "M_1261", r )
   RECOVER USING e
      Err( "M_1261", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,8)
      Show( "M_1262", r )
   RECOVER USING e
      Err( "M_1262", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,3)
      Show( "M_1263", r )
   RECOVER USING e
      Err( "M_1263", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,20)
      Show( "M_1264", r )
   RECOVER USING e
      Err( "M_1264", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,5)
      Show( "M_1265", r )
   RECOVER USING e
      Err( "M_1265", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,10,2)
      Show( "M_1266", r )
   RECOVER USING e
      Err( "M_1266", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,10,0)
      Show( "M_1267", r )
   RECOVER USING e
      Err( "M_1267", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,10,1)
      Show( "M_1268", r )
   RECOVER USING e
      Err( "M_1268", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,5,2)
      Show( "M_1269", r )
   RECOVER USING e
      Err( "M_1269", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,4,2)
      Show( "M_1270", r )
   RECOVER USING e
      Err( "M_1270", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,3,0)
      Show( "M_1271", r )
   RECOVER USING e
      Err( "M_1271", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,2,0)
      Show( "M_1272", r )
   RECOVER USING e
      Err( "M_1272", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,1,0)
      Show( "M_1273", r )
   RECOVER USING e
      Err( "M_1273", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,6,3)
      Show( "M_1274", r )
   RECOVER USING e
      Err( "M_1274", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,20,15)
      Show( "M_1275", r )
   RECOVER USING e
      Err( "M_1275", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,30,20)
      Show( "M_1276", r )
   RECOVER USING e
      Err( "M_1276", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,8,-1)
      Show( "M_1277", r )
   RECOVER USING e
      Err( "M_1277", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,10,3)
      Show( "M_1278", r )
   RECOVER USING e
      Err( "M_1278", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,0,0)
      Show( "M_1279", r )
   RECOVER USING e
      Err( "M_1279", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,12,6)
      Show( "M_1280", r )
   RECOVER USING e
      Err( "M_1280", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5)
      Show( "M_1281", r )
   RECOVER USING e
      Err( "M_1281", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,8)
      Show( "M_1282", r )
   RECOVER USING e
      Err( "M_1282", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,3)
      Show( "M_1283", r )
   RECOVER USING e
      Err( "M_1283", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,20)
      Show( "M_1284", r )
   RECOVER USING e
      Err( "M_1284", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,5)
      Show( "M_1285", r )
   RECOVER USING e
      Err( "M_1285", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,10,2)
      Show( "M_1286", r )
   RECOVER USING e
      Err( "M_1286", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,10,0)
      Show( "M_1287", r )
   RECOVER USING e
      Err( "M_1287", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,10,1)
      Show( "M_1288", r )
   RECOVER USING e
      Err( "M_1288", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,5,2)
      Show( "M_1289", r )
   RECOVER USING e
      Err( "M_1289", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,4,2)
      Show( "M_1290", r )
   RECOVER USING e
      Err( "M_1290", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,3,0)
      Show( "M_1291", r )
   RECOVER USING e
      Err( "M_1291", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,2,0)
      Show( "M_1292", r )
   RECOVER USING e
      Err( "M_1292", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,1,0)
      Show( "M_1293", r )
   RECOVER USING e
      Err( "M_1293", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,6,3)
      Show( "M_1294", r )
   RECOVER USING e
      Err( "M_1294", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,20,15)
      Show( "M_1295", r )
   RECOVER USING e
      Err( "M_1295", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,30,20)
      Show( "M_1296", r )
   RECOVER USING e
      Err( "M_1296", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,8,-1)
      Show( "M_1297", r )
   RECOVER USING e
      Err( "M_1297", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,10,3)
      Show( "M_1298", r )
   RECOVER USING e
      Err( "M_1298", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,0,0)
      Show( "M_1299", r )
   RECOVER USING e
      Err( "M_1299", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,12,6)
      Show( "M_1300", r )
   RECOVER USING e
      Err( "M_1300", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5)
      Show( "M_1301", r )
   RECOVER USING e
      Err( "M_1301", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,8)
      Show( "M_1302", r )
   RECOVER USING e
      Err( "M_1302", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,3)
      Show( "M_1303", r )
   RECOVER USING e
      Err( "M_1303", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,20)
      Show( "M_1304", r )
   RECOVER USING e
      Err( "M_1304", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,5)
      Show( "M_1305", r )
   RECOVER USING e
      Err( "M_1305", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,10,2)
      Show( "M_1306", r )
   RECOVER USING e
      Err( "M_1306", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,10,0)
      Show( "M_1307", r )
   RECOVER USING e
      Err( "M_1307", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,10,1)
      Show( "M_1308", r )
   RECOVER USING e
      Err( "M_1308", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,5,2)
      Show( "M_1309", r )
   RECOVER USING e
      Err( "M_1309", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,4,2)
      Show( "M_1310", r )
   RECOVER USING e
      Err( "M_1310", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,3,0)
      Show( "M_1311", r )
   RECOVER USING e
      Err( "M_1311", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,2,0)
      Show( "M_1312", r )
   RECOVER USING e
      Err( "M_1312", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,1,0)
      Show( "M_1313", r )
   RECOVER USING e
      Err( "M_1313", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,6,3)
      Show( "M_1314", r )
   RECOVER USING e
      Err( "M_1314", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,20,15)
      Show( "M_1315", r )
   RECOVER USING e
      Err( "M_1315", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,30,20)
      Show( "M_1316", r )
   RECOVER USING e
      Err( "M_1316", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,8,-1)
      Show( "M_1317", r )
   RECOVER USING e
      Err( "M_1317", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,10,3)
      Show( "M_1318", r )
   RECOVER USING e
      Err( "M_1318", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,0,0)
      Show( "M_1319", r )
   RECOVER USING e
      Err( "M_1319", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,12,6)
      Show( "M_1320", r )
   RECOVER USING e
      Err( "M_1320", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5)
      Show( "M_1321", r )
   RECOVER USING e
      Err( "M_1321", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,8)
      Show( "M_1322", r )
   RECOVER USING e
      Err( "M_1322", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,3)
      Show( "M_1323", r )
   RECOVER USING e
      Err( "M_1323", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,20)
      Show( "M_1324", r )
   RECOVER USING e
      Err( "M_1324", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,5)
      Show( "M_1325", r )
   RECOVER USING e
      Err( "M_1325", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,10,2)
      Show( "M_1326", r )
   RECOVER USING e
      Err( "M_1326", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,10,0)
      Show( "M_1327", r )
   RECOVER USING e
      Err( "M_1327", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,10,1)
      Show( "M_1328", r )
   RECOVER USING e
      Err( "M_1328", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,5,2)
      Show( "M_1329", r )
   RECOVER USING e
      Err( "M_1329", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,4,2)
      Show( "M_1330", r )
   RECOVER USING e
      Err( "M_1330", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,3,0)
      Show( "M_1331", r )
   RECOVER USING e
      Err( "M_1331", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,2,0)
      Show( "M_1332", r )
   RECOVER USING e
      Err( "M_1332", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,1,0)
      Show( "M_1333", r )
   RECOVER USING e
      Err( "M_1333", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,6,3)
      Show( "M_1334", r )
   RECOVER USING e
      Err( "M_1334", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,20,15)
      Show( "M_1335", r )
   RECOVER USING e
      Err( "M_1335", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,30,20)
      Show( "M_1336", r )
   RECOVER USING e
      Err( "M_1336", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,8,-1)
      Show( "M_1337", r )
   RECOVER USING e
      Err( "M_1337", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,10,3)
      Show( "M_1338", r )
   RECOVER USING e
      Err( "M_1338", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,0,0)
      Show( "M_1339", r )
   RECOVER USING e
      Err( "M_1339", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,12,6)
      Show( "M_1340", r )
   RECOVER USING e
      Err( "M_1340", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045)
      Show( "M_1341", r )
   RECOVER USING e
      Err( "M_1341", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,8)
      Show( "M_1342", r )
   RECOVER USING e
      Err( "M_1342", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,3)
      Show( "M_1343", r )
   RECOVER USING e
      Err( "M_1343", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,20)
      Show( "M_1344", r )
   RECOVER USING e
      Err( "M_1344", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,5)
      Show( "M_1345", r )
   RECOVER USING e
      Err( "M_1345", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,10,2)
      Show( "M_1346", r )
   RECOVER USING e
      Err( "M_1346", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,10,0)
      Show( "M_1347", r )
   RECOVER USING e
      Err( "M_1347", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,10,1)
      Show( "M_1348", r )
   RECOVER USING e
      Err( "M_1348", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,5,2)
      Show( "M_1349", r )
   RECOVER USING e
      Err( "M_1349", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,4,2)
      Show( "M_1350", r )
   RECOVER USING e
      Err( "M_1350", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,3,0)
      Show( "M_1351", r )
   RECOVER USING e
      Err( "M_1351", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,2,0)
      Show( "M_1352", r )
   RECOVER USING e
      Err( "M_1352", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,1,0)
      Show( "M_1353", r )
   RECOVER USING e
      Err( "M_1353", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,6,3)
      Show( "M_1354", r )
   RECOVER USING e
      Err( "M_1354", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,20,15)
      Show( "M_1355", r )
   RECOVER USING e
      Err( "M_1355", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,30,20)
      Show( "M_1356", r )
   RECOVER USING e
      Err( "M_1356", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,8,-1)
      Show( "M_1357", r )
   RECOVER USING e
      Err( "M_1357", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,10,3)
      Show( "M_1358", r )
   RECOVER USING e
      Err( "M_1358", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,0,0)
      Show( "M_1359", r )
   RECOVER USING e
      Err( "M_1359", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,12,6)
      Show( "M_1360", r )
   RECOVER USING e
      Err( "M_1360", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45)
      Show( "M_1361", r )
   RECOVER USING e
      Err( "M_1361", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,8)
      Show( "M_1362", r )
   RECOVER USING e
      Err( "M_1362", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,3)
      Show( "M_1363", r )
   RECOVER USING e
      Err( "M_1363", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,20)
      Show( "M_1364", r )
   RECOVER USING e
      Err( "M_1364", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,5)
      Show( "M_1365", r )
   RECOVER USING e
      Err( "M_1365", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,10,2)
      Show( "M_1366", r )
   RECOVER USING e
      Err( "M_1366", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,10,0)
      Show( "M_1367", r )
   RECOVER USING e
      Err( "M_1367", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,10,1)
      Show( "M_1368", r )
   RECOVER USING e
      Err( "M_1368", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,5,2)
      Show( "M_1369", r )
   RECOVER USING e
      Err( "M_1369", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,4,2)
      Show( "M_1370", r )
   RECOVER USING e
      Err( "M_1370", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,3,0)
      Show( "M_1371", r )
   RECOVER USING e
      Err( "M_1371", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,2,0)
      Show( "M_1372", r )
   RECOVER USING e
      Err( "M_1372", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,1,0)
      Show( "M_1373", r )
   RECOVER USING e
      Err( "M_1373", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,6,3)
      Show( "M_1374", r )
   RECOVER USING e
      Err( "M_1374", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,20,15)
      Show( "M_1375", r )
   RECOVER USING e
      Err( "M_1375", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,30,20)
      Show( "M_1376", r )
   RECOVER USING e
      Err( "M_1376", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,8,-1)
      Show( "M_1377", r )
   RECOVER USING e
      Err( "M_1377", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,10,3)
      Show( "M_1378", r )
   RECOVER USING e
      Err( "M_1378", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,0,0)
      Show( "M_1379", r )
   RECOVER USING e
      Err( "M_1379", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,12,6)
      Show( "M_1380", r )
   RECOVER USING e
      Err( "M_1380", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55)
      Show( "M_1381", r )
   RECOVER USING e
      Err( "M_1381", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,8)
      Show( "M_1382", r )
   RECOVER USING e
      Err( "M_1382", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,3)
      Show( "M_1383", r )
   RECOVER USING e
      Err( "M_1383", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,20)
      Show( "M_1384", r )
   RECOVER USING e
      Err( "M_1384", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,5)
      Show( "M_1385", r )
   RECOVER USING e
      Err( "M_1385", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,10,2)
      Show( "M_1386", r )
   RECOVER USING e
      Err( "M_1386", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,10,0)
      Show( "M_1387", r )
   RECOVER USING e
      Err( "M_1387", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,10,1)
      Show( "M_1388", r )
   RECOVER USING e
      Err( "M_1388", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,5,2)
      Show( "M_1389", r )
   RECOVER USING e
      Err( "M_1389", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,4,2)
      Show( "M_1390", r )
   RECOVER USING e
      Err( "M_1390", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,3,0)
      Show( "M_1391", r )
   RECOVER USING e
      Err( "M_1391", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,2,0)
      Show( "M_1392", r )
   RECOVER USING e
      Err( "M_1392", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,1,0)
      Show( "M_1393", r )
   RECOVER USING e
      Err( "M_1393", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,6,3)
      Show( "M_1394", r )
   RECOVER USING e
      Err( "M_1394", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,20,15)
      Show( "M_1395", r )
   RECOVER USING e
      Err( "M_1395", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,30,20)
      Show( "M_1396", r )
   RECOVER USING e
      Err( "M_1396", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,8,-1)
      Show( "M_1397", r )
   RECOVER USING e
      Err( "M_1397", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,10,3)
      Show( "M_1398", r )
   RECOVER USING e
      Err( "M_1398", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,0,0)
      Show( "M_1399", r )
   RECOVER USING e
      Err( "M_1399", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,12,6)
      Show( "M_1400", r )
   RECOVER USING e
      Err( "M_1400", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456)
      Show( "M_1401", r )
   RECOVER USING e
      Err( "M_1401", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,8)
      Show( "M_1402", r )
   RECOVER USING e
      Err( "M_1402", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,3)
      Show( "M_1403", r )
   RECOVER USING e
      Err( "M_1403", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,20)
      Show( "M_1404", r )
   RECOVER USING e
      Err( "M_1404", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,5)
      Show( "M_1405", r )
   RECOVER USING e
      Err( "M_1405", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,10,2)
      Show( "M_1406", r )
   RECOVER USING e
      Err( "M_1406", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,10,0)
      Show( "M_1407", r )
   RECOVER USING e
      Err( "M_1407", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,10,1)
      Show( "M_1408", r )
   RECOVER USING e
      Err( "M_1408", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,5,2)
      Show( "M_1409", r )
   RECOVER USING e
      Err( "M_1409", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,4,2)
      Show( "M_1410", r )
   RECOVER USING e
      Err( "M_1410", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,3,0)
      Show( "M_1411", r )
   RECOVER USING e
      Err( "M_1411", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,2,0)
      Show( "M_1412", r )
   RECOVER USING e
      Err( "M_1412", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,1,0)
      Show( "M_1413", r )
   RECOVER USING e
      Err( "M_1413", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,6,3)
      Show( "M_1414", r )
   RECOVER USING e
      Err( "M_1414", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,20,15)
      Show( "M_1415", r )
   RECOVER USING e
      Err( "M_1415", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,30,20)
      Show( "M_1416", r )
   RECOVER USING e
      Err( "M_1416", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,8,-1)
      Show( "M_1417", r )
   RECOVER USING e
      Err( "M_1417", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,10,3)
      Show( "M_1418", r )
   RECOVER USING e
      Err( "M_1418", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,0,0)
      Show( "M_1419", r )
   RECOVER USING e
      Err( "M_1419", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,12,6)
      Show( "M_1420", r )
   RECOVER USING e
      Err( "M_1420", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456)
      Show( "M_1421", r )
   RECOVER USING e
      Err( "M_1421", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,8)
      Show( "M_1422", r )
   RECOVER USING e
      Err( "M_1422", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,3)
      Show( "M_1423", r )
   RECOVER USING e
      Err( "M_1423", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,20)
      Show( "M_1424", r )
   RECOVER USING e
      Err( "M_1424", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,5)
      Show( "M_1425", r )
   RECOVER USING e
      Err( "M_1425", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,10,2)
      Show( "M_1426", r )
   RECOVER USING e
      Err( "M_1426", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,10,0)
      Show( "M_1427", r )
   RECOVER USING e
      Err( "M_1427", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,10,1)
      Show( "M_1428", r )
   RECOVER USING e
      Err( "M_1428", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,5,2)
      Show( "M_1429", r )
   RECOVER USING e
      Err( "M_1429", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,4,2)
      Show( "M_1430", r )
   RECOVER USING e
      Err( "M_1430", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,3,0)
      Show( "M_1431", r )
   RECOVER USING e
      Err( "M_1431", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,2,0)
      Show( "M_1432", r )
   RECOVER USING e
      Err( "M_1432", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,1,0)
      Show( "M_1433", r )
   RECOVER USING e
      Err( "M_1433", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,6,3)
      Show( "M_1434", r )
   RECOVER USING e
      Err( "M_1434", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,20,15)
      Show( "M_1435", r )
   RECOVER USING e
      Err( "M_1435", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,30,20)
      Show( "M_1436", r )
   RECOVER USING e
      Err( "M_1436", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,8,-1)
      Show( "M_1437", r )
   RECOVER USING e
      Err( "M_1437", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,10,3)
      Show( "M_1438", r )
   RECOVER USING e
      Err( "M_1438", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,0,0)
      Show( "M_1439", r )
   RECOVER USING e
      Err( "M_1439", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,12,6)
      Show( "M_1440", r )
   RECOVER USING e
      Err( "M_1440", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789)
      Show( "M_1441", r )
   RECOVER USING e
      Err( "M_1441", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,8)
      Show( "M_1442", r )
   RECOVER USING e
      Err( "M_1442", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,3)
      Show( "M_1443", r )
   RECOVER USING e
      Err( "M_1443", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,20)
      Show( "M_1444", r )
   RECOVER USING e
      Err( "M_1444", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,5)
      Show( "M_1445", r )
   RECOVER USING e
      Err( "M_1445", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,10,2)
      Show( "M_1446", r )
   RECOVER USING e
      Err( "M_1446", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,10,0)
      Show( "M_1447", r )
   RECOVER USING e
      Err( "M_1447", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,10,1)
      Show( "M_1448", r )
   RECOVER USING e
      Err( "M_1448", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,5,2)
      Show( "M_1449", r )
   RECOVER USING e
      Err( "M_1449", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,4,2)
      Show( "M_1450", r )
   RECOVER USING e
      Err( "M_1450", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,3,0)
      Show( "M_1451", r )
   RECOVER USING e
      Err( "M_1451", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,2,0)
      Show( "M_1452", r )
   RECOVER USING e
      Err( "M_1452", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,1,0)
      Show( "M_1453", r )
   RECOVER USING e
      Err( "M_1453", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,6,3)
      Show( "M_1454", r )
   RECOVER USING e
      Err( "M_1454", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,20,15)
      Show( "M_1455", r )
   RECOVER USING e
      Err( "M_1455", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,30,20)
      Show( "M_1456", r )
   RECOVER USING e
      Err( "M_1456", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,8,-1)
      Show( "M_1457", r )
   RECOVER USING e
      Err( "M_1457", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,10,3)
      Show( "M_1458", r )
   RECOVER USING e
      Err( "M_1458", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,0,0)
      Show( "M_1459", r )
   RECOVER USING e
      Err( "M_1459", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,12,6)
      Show( "M_1460", r )
   RECOVER USING e
      Err( "M_1460", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000)
      Show( "M_1461", r )
   RECOVER USING e
      Err( "M_1461", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,8)
      Show( "M_1462", r )
   RECOVER USING e
      Err( "M_1462", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,3)
      Show( "M_1463", r )
   RECOVER USING e
      Err( "M_1463", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,20)
      Show( "M_1464", r )
   RECOVER USING e
      Err( "M_1464", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,5)
      Show( "M_1465", r )
   RECOVER USING e
      Err( "M_1465", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,10,2)
      Show( "M_1466", r )
   RECOVER USING e
      Err( "M_1466", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,10,0)
      Show( "M_1467", r )
   RECOVER USING e
      Err( "M_1467", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,10,1)
      Show( "M_1468", r )
   RECOVER USING e
      Err( "M_1468", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,5,2)
      Show( "M_1469", r )
   RECOVER USING e
      Err( "M_1469", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,4,2)
      Show( "M_1470", r )
   RECOVER USING e
      Err( "M_1470", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,3,0)
      Show( "M_1471", r )
   RECOVER USING e
      Err( "M_1471", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,2,0)
      Show( "M_1472", r )
   RECOVER USING e
      Err( "M_1472", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,1,0)
      Show( "M_1473", r )
   RECOVER USING e
      Err( "M_1473", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,6,3)
      Show( "M_1474", r )
   RECOVER USING e
      Err( "M_1474", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,20,15)
      Show( "M_1475", r )
   RECOVER USING e
      Err( "M_1475", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,30,20)
      Show( "M_1476", r )
   RECOVER USING e
      Err( "M_1476", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,8,-1)
      Show( "M_1477", r )
   RECOVER USING e
      Err( "M_1477", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,10,3)
      Show( "M_1478", r )
   RECOVER USING e
      Err( "M_1478", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,0,0)
      Show( "M_1479", r )
   RECOVER USING e
      Err( "M_1479", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,12,6)
      Show( "M_1480", r )
   RECOVER USING e
      Err( "M_1480", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5)
      Show( "M_1481", r )
   RECOVER USING e
      Err( "M_1481", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,8)
      Show( "M_1482", r )
   RECOVER USING e
      Err( "M_1482", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,3)
      Show( "M_1483", r )
   RECOVER USING e
      Err( "M_1483", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,20)
      Show( "M_1484", r )
   RECOVER USING e
      Err( "M_1484", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,5)
      Show( "M_1485", r )
   RECOVER USING e
      Err( "M_1485", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,10,2)
      Show( "M_1486", r )
   RECOVER USING e
      Err( "M_1486", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,10,0)
      Show( "M_1487", r )
   RECOVER USING e
      Err( "M_1487", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,10,1)
      Show( "M_1488", r )
   RECOVER USING e
      Err( "M_1488", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,5,2)
      Show( "M_1489", r )
   RECOVER USING e
      Err( "M_1489", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,4,2)
      Show( "M_1490", r )
   RECOVER USING e
      Err( "M_1490", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,3,0)
      Show( "M_1491", r )
   RECOVER USING e
      Err( "M_1491", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,2,0)
      Show( "M_1492", r )
   RECOVER USING e
      Err( "M_1492", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,1,0)
      Show( "M_1493", r )
   RECOVER USING e
      Err( "M_1493", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,6,3)
      Show( "M_1494", r )
   RECOVER USING e
      Err( "M_1494", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,20,15)
      Show( "M_1495", r )
   RECOVER USING e
      Err( "M_1495", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,30,20)
      Show( "M_1496", r )
   RECOVER USING e
      Err( "M_1496", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,8,-1)
      Show( "M_1497", r )
   RECOVER USING e
      Err( "M_1497", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,10,3)
      Show( "M_1498", r )
   RECOVER USING e
      Err( "M_1498", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,0,0)
      Show( "M_1499", r )
   RECOVER USING e
      Err( "M_1499", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,12,6)
      Show( "M_1500", r )
   RECOVER USING e
      Err( "M_1500", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2)
      Show( "M_1501", r )
   RECOVER USING e
      Err( "M_1501", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,8)
      Show( "M_1502", r )
   RECOVER USING e
      Err( "M_1502", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,3)
      Show( "M_1503", r )
   RECOVER USING e
      Err( "M_1503", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,20)
      Show( "M_1504", r )
   RECOVER USING e
      Err( "M_1504", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,5)
      Show( "M_1505", r )
   RECOVER USING e
      Err( "M_1505", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,10,2)
      Show( "M_1506", r )
   RECOVER USING e
      Err( "M_1506", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,10,0)
      Show( "M_1507", r )
   RECOVER USING e
      Err( "M_1507", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,10,1)
      Show( "M_1508", r )
   RECOVER USING e
      Err( "M_1508", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,5,2)
      Show( "M_1509", r )
   RECOVER USING e
      Err( "M_1509", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,4,2)
      Show( "M_1510", r )
   RECOVER USING e
      Err( "M_1510", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,3,0)
      Show( "M_1511", r )
   RECOVER USING e
      Err( "M_1511", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,2,0)
      Show( "M_1512", r )
   RECOVER USING e
      Err( "M_1512", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,1,0)
      Show( "M_1513", r )
   RECOVER USING e
      Err( "M_1513", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,6,3)
      Show( "M_1514", r )
   RECOVER USING e
      Err( "M_1514", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,20,15)
      Show( "M_1515", r )
   RECOVER USING e
      Err( "M_1515", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,30,20)
      Show( "M_1516", r )
   RECOVER USING e
      Err( "M_1516", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,8,-1)
      Show( "M_1517", r )
   RECOVER USING e
      Err( "M_1517", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,10,3)
      Show( "M_1518", r )
   RECOVER USING e
      Err( "M_1518", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,0,0)
      Show( "M_1519", r )
   RECOVER USING e
      Err( "M_1519", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,12,6)
      Show( "M_1520", r )
   RECOVER USING e
      Err( "M_1520", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3)
      Show( "M_1521", r )
   RECOVER USING e
      Err( "M_1521", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,8)
      Show( "M_1522", r )
   RECOVER USING e
      Err( "M_1522", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,3)
      Show( "M_1523", r )
   RECOVER USING e
      Err( "M_1523", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,20)
      Show( "M_1524", r )
   RECOVER USING e
      Err( "M_1524", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,5)
      Show( "M_1525", r )
   RECOVER USING e
      Err( "M_1525", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),4,0)
      Show( "M_1526", r )
   RECOVER USING e
      Err( "M_1526", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),4)
      Show( "M_1527", r )
   RECOVER USING e
      Err( "M_1527", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,4,0))
      Show( "M_1528", r )
   RECOVER USING e
      Err( "M_1528", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,14,3)),0)
      Show( "M_1529", r )
   RECOVER USING e
      Err( "M_1529", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),6,0)
      Show( "M_1530", r )
   RECOVER USING e
      Err( "M_1530", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),6)
      Show( "M_1531", r )
   RECOVER USING e
      Err( "M_1531", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,6,0))
      Show( "M_1532", r )
   RECOVER USING e
      Err( "M_1532", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,16,3)),0)
      Show( "M_1533", r )
   RECOVER USING e
      Err( "M_1533", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),10,0)
      Show( "M_1534", r )
   RECOVER USING e
      Err( "M_1534", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),10)
      Show( "M_1535", r )
   RECOVER USING e
      Err( "M_1535", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,0))
      Show( "M_1536", r )
   RECOVER USING e
      Err( "M_1536", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,20,3)),0)
      Show( "M_1537", r )
   RECOVER USING e
      Err( "M_1537", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),4,1)
      Show( "M_1538", r )
   RECOVER USING e
      Err( "M_1538", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),4)
      Show( "M_1539", r )
   RECOVER USING e
      Err( "M_1539", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,4,1))
      Show( "M_1540", r )
   RECOVER USING e
      Err( "M_1540", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,14,4)),1)
      Show( "M_1541", r )
   RECOVER USING e
      Err( "M_1541", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),6,1)
      Show( "M_1542", r )
   RECOVER USING e
      Err( "M_1542", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),6)
      Show( "M_1543", r )
   RECOVER USING e
      Err( "M_1543", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,6,1))
      Show( "M_1544", r )
   RECOVER USING e
      Err( "M_1544", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,16,4)),1)
      Show( "M_1545", r )
   RECOVER USING e
      Err( "M_1545", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),10,1)
      Show( "M_1546", r )
   RECOVER USING e
      Err( "M_1546", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),10)
      Show( "M_1547", r )
   RECOVER USING e
      Err( "M_1547", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,1))
      Show( "M_1548", r )
   RECOVER USING e
      Err( "M_1548", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,20,4)),1)
      Show( "M_1549", r )
   RECOVER USING e
      Err( "M_1549", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),4,2)
      Show( "M_1550", r )
   RECOVER USING e
      Err( "M_1550", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),4)
      Show( "M_1551", r )
   RECOVER USING e
      Err( "M_1551", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,4,2))
      Show( "M_1552", r )
   RECOVER USING e
      Err( "M_1552", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,14,5)),2)
      Show( "M_1553", r )
   RECOVER USING e
      Err( "M_1553", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),6,2)
      Show( "M_1554", r )
   RECOVER USING e
      Err( "M_1554", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),6)
      Show( "M_1555", r )
   RECOVER USING e
      Err( "M_1555", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,6,2))
      Show( "M_1556", r )
   RECOVER USING e
      Err( "M_1556", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,16,5)),2)
      Show( "M_1557", r )
   RECOVER USING e
      Err( "M_1557", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),10,2)
      Show( "M_1558", r )
   RECOVER USING e
      Err( "M_1558", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),10)
      Show( "M_1559", r )
   RECOVER USING e
      Err( "M_1559", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,2))
      Show( "M_1560", r )
   RECOVER USING e
      Err( "M_1560", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,20,5)),2)
      Show( "M_1561", r )
   RECOVER USING e
      Err( "M_1561", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),4,3)
      Show( "M_1562", r )
   RECOVER USING e
      Err( "M_1562", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),4)
      Show( "M_1563", r )
   RECOVER USING e
      Err( "M_1563", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,4,3))
      Show( "M_1564", r )
   RECOVER USING e
      Err( "M_1564", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,14,6)),3)
      Show( "M_1565", r )
   RECOVER USING e
      Err( "M_1565", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),6,3)
      Show( "M_1566", r )
   RECOVER USING e
      Err( "M_1566", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),6)
      Show( "M_1567", r )
   RECOVER USING e
      Err( "M_1567", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,6,3))
      Show( "M_1568", r )
   RECOVER USING e
      Err( "M_1568", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,16,6)),3)
      Show( "M_1569", r )
   RECOVER USING e
      Err( "M_1569", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),10,3)
      Show( "M_1570", r )
   RECOVER USING e
      Err( "M_1570", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),10)
      Show( "M_1571", r )
   RECOVER USING e
      Err( "M_1571", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,3))
      Show( "M_1572", r )
   RECOVER USING e
      Err( "M_1572", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,20,6)),3)
      Show( "M_1573", r )
   RECOVER USING e
      Err( "M_1573", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),4,0)
      Show( "M_1574", r )
   RECOVER USING e
      Err( "M_1574", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),4)
      Show( "M_1575", r )
   RECOVER USING e
      Err( "M_1575", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,4,0))
      Show( "M_1576", r )
   RECOVER USING e
      Err( "M_1576", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,14,3)),0)
      Show( "M_1577", r )
   RECOVER USING e
      Err( "M_1577", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),6,0)
      Show( "M_1578", r )
   RECOVER USING e
      Err( "M_1578", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),6)
      Show( "M_1579", r )
   RECOVER USING e
      Err( "M_1579", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,6,0))
      Show( "M_1580", r )
   RECOVER USING e
      Err( "M_1580", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,16,3)),0)
      Show( "M_1581", r )
   RECOVER USING e
      Err( "M_1581", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),10,0)
      Show( "M_1582", r )
   RECOVER USING e
      Err( "M_1582", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),10)
      Show( "M_1583", r )
   RECOVER USING e
      Err( "M_1583", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,0))
      Show( "M_1584", r )
   RECOVER USING e
      Err( "M_1584", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,20,3)),0)
      Show( "M_1585", r )
   RECOVER USING e
      Err( "M_1585", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),4,1)
      Show( "M_1586", r )
   RECOVER USING e
      Err( "M_1586", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),4)
      Show( "M_1587", r )
   RECOVER USING e
      Err( "M_1587", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,4,1))
      Show( "M_1588", r )
   RECOVER USING e
      Err( "M_1588", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,14,4)),1)
      Show( "M_1589", r )
   RECOVER USING e
      Err( "M_1589", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),6,1)
      Show( "M_1590", r )
   RECOVER USING e
      Err( "M_1590", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),6)
      Show( "M_1591", r )
   RECOVER USING e
      Err( "M_1591", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,6,1))
      Show( "M_1592", r )
   RECOVER USING e
      Err( "M_1592", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,16,4)),1)
      Show( "M_1593", r )
   RECOVER USING e
      Err( "M_1593", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),10,1)
      Show( "M_1594", r )
   RECOVER USING e
      Err( "M_1594", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),10)
      Show( "M_1595", r )
   RECOVER USING e
      Err( "M_1595", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,1))
      Show( "M_1596", r )
   RECOVER USING e
      Err( "M_1596", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,20,4)),1)
      Show( "M_1597", r )
   RECOVER USING e
      Err( "M_1597", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),4,2)
      Show( "M_1598", r )
   RECOVER USING e
      Err( "M_1598", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),4)
      Show( "M_1599", r )
   RECOVER USING e
      Err( "M_1599", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,4,2))
      Show( "M_1600", r )
   RECOVER USING e
      Err( "M_1600", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,14,5)),2)
      Show( "M_1601", r )
   RECOVER USING e
      Err( "M_1601", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),6,2)
      Show( "M_1602", r )
   RECOVER USING e
      Err( "M_1602", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),6)
      Show( "M_1603", r )
   RECOVER USING e
      Err( "M_1603", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,6,2))
      Show( "M_1604", r )
   RECOVER USING e
      Err( "M_1604", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,16,5)),2)
      Show( "M_1605", r )
   RECOVER USING e
      Err( "M_1605", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),10,2)
      Show( "M_1606", r )
   RECOVER USING e
      Err( "M_1606", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),10)
      Show( "M_1607", r )
   RECOVER USING e
      Err( "M_1607", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,2))
      Show( "M_1608", r )
   RECOVER USING e
      Err( "M_1608", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,20,5)),2)
      Show( "M_1609", r )
   RECOVER USING e
      Err( "M_1609", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),4,3)
      Show( "M_1610", r )
   RECOVER USING e
      Err( "M_1610", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),4)
      Show( "M_1611", r )
   RECOVER USING e
      Err( "M_1611", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,4,3))
      Show( "M_1612", r )
   RECOVER USING e
      Err( "M_1612", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,14,6)),3)
      Show( "M_1613", r )
   RECOVER USING e
      Err( "M_1613", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),6,3)
      Show( "M_1614", r )
   RECOVER USING e
      Err( "M_1614", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),6)
      Show( "M_1615", r )
   RECOVER USING e
      Err( "M_1615", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,6,3))
      Show( "M_1616", r )
   RECOVER USING e
      Err( "M_1616", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,16,6)),3)
      Show( "M_1617", r )
   RECOVER USING e
      Err( "M_1617", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),10,3)
      Show( "M_1618", r )
   RECOVER USING e
      Err( "M_1618", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),10)
      Show( "M_1619", r )
   RECOVER USING e
      Err( "M_1619", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,3))
      Show( "M_1620", r )
   RECOVER USING e
      Err( "M_1620", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,20,6)),3)
      Show( "M_1621", r )
   RECOVER USING e
      Err( "M_1621", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),4,0)
      Show( "M_1622", r )
   RECOVER USING e
      Err( "M_1622", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),4)
      Show( "M_1623", r )
   RECOVER USING e
      Err( "M_1623", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,4,0))
      Show( "M_1624", r )
   RECOVER USING e
      Err( "M_1624", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,14,3)),0)
      Show( "M_1625", r )
   RECOVER USING e
      Err( "M_1625", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),6,0)
      Show( "M_1626", r )
   RECOVER USING e
      Err( "M_1626", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),6)
      Show( "M_1627", r )
   RECOVER USING e
      Err( "M_1627", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,6,0))
      Show( "M_1628", r )
   RECOVER USING e
      Err( "M_1628", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,16,3)),0)
      Show( "M_1629", r )
   RECOVER USING e
      Err( "M_1629", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),10,0)
      Show( "M_1630", r )
   RECOVER USING e
      Err( "M_1630", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),10)
      Show( "M_1631", r )
   RECOVER USING e
      Err( "M_1631", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,0))
      Show( "M_1632", r )
   RECOVER USING e
      Err( "M_1632", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,20,3)),0)
      Show( "M_1633", r )
   RECOVER USING e
      Err( "M_1633", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),4,1)
      Show( "M_1634", r )
   RECOVER USING e
      Err( "M_1634", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),4)
      Show( "M_1635", r )
   RECOVER USING e
      Err( "M_1635", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,4,1))
      Show( "M_1636", r )
   RECOVER USING e
      Err( "M_1636", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,14,4)),1)
      Show( "M_1637", r )
   RECOVER USING e
      Err( "M_1637", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),6,1)
      Show( "M_1638", r )
   RECOVER USING e
      Err( "M_1638", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),6)
      Show( "M_1639", r )
   RECOVER USING e
      Err( "M_1639", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,6,1))
      Show( "M_1640", r )
   RECOVER USING e
      Err( "M_1640", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,16,4)),1)
      Show( "M_1641", r )
   RECOVER USING e
      Err( "M_1641", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),10,1)
      Show( "M_1642", r )
   RECOVER USING e
      Err( "M_1642", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),10)
      Show( "M_1643", r )
   RECOVER USING e
      Err( "M_1643", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,1))
      Show( "M_1644", r )
   RECOVER USING e
      Err( "M_1644", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,20,4)),1)
      Show( "M_1645", r )
   RECOVER USING e
      Err( "M_1645", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),4,2)
      Show( "M_1646", r )
   RECOVER USING e
      Err( "M_1646", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),4)
      Show( "M_1647", r )
   RECOVER USING e
      Err( "M_1647", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,4,2))
      Show( "M_1648", r )
   RECOVER USING e
      Err( "M_1648", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,14,5)),2)
      Show( "M_1649", r )
   RECOVER USING e
      Err( "M_1649", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),6,2)
      Show( "M_1650", r )
   RECOVER USING e
      Err( "M_1650", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),6)
      Show( "M_1651", r )
   RECOVER USING e
      Err( "M_1651", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,6,2))
      Show( "M_1652", r )
   RECOVER USING e
      Err( "M_1652", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,16,5)),2)
      Show( "M_1653", r )
   RECOVER USING e
      Err( "M_1653", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),10,2)
      Show( "M_1654", r )
   RECOVER USING e
      Err( "M_1654", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),10)
      Show( "M_1655", r )
   RECOVER USING e
      Err( "M_1655", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,2))
      Show( "M_1656", r )
   RECOVER USING e
      Err( "M_1656", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,20,5)),2)
      Show( "M_1657", r )
   RECOVER USING e
      Err( "M_1657", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),4,3)
      Show( "M_1658", r )
   RECOVER USING e
      Err( "M_1658", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),4)
      Show( "M_1659", r )
   RECOVER USING e
      Err( "M_1659", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,4,3))
      Show( "M_1660", r )
   RECOVER USING e
      Err( "M_1660", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,14,6)),3)
      Show( "M_1661", r )
   RECOVER USING e
      Err( "M_1661", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),6,3)
      Show( "M_1662", r )
   RECOVER USING e
      Err( "M_1662", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),6)
      Show( "M_1663", r )
   RECOVER USING e
      Err( "M_1663", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,6,3))
      Show( "M_1664", r )
   RECOVER USING e
      Err( "M_1664", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,16,6)),3)
      Show( "M_1665", r )
   RECOVER USING e
      Err( "M_1665", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),10,3)
      Show( "M_1666", r )
   RECOVER USING e
      Err( "M_1666", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),10)
      Show( "M_1667", r )
   RECOVER USING e
      Err( "M_1667", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,3))
      Show( "M_1668", r )
   RECOVER USING e
      Err( "M_1668", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,20,6)),3)
      Show( "M_1669", r )
   RECOVER USING e
      Err( "M_1669", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),4,0)
      Show( "M_1670", r )
   RECOVER USING e
      Err( "M_1670", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),4)
      Show( "M_1671", r )
   RECOVER USING e
      Err( "M_1671", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,4,0))
      Show( "M_1672", r )
   RECOVER USING e
      Err( "M_1672", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,14,3)),0)
      Show( "M_1673", r )
   RECOVER USING e
      Err( "M_1673", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),6,0)
      Show( "M_1674", r )
   RECOVER USING e
      Err( "M_1674", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),6)
      Show( "M_1675", r )
   RECOVER USING e
      Err( "M_1675", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,6,0))
      Show( "M_1676", r )
   RECOVER USING e
      Err( "M_1676", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,16,3)),0)
      Show( "M_1677", r )
   RECOVER USING e
      Err( "M_1677", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),10,0)
      Show( "M_1678", r )
   RECOVER USING e
      Err( "M_1678", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),10)
      Show( "M_1679", r )
   RECOVER USING e
      Err( "M_1679", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,0))
      Show( "M_1680", r )
   RECOVER USING e
      Err( "M_1680", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,20,3)),0)
      Show( "M_1681", r )
   RECOVER USING e
      Err( "M_1681", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),4,1)
      Show( "M_1682", r )
   RECOVER USING e
      Err( "M_1682", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),4)
      Show( "M_1683", r )
   RECOVER USING e
      Err( "M_1683", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,4,1))
      Show( "M_1684", r )
   RECOVER USING e
      Err( "M_1684", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,14,4)),1)
      Show( "M_1685", r )
   RECOVER USING e
      Err( "M_1685", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),6,1)
      Show( "M_1686", r )
   RECOVER USING e
      Err( "M_1686", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),6)
      Show( "M_1687", r )
   RECOVER USING e
      Err( "M_1687", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,6,1))
      Show( "M_1688", r )
   RECOVER USING e
      Err( "M_1688", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,16,4)),1)
      Show( "M_1689", r )
   RECOVER USING e
      Err( "M_1689", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),10,1)
      Show( "M_1690", r )
   RECOVER USING e
      Err( "M_1690", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),10)
      Show( "M_1691", r )
   RECOVER USING e
      Err( "M_1691", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,1))
      Show( "M_1692", r )
   RECOVER USING e
      Err( "M_1692", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,20,4)),1)
      Show( "M_1693", r )
   RECOVER USING e
      Err( "M_1693", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),4,2)
      Show( "M_1694", r )
   RECOVER USING e
      Err( "M_1694", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),4)
      Show( "M_1695", r )
   RECOVER USING e
      Err( "M_1695", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,4,2))
      Show( "M_1696", r )
   RECOVER USING e
      Err( "M_1696", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,14,5)),2)
      Show( "M_1697", r )
   RECOVER USING e
      Err( "M_1697", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),6,2)
      Show( "M_1698", r )
   RECOVER USING e
      Err( "M_1698", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),6)
      Show( "M_1699", r )
   RECOVER USING e
      Err( "M_1699", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,6,2))
      Show( "M_1700", r )
   RECOVER USING e
      Err( "M_1700", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,16,5)),2)
      Show( "M_1701", r )
   RECOVER USING e
      Err( "M_1701", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),10,2)
      Show( "M_1702", r )
   RECOVER USING e
      Err( "M_1702", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),10)
      Show( "M_1703", r )
   RECOVER USING e
      Err( "M_1703", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,2))
      Show( "M_1704", r )
   RECOVER USING e
      Err( "M_1704", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,20,5)),2)
      Show( "M_1705", r )
   RECOVER USING e
      Err( "M_1705", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),4,3)
      Show( "M_1706", r )
   RECOVER USING e
      Err( "M_1706", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),4)
      Show( "M_1707", r )
   RECOVER USING e
      Err( "M_1707", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,4,3))
      Show( "M_1708", r )
   RECOVER USING e
      Err( "M_1708", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,14,6)),3)
      Show( "M_1709", r )
   RECOVER USING e
      Err( "M_1709", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),6,3)
      Show( "M_1710", r )
   RECOVER USING e
      Err( "M_1710", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),6)
      Show( "M_1711", r )
   RECOVER USING e
      Err( "M_1711", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,6,3))
      Show( "M_1712", r )
   RECOVER USING e
      Err( "M_1712", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,16,6)),3)
      Show( "M_1713", r )
   RECOVER USING e
      Err( "M_1713", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),10,3)
      Show( "M_1714", r )
   RECOVER USING e
      Err( "M_1714", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),10)
      Show( "M_1715", r )
   RECOVER USING e
      Err( "M_1715", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,3))
      Show( "M_1716", r )
   RECOVER USING e
      Err( "M_1716", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,20,6)),3)
      Show( "M_1717", r )
   RECOVER USING e
      Err( "M_1717", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),4,0)
      Show( "M_1718", r )
   RECOVER USING e
      Err( "M_1718", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),4)
      Show( "M_1719", r )
   RECOVER USING e
      Err( "M_1719", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,4,0))
      Show( "M_1720", r )
   RECOVER USING e
      Err( "M_1720", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,14,3)),0)
      Show( "M_1721", r )
   RECOVER USING e
      Err( "M_1721", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),6,0)
      Show( "M_1722", r )
   RECOVER USING e
      Err( "M_1722", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),6)
      Show( "M_1723", r )
   RECOVER USING e
      Err( "M_1723", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,6,0))
      Show( "M_1724", r )
   RECOVER USING e
      Err( "M_1724", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,16,3)),0)
      Show( "M_1725", r )
   RECOVER USING e
      Err( "M_1725", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),10,0)
      Show( "M_1726", r )
   RECOVER USING e
      Err( "M_1726", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),10)
      Show( "M_1727", r )
   RECOVER USING e
      Err( "M_1727", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,10,0))
      Show( "M_1728", r )
   RECOVER USING e
      Err( "M_1728", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,20,3)),0)
      Show( "M_1729", r )
   RECOVER USING e
      Err( "M_1729", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),4,1)
      Show( "M_1730", r )
   RECOVER USING e
      Err( "M_1730", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),4)
      Show( "M_1731", r )
   RECOVER USING e
      Err( "M_1731", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,4,1))
      Show( "M_1732", r )
   RECOVER USING e
      Err( "M_1732", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,14,4)),1)
      Show( "M_1733", r )
   RECOVER USING e
      Err( "M_1733", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),6,1)
      Show( "M_1734", r )
   RECOVER USING e
      Err( "M_1734", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),6)
      Show( "M_1735", r )
   RECOVER USING e
      Err( "M_1735", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,6,1))
      Show( "M_1736", r )
   RECOVER USING e
      Err( "M_1736", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,16,4)),1)
      Show( "M_1737", r )
   RECOVER USING e
      Err( "M_1737", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),10,1)
      Show( "M_1738", r )
   RECOVER USING e
      Err( "M_1738", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),10)
      Show( "M_1739", r )
   RECOVER USING e
      Err( "M_1739", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,10,1))
      Show( "M_1740", r )
   RECOVER USING e
      Err( "M_1740", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,20,4)),1)
      Show( "M_1741", r )
   RECOVER USING e
      Err( "M_1741", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),4,2)
      Show( "M_1742", r )
   RECOVER USING e
      Err( "M_1742", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),4)
      Show( "M_1743", r )
   RECOVER USING e
      Err( "M_1743", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,4,2))
      Show( "M_1744", r )
   RECOVER USING e
      Err( "M_1744", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,14,5)),2)
      Show( "M_1745", r )
   RECOVER USING e
      Err( "M_1745", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),6,2)
      Show( "M_1746", r )
   RECOVER USING e
      Err( "M_1746", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),6)
      Show( "M_1747", r )
   RECOVER USING e
      Err( "M_1747", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,6,2))
      Show( "M_1748", r )
   RECOVER USING e
      Err( "M_1748", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,16,5)),2)
      Show( "M_1749", r )
   RECOVER USING e
      Err( "M_1749", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),10,2)
      Show( "M_1750", r )
   RECOVER USING e
      Err( "M_1750", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),10)
      Show( "M_1751", r )
   RECOVER USING e
      Err( "M_1751", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,10,2))
      Show( "M_1752", r )
   RECOVER USING e
      Err( "M_1752", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,20,5)),2)
      Show( "M_1753", r )
   RECOVER USING e
      Err( "M_1753", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),4,3)
      Show( "M_1754", r )
   RECOVER USING e
      Err( "M_1754", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),4)
      Show( "M_1755", r )
   RECOVER USING e
      Err( "M_1755", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,4,3))
      Show( "M_1756", r )
   RECOVER USING e
      Err( "M_1756", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,14,6)),3)
      Show( "M_1757", r )
   RECOVER USING e
      Err( "M_1757", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),6,3)
      Show( "M_1758", r )
   RECOVER USING e
      Err( "M_1758", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),6)
      Show( "M_1759", r )
   RECOVER USING e
      Err( "M_1759", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,6,3))
      Show( "M_1760", r )
   RECOVER USING e
      Err( "M_1760", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,16,6)),3)
      Show( "M_1761", r )
   RECOVER USING e
      Err( "M_1761", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),10,3)
      Show( "M_1762", r )
   RECOVER USING e
      Err( "M_1762", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),10)
      Show( "M_1763", r )
   RECOVER USING e
      Err( "M_1763", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,10,3))
      Show( "M_1764", r )
   RECOVER USING e
      Err( "M_1764", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,20,6)),3)
      Show( "M_1765", r )
   RECOVER USING e
      Err( "M_1765", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),4,0)
      Show( "M_1766", r )
   RECOVER USING e
      Err( "M_1766", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),4)
      Show( "M_1767", r )
   RECOVER USING e
      Err( "M_1767", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,4,0))
      Show( "M_1768", r )
   RECOVER USING e
      Err( "M_1768", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,14,3)),0)
      Show( "M_1769", r )
   RECOVER USING e
      Err( "M_1769", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),6,0)
      Show( "M_1770", r )
   RECOVER USING e
      Err( "M_1770", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),6)
      Show( "M_1771", r )
   RECOVER USING e
      Err( "M_1771", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,6,0))
      Show( "M_1772", r )
   RECOVER USING e
      Err( "M_1772", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,16,3)),0)
      Show( "M_1773", r )
   RECOVER USING e
      Err( "M_1773", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),10,0)
      Show( "M_1774", r )
   RECOVER USING e
      Err( "M_1774", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),10)
      Show( "M_1775", r )
   RECOVER USING e
      Err( "M_1775", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,10,0))
      Show( "M_1776", r )
   RECOVER USING e
      Err( "M_1776", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,20,3)),0)
      Show( "M_1777", r )
   RECOVER USING e
      Err( "M_1777", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),4,1)
      Show( "M_1778", r )
   RECOVER USING e
      Err( "M_1778", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),4)
      Show( "M_1779", r )
   RECOVER USING e
      Err( "M_1779", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,4,1))
      Show( "M_1780", r )
   RECOVER USING e
      Err( "M_1780", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,14,4)),1)
      Show( "M_1781", r )
   RECOVER USING e
      Err( "M_1781", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),6,1)
      Show( "M_1782", r )
   RECOVER USING e
      Err( "M_1782", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),6)
      Show( "M_1783", r )
   RECOVER USING e
      Err( "M_1783", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,6,1))
      Show( "M_1784", r )
   RECOVER USING e
      Err( "M_1784", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,16,4)),1)
      Show( "M_1785", r )
   RECOVER USING e
      Err( "M_1785", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),10,1)
      Show( "M_1786", r )
   RECOVER USING e
      Err( "M_1786", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),10)
      Show( "M_1787", r )
   RECOVER USING e
      Err( "M_1787", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,10,1))
      Show( "M_1788", r )
   RECOVER USING e
      Err( "M_1788", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,20,4)),1)
      Show( "M_1789", r )
   RECOVER USING e
      Err( "M_1789", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),4,2)
      Show( "M_1790", r )
   RECOVER USING e
      Err( "M_1790", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),4)
      Show( "M_1791", r )
   RECOVER USING e
      Err( "M_1791", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,4,2))
      Show( "M_1792", r )
   RECOVER USING e
      Err( "M_1792", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,14,5)),2)
      Show( "M_1793", r )
   RECOVER USING e
      Err( "M_1793", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),6,2)
      Show( "M_1794", r )
   RECOVER USING e
      Err( "M_1794", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),6)
      Show( "M_1795", r )
   RECOVER USING e
      Err( "M_1795", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,6,2))
      Show( "M_1796", r )
   RECOVER USING e
      Err( "M_1796", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,16,5)),2)
      Show( "M_1797", r )
   RECOVER USING e
      Err( "M_1797", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),10,2)
      Show( "M_1798", r )
   RECOVER USING e
      Err( "M_1798", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),10)
      Show( "M_1799", r )
   RECOVER USING e
      Err( "M_1799", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,10,2))
      Show( "M_1800", r )
   RECOVER USING e
      Err( "M_1800", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,20,5)),2)
      Show( "M_1801", r )
   RECOVER USING e
      Err( "M_1801", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),4,3)
      Show( "M_1802", r )
   RECOVER USING e
      Err( "M_1802", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),4)
      Show( "M_1803", r )
   RECOVER USING e
      Err( "M_1803", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,4,3))
      Show( "M_1804", r )
   RECOVER USING e
      Err( "M_1804", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,14,6)),3)
      Show( "M_1805", r )
   RECOVER USING e
      Err( "M_1805", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),6,3)
      Show( "M_1806", r )
   RECOVER USING e
      Err( "M_1806", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),6)
      Show( "M_1807", r )
   RECOVER USING e
      Err( "M_1807", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,6,3))
      Show( "M_1808", r )
   RECOVER USING e
      Err( "M_1808", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,16,6)),3)
      Show( "M_1809", r )
   RECOVER USING e
      Err( "M_1809", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),10,3)
      Show( "M_1810", r )
   RECOVER USING e
      Err( "M_1810", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),10)
      Show( "M_1811", r )
   RECOVER USING e
      Err( "M_1811", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,10,3))
      Show( "M_1812", r )
   RECOVER USING e
      Err( "M_1812", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,20,6)),3)
      Show( "M_1813", r )
   RECOVER USING e
      Err( "M_1813", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),4,0)
      Show( "M_1814", r )
   RECOVER USING e
      Err( "M_1814", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),4)
      Show( "M_1815", r )
   RECOVER USING e
      Err( "M_1815", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,4,0))
      Show( "M_1816", r )
   RECOVER USING e
      Err( "M_1816", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,14,3)),0)
      Show( "M_1817", r )
   RECOVER USING e
      Err( "M_1817", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),6,0)
      Show( "M_1818", r )
   RECOVER USING e
      Err( "M_1818", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),6)
      Show( "M_1819", r )
   RECOVER USING e
      Err( "M_1819", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,6,0))
      Show( "M_1820", r )
   RECOVER USING e
      Err( "M_1820", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,16,3)),0)
      Show( "M_1821", r )
   RECOVER USING e
      Err( "M_1821", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),10,0)
      Show( "M_1822", r )
   RECOVER USING e
      Err( "M_1822", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),10)
      Show( "M_1823", r )
   RECOVER USING e
      Err( "M_1823", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,0))
      Show( "M_1824", r )
   RECOVER USING e
      Err( "M_1824", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,20,3)),0)
      Show( "M_1825", r )
   RECOVER USING e
      Err( "M_1825", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),4,1)
      Show( "M_1826", r )
   RECOVER USING e
      Err( "M_1826", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),4)
      Show( "M_1827", r )
   RECOVER USING e
      Err( "M_1827", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,4,1))
      Show( "M_1828", r )
   RECOVER USING e
      Err( "M_1828", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,14,4)),1)
      Show( "M_1829", r )
   RECOVER USING e
      Err( "M_1829", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),6,1)
      Show( "M_1830", r )
   RECOVER USING e
      Err( "M_1830", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),6)
      Show( "M_1831", r )
   RECOVER USING e
      Err( "M_1831", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,6,1))
      Show( "M_1832", r )
   RECOVER USING e
      Err( "M_1832", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,16,4)),1)
      Show( "M_1833", r )
   RECOVER USING e
      Err( "M_1833", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),10,1)
      Show( "M_1834", r )
   RECOVER USING e
      Err( "M_1834", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),10)
      Show( "M_1835", r )
   RECOVER USING e
      Err( "M_1835", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,1))
      Show( "M_1836", r )
   RECOVER USING e
      Err( "M_1836", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,20,4)),1)
      Show( "M_1837", r )
   RECOVER USING e
      Err( "M_1837", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),4,2)
      Show( "M_1838", r )
   RECOVER USING e
      Err( "M_1838", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),4)
      Show( "M_1839", r )
   RECOVER USING e
      Err( "M_1839", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,4,2))
      Show( "M_1840", r )
   RECOVER USING e
      Err( "M_1840", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,14,5)),2)
      Show( "M_1841", r )
   RECOVER USING e
      Err( "M_1841", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),6,2)
      Show( "M_1842", r )
   RECOVER USING e
      Err( "M_1842", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),6)
      Show( "M_1843", r )
   RECOVER USING e
      Err( "M_1843", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,6,2))
      Show( "M_1844", r )
   RECOVER USING e
      Err( "M_1844", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,16,5)),2)
      Show( "M_1845", r )
   RECOVER USING e
      Err( "M_1845", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),10,2)
      Show( "M_1846", r )
   RECOVER USING e
      Err( "M_1846", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),10)
      Show( "M_1847", r )
   RECOVER USING e
      Err( "M_1847", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,2))
      Show( "M_1848", r )
   RECOVER USING e
      Err( "M_1848", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,20,5)),2)
      Show( "M_1849", r )
   RECOVER USING e
      Err( "M_1849", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),4,3)
      Show( "M_1850", r )
   RECOVER USING e
      Err( "M_1850", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),4)
      Show( "M_1851", r )
   RECOVER USING e
      Err( "M_1851", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,4,3))
      Show( "M_1852", r )
   RECOVER USING e
      Err( "M_1852", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,14,6)),3)
      Show( "M_1853", r )
   RECOVER USING e
      Err( "M_1853", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),6,3)
      Show( "M_1854", r )
   RECOVER USING e
      Err( "M_1854", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),6)
      Show( "M_1855", r )
   RECOVER USING e
      Err( "M_1855", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,6,3))
      Show( "M_1856", r )
   RECOVER USING e
      Err( "M_1856", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,16,6)),3)
      Show( "M_1857", r )
   RECOVER USING e
      Err( "M_1857", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),10,3)
      Show( "M_1858", r )
   RECOVER USING e
      Err( "M_1858", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),10)
      Show( "M_1859", r )
   RECOVER USING e
      Err( "M_1859", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,3))
      Show( "M_1860", r )
   RECOVER USING e
      Err( "M_1860", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,20,6)),3)
      Show( "M_1861", r )
   RECOVER USING e
      Err( "M_1861", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),4,0)
      Show( "M_1862", r )
   RECOVER USING e
      Err( "M_1862", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),4)
      Show( "M_1863", r )
   RECOVER USING e
      Err( "M_1863", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,4,0))
      Show( "M_1864", r )
   RECOVER USING e
      Err( "M_1864", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,14,3)),0)
      Show( "M_1865", r )
   RECOVER USING e
      Err( "M_1865", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),6,0)
      Show( "M_1866", r )
   RECOVER USING e
      Err( "M_1866", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),6)
      Show( "M_1867", r )
   RECOVER USING e
      Err( "M_1867", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,6,0))
      Show( "M_1868", r )
   RECOVER USING e
      Err( "M_1868", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,16,3)),0)
      Show( "M_1869", r )
   RECOVER USING e
      Err( "M_1869", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),10,0)
      Show( "M_1870", r )
   RECOVER USING e
      Err( "M_1870", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),10)
      Show( "M_1871", r )
   RECOVER USING e
      Err( "M_1871", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,10,0))
      Show( "M_1872", r )
   RECOVER USING e
      Err( "M_1872", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,20,3)),0)
      Show( "M_1873", r )
   RECOVER USING e
      Err( "M_1873", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),4,1)
      Show( "M_1874", r )
   RECOVER USING e
      Err( "M_1874", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),4)
      Show( "M_1875", r )
   RECOVER USING e
      Err( "M_1875", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,4,1))
      Show( "M_1876", r )
   RECOVER USING e
      Err( "M_1876", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,14,4)),1)
      Show( "M_1877", r )
   RECOVER USING e
      Err( "M_1877", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),6,1)
      Show( "M_1878", r )
   RECOVER USING e
      Err( "M_1878", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),6)
      Show( "M_1879", r )
   RECOVER USING e
      Err( "M_1879", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,6,1))
      Show( "M_1880", r )
   RECOVER USING e
      Err( "M_1880", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,16,4)),1)
      Show( "M_1881", r )
   RECOVER USING e
      Err( "M_1881", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),10,1)
      Show( "M_1882", r )
   RECOVER USING e
      Err( "M_1882", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),10)
      Show( "M_1883", r )
   RECOVER USING e
      Err( "M_1883", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,10,1))
      Show( "M_1884", r )
   RECOVER USING e
      Err( "M_1884", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,20,4)),1)
      Show( "M_1885", r )
   RECOVER USING e
      Err( "M_1885", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),4,2)
      Show( "M_1886", r )
   RECOVER USING e
      Err( "M_1886", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),4)
      Show( "M_1887", r )
   RECOVER USING e
      Err( "M_1887", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,4,2))
      Show( "M_1888", r )
   RECOVER USING e
      Err( "M_1888", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,14,5)),2)
      Show( "M_1889", r )
   RECOVER USING e
      Err( "M_1889", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),6,2)
      Show( "M_1890", r )
   RECOVER USING e
      Err( "M_1890", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),6)
      Show( "M_1891", r )
   RECOVER USING e
      Err( "M_1891", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,6,2))
      Show( "M_1892", r )
   RECOVER USING e
      Err( "M_1892", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,16,5)),2)
      Show( "M_1893", r )
   RECOVER USING e
      Err( "M_1893", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),10,2)
      Show( "M_1894", r )
   RECOVER USING e
      Err( "M_1894", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),10)
      Show( "M_1895", r )
   RECOVER USING e
      Err( "M_1895", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,10,2))
      Show( "M_1896", r )
   RECOVER USING e
      Err( "M_1896", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,20,5)),2)
      Show( "M_1897", r )
   RECOVER USING e
      Err( "M_1897", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),4,3)
      Show( "M_1898", r )
   RECOVER USING e
      Err( "M_1898", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),4)
      Show( "M_1899", r )
   RECOVER USING e
      Err( "M_1899", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,4,3))
      Show( "M_1900", r )
   RECOVER USING e
      Err( "M_1900", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,14,6)),3)
      Show( "M_1901", r )
   RECOVER USING e
      Err( "M_1901", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),6,3)
      Show( "M_1902", r )
   RECOVER USING e
      Err( "M_1902", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),6)
      Show( "M_1903", r )
   RECOVER USING e
      Err( "M_1903", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,6,3))
      Show( "M_1904", r )
   RECOVER USING e
      Err( "M_1904", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,16,6)),3)
      Show( "M_1905", r )
   RECOVER USING e
      Err( "M_1905", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),10,3)
      Show( "M_1906", r )
   RECOVER USING e
      Err( "M_1906", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),10)
      Show( "M_1907", r )
   RECOVER USING e
      Err( "M_1907", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,10,3))
      Show( "M_1908", r )
   RECOVER USING e
      Err( "M_1908", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,20,6)),3)
      Show( "M_1909", r )
   RECOVER USING e
      Err( "M_1909", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),4,0)
      Show( "M_1910", r )
   RECOVER USING e
      Err( "M_1910", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),4)
      Show( "M_1911", r )
   RECOVER USING e
      Err( "M_1911", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,4,0))
      Show( "M_1912", r )
   RECOVER USING e
      Err( "M_1912", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,14,3)),0)
      Show( "M_1913", r )
   RECOVER USING e
      Err( "M_1913", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),6,0)
      Show( "M_1914", r )
   RECOVER USING e
      Err( "M_1914", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),6)
      Show( "M_1915", r )
   RECOVER USING e
      Err( "M_1915", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,6,0))
      Show( "M_1916", r )
   RECOVER USING e
      Err( "M_1916", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,16,3)),0)
      Show( "M_1917", r )
   RECOVER USING e
      Err( "M_1917", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),10,0)
      Show( "M_1918", r )
   RECOVER USING e
      Err( "M_1918", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),10)
      Show( "M_1919", r )
   RECOVER USING e
      Err( "M_1919", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,10,0))
      Show( "M_1920", r )
   RECOVER USING e
      Err( "M_1920", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,20,3)),0)
      Show( "M_1921", r )
   RECOVER USING e
      Err( "M_1921", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),4,1)
      Show( "M_1922", r )
   RECOVER USING e
      Err( "M_1922", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),4)
      Show( "M_1923", r )
   RECOVER USING e
      Err( "M_1923", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,4,1))
      Show( "M_1924", r )
   RECOVER USING e
      Err( "M_1924", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,14,4)),1)
      Show( "M_1925", r )
   RECOVER USING e
      Err( "M_1925", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),6,1)
      Show( "M_1926", r )
   RECOVER USING e
      Err( "M_1926", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),6)
      Show( "M_1927", r )
   RECOVER USING e
      Err( "M_1927", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,6,1))
      Show( "M_1928", r )
   RECOVER USING e
      Err( "M_1928", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,16,4)),1)
      Show( "M_1929", r )
   RECOVER USING e
      Err( "M_1929", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),10,1)
      Show( "M_1930", r )
   RECOVER USING e
      Err( "M_1930", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),10)
      Show( "M_1931", r )
   RECOVER USING e
      Err( "M_1931", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,10,1))
      Show( "M_1932", r )
   RECOVER USING e
      Err( "M_1932", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,20,4)),1)
      Show( "M_1933", r )
   RECOVER USING e
      Err( "M_1933", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),4,2)
      Show( "M_1934", r )
   RECOVER USING e
      Err( "M_1934", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),4)
      Show( "M_1935", r )
   RECOVER USING e
      Err( "M_1935", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,4,2))
      Show( "M_1936", r )
   RECOVER USING e
      Err( "M_1936", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,14,5)),2)
      Show( "M_1937", r )
   RECOVER USING e
      Err( "M_1937", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),6,2)
      Show( "M_1938", r )
   RECOVER USING e
      Err( "M_1938", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),6)
      Show( "M_1939", r )
   RECOVER USING e
      Err( "M_1939", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,6,2))
      Show( "M_1940", r )
   RECOVER USING e
      Err( "M_1940", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,16,5)),2)
      Show( "M_1941", r )
   RECOVER USING e
      Err( "M_1941", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),10,2)
      Show( "M_1942", r )
   RECOVER USING e
      Err( "M_1942", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),10)
      Show( "M_1943", r )
   RECOVER USING e
      Err( "M_1943", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,10,2))
      Show( "M_1944", r )
   RECOVER USING e
      Err( "M_1944", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,20,5)),2)
      Show( "M_1945", r )
   RECOVER USING e
      Err( "M_1945", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),4,3)
      Show( "M_1946", r )
   RECOVER USING e
      Err( "M_1946", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),4)
      Show( "M_1947", r )
   RECOVER USING e
      Err( "M_1947", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,4,3))
      Show( "M_1948", r )
   RECOVER USING e
      Err( "M_1948", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,14,6)),3)
      Show( "M_1949", r )
   RECOVER USING e
      Err( "M_1949", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),6,3)
      Show( "M_1950", r )
   RECOVER USING e
      Err( "M_1950", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),6)
      Show( "M_1951", r )
   RECOVER USING e
      Err( "M_1951", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,6,3))
      Show( "M_1952", r )
   RECOVER USING e
      Err( "M_1952", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,16,6)),3)
      Show( "M_1953", r )
   RECOVER USING e
      Err( "M_1953", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),10,3)
      Show( "M_1954", r )
   RECOVER USING e
      Err( "M_1954", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),10)
      Show( "M_1955", r )
   RECOVER USING e
      Err( "M_1955", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,10,3))
      Show( "M_1956", r )
   RECOVER USING e
      Err( "M_1956", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,20,6)),3)
      Show( "M_1957", r )
   RECOVER USING e
      Err( "M_1957", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),4,0)
      Show( "M_1958", r )
   RECOVER USING e
      Err( "M_1958", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),4)
      Show( "M_1959", r )
   RECOVER USING e
      Err( "M_1959", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,4,0))
      Show( "M_1960", r )
   RECOVER USING e
      Err( "M_1960", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,14,3)),0)
      Show( "M_1961", r )
   RECOVER USING e
      Err( "M_1961", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),6,0)
      Show( "M_1962", r )
   RECOVER USING e
      Err( "M_1962", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),6)
      Show( "M_1963", r )
   RECOVER USING e
      Err( "M_1963", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,6,0))
      Show( "M_1964", r )
   RECOVER USING e
      Err( "M_1964", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,16,3)),0)
      Show( "M_1965", r )
   RECOVER USING e
      Err( "M_1965", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),10,0)
      Show( "M_1966", r )
   RECOVER USING e
      Err( "M_1966", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),10)
      Show( "M_1967", r )
   RECOVER USING e
      Err( "M_1967", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,10,0))
      Show( "M_1968", r )
   RECOVER USING e
      Err( "M_1968", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,20,3)),0)
      Show( "M_1969", r )
   RECOVER USING e
      Err( "M_1969", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),4,1)
      Show( "M_1970", r )
   RECOVER USING e
      Err( "M_1970", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),4)
      Show( "M_1971", r )
   RECOVER USING e
      Err( "M_1971", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,4,1))
      Show( "M_1972", r )
   RECOVER USING e
      Err( "M_1972", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,14,4)),1)
      Show( "M_1973", r )
   RECOVER USING e
      Err( "M_1973", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),6,1)
      Show( "M_1974", r )
   RECOVER USING e
      Err( "M_1974", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),6)
      Show( "M_1975", r )
   RECOVER USING e
      Err( "M_1975", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,6,1))
      Show( "M_1976", r )
   RECOVER USING e
      Err( "M_1976", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,16,4)),1)
      Show( "M_1977", r )
   RECOVER USING e
      Err( "M_1977", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),10,1)
      Show( "M_1978", r )
   RECOVER USING e
      Err( "M_1978", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),10)
      Show( "M_1979", r )
   RECOVER USING e
      Err( "M_1979", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,10,1))
      Show( "M_1980", r )
   RECOVER USING e
      Err( "M_1980", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,20,4)),1)
      Show( "M_1981", r )
   RECOVER USING e
      Err( "M_1981", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),4,2)
      Show( "M_1982", r )
   RECOVER USING e
      Err( "M_1982", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),4)
      Show( "M_1983", r )
   RECOVER USING e
      Err( "M_1983", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,4,2))
      Show( "M_1984", r )
   RECOVER USING e
      Err( "M_1984", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,14,5)),2)
      Show( "M_1985", r )
   RECOVER USING e
      Err( "M_1985", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),6,2)
      Show( "M_1986", r )
   RECOVER USING e
      Err( "M_1986", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),6)
      Show( "M_1987", r )
   RECOVER USING e
      Err( "M_1987", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,6,2))
      Show( "M_1988", r )
   RECOVER USING e
      Err( "M_1988", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,16,5)),2)
      Show( "M_1989", r )
   RECOVER USING e
      Err( "M_1989", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),10,2)
      Show( "M_1990", r )
   RECOVER USING e
      Err( "M_1990", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),10)
      Show( "M_1991", r )
   RECOVER USING e
      Err( "M_1991", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,10,2))
      Show( "M_1992", r )
   RECOVER USING e
      Err( "M_1992", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,20,5)),2)
      Show( "M_1993", r )
   RECOVER USING e
      Err( "M_1993", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),4,3)
      Show( "M_1994", r )
   RECOVER USING e
      Err( "M_1994", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),4)
      Show( "M_1995", r )
   RECOVER USING e
      Err( "M_1995", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,4,3))
      Show( "M_1996", r )
   RECOVER USING e
      Err( "M_1996", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,14,6)),3)
      Show( "M_1997", r )
   RECOVER USING e
      Err( "M_1997", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),6,3)
      Show( "M_1998", r )
   RECOVER USING e
      Err( "M_1998", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),6)
      Show( "M_1999", r )
   RECOVER USING e
      Err( "M_1999", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,6,3))
      Show( "M_2000", r )
   RECOVER USING e
      Err( "M_2000", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,16,6)),3)
      Show( "M_2001", r )
   RECOVER USING e
      Err( "M_2001", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),10,3)
      Show( "M_2002", r )
   RECOVER USING e
      Err( "M_2002", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),10)
      Show( "M_2003", r )
   RECOVER USING e
      Err( "M_2003", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,10,3))
      Show( "M_2004", r )
   RECOVER USING e
      Err( "M_2004", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,20,6)),3)
      Show( "M_2005", r )
   RECOVER USING e
      Err( "M_2005", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(-0.4,0),5,1)
      Show( "M_2006", r )
   RECOVER USING e
      Err( "M_2006", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(-0.004,2),8,3)
      Show( "M_2007", r )
   RECOVER USING e
      Err( "M_2007", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(-0.4,0))
      Show( "M_2008", r )
   RECOVER USING e
      Err( "M_2008", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Transform(Round(-0.4,0),'99.9')
      Show( "M_2009", r )
   RECOVER USING e
      Err( "M_2009", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.4,2,0)
      Show( "M_2010", r )
   RECOVER USING e
      Err( "M_2010", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,2,0)
      Show( "M_2011", r )
   RECOVER USING e
      Err( "M_2011", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,3,0)
      Show( "M_2012", r )
   RECOVER USING e
      Err( "M_2012", e )
   END SEQUENCE
   RETURN

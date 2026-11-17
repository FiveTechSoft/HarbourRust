procedure main()
LOCAL cROOT:= "."
LOCAL cDIR,cMONAT,x
LOCAL AMONAT := {"JANUAR","FEBRUAR","MAERZ","APRIL","MAI","JUNI","JULI","AUGUST","SEPTEMBER","OKTOBER","NOVEMBER","DEZEMBER"}
cDIR := cROOT
for x := 1 to 12
	cMONAT := AMONAT[x]
	cMONAT := cDIR+"\"+cMONAT
	? cMONAT
	? "mkdir"
	for y := 1 TO 2
	       IF y = 1
		? cMONAT+"\REIN"
	       ELSE
		? cMONAT+"\RAUS"
	       ENDIF
	NEXT
NEXT

RETURN

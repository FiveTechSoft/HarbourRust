PROCEDURE Main()
 ? Probe(1,2),Probe(2,1),Probe(2,2)
RETURN
FUNCTION Probe(a,b)
RETURN !((a==1 .AND. b==2) .OR. !(a==b))

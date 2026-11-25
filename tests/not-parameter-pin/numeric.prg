PROCEDURE Main()
 ? Probe(1),Probe(2),Probe(3)
 ? Logic(.T.),Logic(.F.)
RETURN
FUNCTION Probe(n)
RETURN !(n==1) .AND. !(n>2)
FUNCTION Logic(b)
RETURN !b

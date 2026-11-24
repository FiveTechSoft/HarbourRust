PROCEDURE Main()
 ? .NOT. F(1)==F(2) .AND. F(3)==3
 ? !F(4)<F(5) .OR. F(6)==6
 ? !F(7)>F(8) .OR. F(9)==9
RETURN
FUNCTION F(n)
 ? "call",n
RETURN n

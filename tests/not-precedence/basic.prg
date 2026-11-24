PROCEDURE Main()
 LOCAL x:=NIL,a:=1,b:=2,t:=.T.,f:=.F.
 ? !x==NIL,.NOT. a==b,!t==f,.NOT. t .AND. f
 ? .NOT. a+1==b,.NOT. a*2>b,.NOT. -a<b
 ? .NOT. .NOT. a<b,!!t==f
 ? (.NOT. t)==f,.NOT.(a==b)
 ? .NOT. a<b .OR. .T.,.NOT. a>b .AND. .T.
RETURN

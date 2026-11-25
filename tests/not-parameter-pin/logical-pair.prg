PROCEDURE Main()
 ? Same(.T.,.T.),Same(.T.,.F.),Same(.F.,.T.),Same(.F.,.F.)
 ? NotSame(.T.,.T.),NotSame(.T.,.F.),NotSame(.F.,.T.),NotSame(.F.,.F.)
RETURN
FUNCTION Same(a,b)
RETURN a==b
FUNCTION NotSame(a,b)
RETURN !(a==b)

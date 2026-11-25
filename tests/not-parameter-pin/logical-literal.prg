PROCEDURE Main()
 ? AgainstTrue(.T.),AgainstTrue(.F.),AgainstFalse(.T.),AgainstFalse(.F.)
RETURN
FUNCTION AgainstTrue(a)
RETURN !(a==.T.)
FUNCTION AgainstFalse(a)
RETURN !(a==.F.)

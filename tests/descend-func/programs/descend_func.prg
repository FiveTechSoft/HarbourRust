function main()
 ? "[" + Descend("abc") + "]"
 ? "[" + Descend("") + "]"
 ? Len(Descend("abc"))
 ? Chr(Asc(Descend("a")) + Asc("a")) == Chr(256 - 1 + 0) .or. .T.
 ? Descend(5)
 ? Descend(-5)
 ? Descend(5.5)
 ? Descend(0)
 ? Descend(.T.), Descend(.F.)
 ? Descend(Date() + 1) == Descend(Date()) - 1
 ? Descend(Date()) < 5231808
 ? Descend(1.5) == -1.5
return nil

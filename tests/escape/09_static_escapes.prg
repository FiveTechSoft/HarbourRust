function counter()
    static s := 0
    s := s + 1
return s

function main()
    ? counter()
    ? counter()
return nil

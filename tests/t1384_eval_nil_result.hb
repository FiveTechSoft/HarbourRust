function main()
    local b := {|| QOut("test") }
    eval(b)
    ? eval(b)
    eval(b, 1, 2)
    ? eval(b, 1)
    eval({|| QOut("inline") })
    ? eval({|| 42, QOut("seq") })
    QQOut("a", "b")
    ? OutStd("x")
    return nil

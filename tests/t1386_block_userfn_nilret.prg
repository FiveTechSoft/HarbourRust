function main()
    local b := {|| shout("hi") }
    ? eval(b)
    return nil
function shout(s)
    QOut(s)
    return

function main()
    local b := {|| QOut("t") }
    ? apply1(b)
    return nil
function apply1(f)
    return eval(f)

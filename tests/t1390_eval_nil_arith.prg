function main()
    local b := {|| QOut("test") }
    ? eval(b) + 1
    return nil

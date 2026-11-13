function main()
    local b := {|| QOut("t") }
    local c := {|x| x + 1 }
    local d := iif(.t., b, c)
    return nil

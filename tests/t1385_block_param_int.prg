function main()
    local b := {|x| x * 2 }
    ? apply1(b)
    return nil
function apply1(f)
    return eval(f, 21)

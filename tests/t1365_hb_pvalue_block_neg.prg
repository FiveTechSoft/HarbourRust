// neg: hb_PValue inside a codeblock would expose the block's own
// parameters - a named rejection in this increment.
function main()
    local b := {|x| QOut(hb_PValue(1)) }
    ? eval(b, 1)
    return nil

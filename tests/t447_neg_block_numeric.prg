function bad(b)
return b + 1
function main()
    local dup := {|v| v * 2}
    ? bad(dup)
return nil

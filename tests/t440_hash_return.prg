function mk()
    local h := {"one" => 1}
return h
function work()
    local b := mk()
    ? len(b)
    ? b["one"]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil

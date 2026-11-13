function addkey(p)
    ? len(p)
    p["two"] := 2
    ? len(p)
    ? p["two"]
return 0
function work()
    local h := {"one" => 1}
    ? addkey(h)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil

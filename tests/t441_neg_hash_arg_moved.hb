function addkey(p)
    p["two"] := 2
return 0
function main()
    local h := {"one" => 1}
    ? addkey(h)
    ? len(h)
return nil

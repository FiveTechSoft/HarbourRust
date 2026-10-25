// NIL values roundtrip through the tagged slot (probe n1 shape).
function main()
    local h := {"a" => nil}
    ? h["a"]
    ? len(h)
return nil

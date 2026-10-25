// hash literal + read + len (oracle h1 shape: insertion, distinct keys).
function main()
    local h := {"a" => 1, "b" => 2}
    ? len(h)
    ? h["a"]
    ? h["b"]
return nil

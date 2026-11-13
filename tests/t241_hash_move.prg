// assignment MOVES the hash (Rust ownership): the source is dead after.
function main()
    local h := {"a" => 1}
    local h2 := h
    ? h["a"]
return nil

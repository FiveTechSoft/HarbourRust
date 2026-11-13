// keys are case-sensitive (oracle h3b): "a" misses a hash holding "A".
function main()
    local h := {"A" => 1}
    ? h["a"]
return nil

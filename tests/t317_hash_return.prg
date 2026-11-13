// HB-EXACT mirror of oracle hk12: a function returns a hash it built.
function mk()
    local h := {"a" => 7}
return h
function main()
    local h := mk()
    ? len(h)
    ? h["a"]
return nil

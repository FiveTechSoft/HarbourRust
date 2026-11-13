// duplicate keys in one literal overwrite in place (oracle h8: len 1, last wins).
function main()
    local h := {"a" => 1, "a" => 2}
    ? len(h)
    ? h["a"]
return nil

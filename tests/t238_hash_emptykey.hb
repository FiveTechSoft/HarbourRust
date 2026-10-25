// the empty string is an ordinary key (oracle h10).
function main()
    local h := {"" => 7}
    ? len(h)
    ? h[""]
return nil

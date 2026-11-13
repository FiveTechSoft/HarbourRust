// Hash as a parameter (oracle hk11): Harbour SHARES the hash - addkey's
// write is visible in main without any return. We MOVE: the caller hands
// the hash over and the function returns it; the printed values are
// byte-identical to hk11 either way. The sharing difference itself is
// registered (family D5/D7, pending the user's contract decision).
function addkey(p)
    p["two"] := 2
    ? len(p)
return p
function main()
    local h := {"one" => 1}
    h := addkey(h)
    ? len(h)
    ? h["two"]
return nil

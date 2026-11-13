// overwrite through h[k] := v keeps the pair count (oracle h1 shape).
function main()
    local h := {=>}
    h["a"] := 1
    h["a"] := 2
    ? len(h)
    ? h["a"]
return nil

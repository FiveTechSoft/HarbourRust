// byte compare uses the length: prefix keys stay distinct (oracle h12).
function main()
    local h := {=>}
    h["a"] := 1
    h["ab"] := 2
    ? len(h)
    ? h["a"]
    ? h["ab"]
return nil

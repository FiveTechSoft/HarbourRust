// inside a literal each pair evaluates its KEY first, then its value
// (oracle h9: K1, V1, K2, V2) - the opposite of `h[k] := v`.
function kname()
    ? "K"
return "a"
function give()
    ? "V"
return 9
function main()
    local h := {kname() => give()}
    ? h["a"]
return nil

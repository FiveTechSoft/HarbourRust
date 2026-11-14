// t609: logical values in hash writes and comparisons (oracle hk205);
// hb_HHasKey renders .T./.F. (logical type, issue #1)
function main()
    local h := { "a" => 1 }
    h["b"] := .T.
    h["c"] := .F.
    ? h["b"]
    ? h["c"]
    ? valtype( h["b"] )
    ? hb_hhaskey( h, "b" )
    ? h["b"] = .T.
    ? h["b"] = h["c"]
return nil

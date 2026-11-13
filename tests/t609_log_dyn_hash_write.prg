// t609: logical values in hash writes and comparisons (oracle hk205);
// hb_HHasKey keeps the registered 1/0 flag surface
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

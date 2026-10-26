// t536: a string-literal default is rejected in this increment (the
// hb_HGet default is an integer) - explicit rejection, never a silent
// discard of an unsupported form.
function main()
    local h := {"a" => 1}
    ? hb_HGet(h, "a", "x")
return nil

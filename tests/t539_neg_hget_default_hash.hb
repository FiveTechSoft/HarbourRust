// t539: a hash default is rejected in this increment (the hb_HGet
// default is an integer) - explicit rejection of an unsupported form.
function main()
    local h := {"a" => 1}
    local h2 := {"x" => 1}
    ? hb_HGet(h, "a", h2)
return nil

// t538: an array default is rejected in this increment (the hb_HGet
// default is an integer) - explicit rejection of an unsupported form.
function main()
    local h := {"a" => 1}
    local d := {1, 2}
    ? hb_HGet(h, "a", d)
return nil

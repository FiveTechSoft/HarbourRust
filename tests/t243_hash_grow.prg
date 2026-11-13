// six pairs cross the initial capacity (4): the block grows, entries move
// and reads still hit (growth shape only; order is not observable in v1).
function main()
    local h := {"a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5, "f" => 6}
    ? len(h)
    ? h["c"]
return nil

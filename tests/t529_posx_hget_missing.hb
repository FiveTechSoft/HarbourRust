// t529: hb_HGet on a MISSING key - with or without a default - is the
// BASE/1132 condition (hk158a/b/d: Harbour shows its dialog and hangs
// headless): the PoC prints and exits 1 (registered failure mode, never
// a compat success).
function main()
    local h := {"a" => 1}
    ? hb_HGet(h, "a")
    ? hb_HGet(h, "zz", 42)
return nil

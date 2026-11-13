// optional RESULT part [ ... ] (probes b35, b36a-d): a bracket containing
// at least one bound marker is kept (unbound markers inside it are removed
// individually); a bracket with NO bound marker is dropped whole, comma and
// all (std.ch's `[, <clr>]` case).
#command TELL <x> [AND <y>] => ? <x> [+ <y> + <x>]
#command DROP <x> [AND <y>] => ? <x> [+ <y>]
function main()
    TELL 1 AND 2
    DROP 3 AND 4
    DROP 5
    return nil

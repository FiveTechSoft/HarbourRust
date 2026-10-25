// missing-key read: Harbour opens its BASE/1132 dialog and hangs headless
// (oracle h3) - registered failure mode: clean bound error, exit 1.
function main()
    local h := {"a" => 1}
    ? h["b"]
return nil

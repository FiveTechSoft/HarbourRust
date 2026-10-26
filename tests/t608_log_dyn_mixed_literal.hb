// t608: a flat literal mixing logicals and integers materializes as a
// dynamic tagged array (oracle hk201)
function main()
    local a := { .T., .F., 1 }
    ? a[1]
    ? a[2]
    ? valtype( a[1] )
    ? a[1] .and. .T.
    ? a[1] = a[1]
    ? a[1] = a[2]
return nil

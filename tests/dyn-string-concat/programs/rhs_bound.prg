function main()
local d,e,a := {"one","two"}
d := "owned"
try
? d+a[3]
catch e
? "caught"
end
? "after"
return nil

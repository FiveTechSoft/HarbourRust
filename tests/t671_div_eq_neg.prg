// neg: /= named rejection (Harbour yields decimals, hk246; float/decimal
// design parked hk226-hk233).
function main()
   local n := 48
   n /= 2
   ? n
   return

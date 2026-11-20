function main()
 local a := {"x", "y", "z"}
 local z := "y"
 local n := AScan(a, {|e| e == z})
 ? n
 ? AScan(a, {|e| e == "q"}), AScan(a, {|e| e > "x"}), AScan(a, {|e| e == "Y"})
 ? AScan(a, {|e, i| e == "z" .and. i == 3})
 ? AScan(a, {|e| e == z}), AScan(a, {|e| Len(e) == 3})
return nil

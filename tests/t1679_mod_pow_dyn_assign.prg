procedure main()
   // D5 regression: % and ^ over a Dyn casilla assigned AFTER declaration
   // (local without initializer). cg_f64_operand used to read the casilla
   // TAG (9) as the value: x ^ 2 printed 81.00 instead of 10000.00.
   // Oracle: real Harbour 3.2 prints 2.00 / 1.00 / 10000.00 / 10.00 / 0.
   local x, y
   x := 100
   y := 3
   ? x % 7
   ? x % y
   ? x ^ 2
   ? x ^ 0.5
   ? x % 0
return

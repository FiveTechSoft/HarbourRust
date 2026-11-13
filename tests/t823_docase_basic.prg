local x := 2
do case
case x == 1
   ? "one"
case x == 2
   ? "two"
   ? "second line"
case x == 3
   ? "three"
otherwise
   ? "other"
endcase
? "after"

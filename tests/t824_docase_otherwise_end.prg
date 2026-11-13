local x := 9
do case
case x == 1
   ? "one"
otherwise
   ? "fallback"
end
? "end-close"
do case
case x == 1
   ? "one"
case x == 9
   ? "nine"
endcase
? "no-otherwise-taken"
do case
case x == 1
   ? "one"
endcase
? "no-match-no-otherwise"

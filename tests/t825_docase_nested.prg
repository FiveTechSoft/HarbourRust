local x := 1
do case
case .t.
   do case
   case x == 1
      ? "nested-one"
   otherwise
      ? "nested-other"
   endcase
otherwise
   ? "outer-other"
endcase
? "done"

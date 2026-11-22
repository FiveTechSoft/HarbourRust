# FOR EACH over fixed-size stack arrays

`for each x in a` with `a` a fixed-size stack array (`local a := {1,2,3}`,
the all-integer literal type `Arr(k)`): the checker lifts the old
blanket rejection (the codegen's static path existed half-wired) and the
loop variable materializes a plain tag-0 i64 pair per iteration, so the
body may store/accumulate it (`n := n + x`) - the borrowed-string
observation-only rule stays for the dynamic collections. In place: the
collection iterates the OWNER's own frame slot (no snapshot), the loop
end compares against the static length, the element address is `lea`
of the inline cell (they run DOWNWARD: cell k lives at `off - 8*k`).
All-strings literals type DArrS (the dynamic string path unchanged);
an INLINE literal collection (`for each x in {1,2,3}`) keeps the
"assign the expression to a variable first" rejection.

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11); the Linux file is the same
bytes with LF line ends. Byte-exact (10 pins).

# ASort with a bOrder codeblock

`ASort(a [, start [, count [, bOrder]]])`: the fourth argument is a
DIRECT codeblock literal comparator over flat dynamic arrays
(`DArr` integers / `DArrS` strings). The block receives the two
ELEMENTS (x, y) and TRUE places x before y (oracle: {3,1,2} with
`{|x, y| x > y}` -> 3 2 1). A literal NIL in the start/count slots is
the default (ASort(a, nil, nil, block) sorts everything), start stays
1-based and count obeys the hbc_asort_i convention (below 1 -> to the
end). The comparator's parameter typing follows the element family
(exactly like AScan's block) and remaining free names resolve as
read-only captures in the enclosing scope. The implementation is a
black-box insertion sort validated byte-exact against the oracle; the
comparison order of inconsistent comparators is not observable.

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11); the Linux file is the same
bytes with LF line ends.

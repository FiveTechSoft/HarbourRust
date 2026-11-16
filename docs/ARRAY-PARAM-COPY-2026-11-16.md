# Fixed-size array arguments that the callee changes: now a compile-time error

Reported in issue #1 (follow-up against 0.11.1, section 3.1). In Harbour an
array argument is a reference: when the callee changes an element, the
caller sees the change. hbc keeps a local array of known fixed size
(`local v := {0,0}`) in the caller's stack frame and passes the callee a
heap COPY, which the callee owns and frees. The callee's changes went to
the copy, so the caller printed the old values with no message:

```harbour
function main()
 local v := {0,0}
 f(1, v)
 ? v[1]          // Harbour 1, hbc 0.11.1 printed 0
return nil
function f(n, v)
 v[1] := v[1] + n
return nil
```

## Change

Such a call is now rejected at compile time:

```
error: line 3: array `v` is passed to `f`, which can change its elements;
Harbour passes arrays by reference, and this increment passes a fixed-size
local array as a copy, so the change would be lost (arrays passed by
reference are not in this increment)
```

A callee parameter counts as changed (conservatively) when the callee:
- stores into its elements (`p[i] := x`, `p[i] += x`, nested forms);
- uses an in-place array statement or builtin on it (AAdd, ASize, AIns,
  ADel, AFill, ASort, AEval, ACopy);
- copies it into another variable, passes it to a method, to `Eval`, to
  `hb_threadStart` or to a codeblock;
- passes it to another function whose parameter is changed (fixed point
  over the call graph).

Calls whose callee only reads the array keep working exactly as before.

## Evidence

- The three issue repros (`tests/issue1/a1..a3`) are now `neg` rows.
- Every manifest program was compiled for both targets with the old and
  the new compiler. 3482 of 3488 outputs are identical. The other 6 are
  t425, t426 and t427 on both targets, now rejected. Their old expectation
  files recorded the copy behaviour, not Harbour's. Real Harbour 3.2 prints
  `a[1]` = 99, `Len(a)` = 4 and `Len(a)` = 2 where those files had 1, 3
  and 3. The three files were removed and the rows became `neg` rows.

## Not done

Real by-reference array passing for fixed-size locals (the copy would have
to be written back, or the local kept on the heap). Until then, these
programs get an error instead of a wrong number.

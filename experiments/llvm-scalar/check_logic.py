"""Independent integer oracle for the logic fixture, after byte comparison."""
import itertools
import pathlib

expected = []
for i, j, k in itertools.product((False, True), repeat=3):
    expected += [int(i and j), int(i or j), int(not i),
                 int(not (i or (j and k))), int(i and ((not j) or k))]
for n, m, k in itertools.product((-1, 0, 1), repeat=3):
    i, j, z = n > 0, m > 0, k > 0
    expected.append(int(i and j) + 2*int(i or j) + 4*int(not i)
                    + 8*int(not (i or (j and z))) + 16*int(i and ((not j) or z)))
# Skipped increments/bounds; taken increments; observable mark() call order;
# WHILE must stop before reading array element four.
expected += [0, 0, 1, 0, 0, 1, 1, 1, 1, 2,
             1, 2, 1, 3, 1, 5, 0, 7, 8, 1, 3]
for name in ['logic-current.out', 'logic-llvm.out']:
    actual = list(map(int, pathlib.Path('run', name).read_text().split()))
    assert actual == expected, (name, actual, expected)
print('PASS independent logic truth/effect oracle (88 integers)')

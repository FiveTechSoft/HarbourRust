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

# Explicit expected observations for forward/reverse FOR, WHILE, nested
# EXIT/LOOP, signed-max increment termination and early-return trace unlink.
loop_expected = [1, 10, 3, 30, 4, 4, 2, 1, 1, 3, 4, 3,
                 1, 1, 1, 3, 2, 1, 2, 3,
                 1, 1, 1, 3, 2, 1, 2, 3,
                 9223372036854775807, -9223372036854775808, 3, 2, 1]
for name in ['loopcontrol-current.out', 'loopcontrol-llvm.out']:
    actual = list(map(int, pathlib.Path('run', name).read_text().split()))
    assert actual == loop_expected, (name, actual, loop_expected)
print('PASS independent loop-control observations (33 integers)')

sequence_expected = [12345678901, 2, 7, 4, 1, 2, 4, 4, 5, 5,
                     1, 6, 0, 6, 1, 6, 1, 2, 3, 7, 1, 2, 7, 10, 4]
for name in ['sequence-current.out', 'sequence-llvm.out']:
    actual = list(map(int, pathlib.Path('run', name).read_text().split()))
    assert actual == sequence_expected, (name, actual, sequence_expected)
print('PASS independent sequence observations (25 integers)')

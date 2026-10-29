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

minmax_expected = [3,8,-4,0,-9223372036854775808,9223372036854775807,
                   5,5,1,2,4,4,8,3,3,2,9,9,2,5,12345678901,6]
for name in ['minmax-current.out','minmax-llvm.out']:
    actual = list(map(int,pathlib.Path('run',name).read_text().split()))
    assert actual == minmax_expected, (name,actual,minmax_expected)
print('PASS independent Min/Max observations (22 integers)')

bitops_expected = [3,7,5,-1,255,-3,0,9223372036854775807,
                   0,3,1,2,4,7,-9223372036854775808,3,
                   -9223372036854775808,9223372036854775807,-1,
                   1,5,1,1,0,3,1,3,12,4]
for name in ['bitops-current.out','bitops-llvm.out']:
    actual = list(map(int,pathlib.Path('run',name).read_text().split()))
    assert actual == bitops_expected, (name,actual,bitops_expected)
print('PASS independent bit-operation observations (29 integers)')

empty_expected = [1,0,0,0,1,0,0,1,1,0,2,0,9,1,0,1,2,1,3,1]
for name in ['empty-current.out','empty-llvm.out']:
    actual = list(map(int,pathlib.Path('run',name).read_text().split()))
    assert actual == empty_expected, (name,actual,empty_expected)
print('PASS independent Empty observations (20 integers)')


def interact(n):
    a = [3,5,7,11]
    s = n
    i = 1
    while i <= 12:
        j = (i & 3) + 1
        b = (i & 1) == 0 and a[j-1] != 0
        if b and i < 10:
            a[j-1] = max(a[j-1],min(s+i,100))
        else:
            a[j-1] ^= i
        if i != 4:
            s = s + 1 + a[j-1]
            if i > 8 and s > 200:
                break
        i += 1
    j = 1
    while j <= 4 and a[j-1] != 0:
        s += a[j-1]
        j += 1
    return s+i+j
interaction_expected = [interact(n) for n in range(-16,17)]
for name in ['interaction-current.out','interaction-llvm.out']:
    actual = list(map(int,pathlib.Path('run',name).read_text().split()))
    assert actual == interaction_expected, (name,actual,interaction_expected)
print('PASS independent cross-feature interaction oracle (33 inputs)')

boolcalls_expected = [1,0,0,0]
for i in range(9):
    boolcalls_expected += [int(i%2==0),int(i%2==0),int(i%2==1)]
boolcalls_expected += [0,1,3,1,4,1]
for name in ['boolcalls-current.out','boolcalls-llvm.out']:
    actual = list(map(int,pathlib.Path('run',name).read_text().split()))
    assert actual == boolcalls_expected, (name,actual,boolcalls_expected)
print('PASS independent logical-call observations (37 integers)')

# Full bytes matter here: three-byte logical tokens, mixed-field spaces,
# side effects before outer output, QQOut concatenation and trailing trim.
booloutput_expected = (b'\n.T. .T. .F.\n.T.          1 .T. .T.'
                       b'\n.T.\n.F.\n.F. .T.\n.F. .T.\n         1\n         2'
                       b'\n.T. .T..T..F.\nend\na   .T. z\n.T. ')
for name in ['booloutput-current.out','booloutput-llvm.out']:
    assert pathlib.Path('run',name).read_bytes() == booloutput_expected, name
print('PASS independent logical-output byte oracle')

boolminmax_expected = (b'\n.F. .F. .F. .T.\n.F. .T. .T. .T.\n.T. .F. .F.'
                       b'\n         0\n         1\n.F.\n         2\n         0\n.T.'
                       b'\n         0          1')
for name in ['boolminmax-current.out','boolminmax-llvm.out']:
    assert pathlib.Path('run',name).read_bytes() == boolminmax_expected, name
print('PASS independent logical Min/Max byte oracle')

boolscope_expected = (b'\n.T.\n.T.\n         8\n         9 .T.'
                      b'\n         7\n.T.\n.F.\n.F. .T.\n         0          0')
for name in ['boolscope-current.out','boolscope-llvm.out']:
    assert pathlib.Path('run',name).read_bytes() == boolscope_expected, name
print('PASS independent disjoint logical-local scope byte oracle')


def signed64(n):
    return (n+(1<<63))%(1<<64)-(1<<63)
edge_lines=[]
for a,b in [(-(1<<63),-1),(-(1<<63),1),((1<<63)-1,1),((1<<63)-1,-1),
            (-(1<<63),(1<<63)-1),(-(1<<32),1<<32),(0,0),(-1,-1)]:
    # Computed integer fields have the existing minimum10-byte width.
    edge_lines.append(' '.join(str(signed64(n)).rjust(10) for n in (a+b,a-b,a*b)))
    edge_lines.append(' '.join('.T.' if c else '.F.' for c in (a<b,a<=b,a==b,a!=b,a>=b,a>b)))
    edge_lines.append(' '.join(str(n).rjust(10) for n in (min(a,b),max(a,b),a^b)))
integeredges_expected=('\n'+'\n'.join(edge_lines)).encode()
for name in ['integeredges-current.out','integeredges-llvm.out']:
    actual=pathlib.Path('run',name).read_bytes()
    assert actual.split() == integeredges_expected.split(),(name,actual,integeredges_expected)
print('PASS independent signed-I64 edge arithmetic/compare value oracle (8 pairs)')

scope_lines=[]
for n in (0,1):
    if n==0:
        scope_lines += ['         1','         2','         2          1          2','         8']
    else:
        scope_lines += ['         3','         4','         5','         3          3          5','.T.']
    scope_lines += ['         2          2','         4          4','         4          1          2',
                    '         1','         2','         3          3','         3          6',
                    str(10 if n==0 else 11).rjust(10),str(17 if n==0 else 18).rjust(10),'        13','        16']
scopedslots_expected=('\n'+'\n'.join(scope_lines)+'\n         0          0').encode()
for name in ['scopedslots-current.out','scopedslots-llvm.out']:
    assert pathlib.Path('run',name).read_bytes()==scopedslots_expected,name
print('PASS independent scoped declaration/array byte oracle')

# Original hk339/fornext expected control path, independent of either backend.
fornext_lines=['Testing Harbour For Next loops. Going up quick']
fornext_lines += [str(n).rjust(10) for n in (1,5,9)]
fornext_lines += ['Going down']+[str(n).rjust(10) for n in range(10,0,-1)]
fornext_lines += ['No step']+[str(n).rjust(10) for n in range(1,11)]
fornext_lines += ['No production','Ok!']
fornext_expected=('\n'+'\n'.join(fornext_lines)).encode()
assert len(fornext_expected)==337
for name in ['fornext-original-current.out','fornext-original-llvm.out']:
    assert pathlib.Path('run',name).read_bytes()==fornext_expected,name
print('PASS unchanged fornext/hk339 expected bytes (337 bytes)')

for name in ['barecounter-current.out','barecounter-llvm.out']:
    assert pathlib.Path('run',name).read_bytes()==b'bound\n         2\n        80         1         2\n         3\n        80',name
print('PASS bare counter effects, zero-trip and scope restoration')

for name in ['discardeffects-current.out','discardeffects-llvm.out']:
    assert pathlib.Path('run',name).read_bytes()==b'         1\nchosen          1         2inline          2\nprefix\n         1          1         7seq         3         3',name
print('PASS discarded output effects: lazy arms, sequence order and NIL no-op')

for name in ['nilcompare-current.out','nilcompare-llvm.out']:
    assert pathlib.Path('run',name).read_bytes()==b'\n.F. .F. .F. .F.\n.T. .T. .F. .T.         3         4\n.T. .F.\n.T. .T.          2\n.F. .T.\nprefix\n.T.\nnot NIL',name
print('PASS literal NIL/scalar comparison: constants preserve operand effects')

for name in ['printchoice-current.out','printchoice-llvm.out']:
    assert pathlib.Path('run',name).read_bytes()==b'         1         2\nstart a   b\n\nx            9         1\nnested',name
for name in ['exit-original-current.out','exit-original-llvm.out']:
    assert pathlib.Path('run',name).read_bytes()==b'\ndo exit test passed\nfor exit test passed',name
print('PASS static literal IIF print selection and unchanged original exit bytes')

# Unchanged originals: expected bytes from existing semantic/oracle records.
void_expected={
 'returns-original':b'\nFrom Main()\nn == 1\nback to Main()\nn == 2\nback to Main()',
 'ifelse-original':b'\nTesting Harbour IF ELSEIF ELSE ENDIF'+b''.join((f'\nx is {i}\nOk!').encode() for i in range(1,5))+b'\nx is not 1 or 2 or 3 or 4\nOk!',
 'statfun-original':b'\nFrom Main()\nFrom Second()\nFrom Main() again',
 'voideffects':b'         0         1         2early          2endpong'
}
for case,want in void_expected.items():
 for backend in ['current','llvm']:
  assert pathlib.Path('run',case+'-'+backend+'.out').read_bytes()==want,case
print('PASS NIL-only void originals and recursive/early-return effects exact bytes')

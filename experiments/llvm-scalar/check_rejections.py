import pathlib,subprocess,os
os.chdir(pathlib.Path(__file__).resolve().parent)
cases={
 'bool-branch': 'function main()\nlocal b := .T.\nlocal z := .F.\nif b\nz := .T.\nendif\n? If(b,z,.F.)\nreturn\n',
 'sequence-logical-output': 'function main()\nlocal x := 0\n? (x++, .T.)\nreturn\n',
 'sequence-float': 'function main()\nlocal x := 0\n? (x++, 1.5)\nreturn\n',
 'bittest-output': 'function main()\n? hb_bitTest(1,0)\nreturn\n',
 'bittest-local-output': 'function main()\nlocal b := hb_bitTest(1,0)\n? b\nreturn\n',
 'bitindex-dynamic': 'function main()\nlocal n := 1\n? hb_bitSet(0,n)\nreturn\n',
 'bitindex-range': 'function main()\n? hb_bitSet(0,64)\nreturn\n',
 'bitops-float': 'function main()\n? hb_bitAnd(1.0,2.0)\nreturn\n',
 'float': 'function main()\n? 1.2\nreturn\n',
 'array-logical': 'function main()\nlocal a := {.T.,.F.}\n? a[1]\nreturn\n',
 'array-mixed-logical': 'function main()\nlocal a := {1,.T.}\n? a[2]\nreturn\n',
 'array-dead-logical': 'function main()\nwhile .T.\nexit\nlocal a := {.T.,.F.}\nenddo\nreturn\n',
 'array-dynamic': 'function main()\nlocal a := Array(2)\nreturn\n',
 'array-param': 'function f(a)\nreturn a[1]\nfunction main()\nlocal a := {1,2}\n? f(a)\nreturn\n',
 'array-nested': 'function main()\nlocal a := {{1,2},{3,4}}\n? a[1][1]\nreturn\n',
 'array-copy': 'function main()\nlocal a := {1,2}\nlocal b := a\nreturn\n',
 'array-aadd': 'function main()\nlocal a := {1,2}\nAAdd(a,3)\nreturn\n',
 'nil': 'function main()\n? nil\nreturn\n',
 'string-var': 'function main()\nlocal a := "x"\n? a\nreturn\n',
 'byref': 'function f(x)\nreturn x+1\nfunction main()\nlocal a := 1\n? f(@a)\nreturn\n',
 'builtin': 'function main()\n? Abs(1)\nreturn\n',
 'minmax-logical': 'function main()\n? Min(.T.,.F.)\nreturn\n',
 'minmax-float': 'function main()\n? Max(1.0,2.0)\nreturn\n',
 'dead-string-return': 'function main()\nif .T.\nreturn\nlocal s := "unsupported"\n? s\nendif\nreturn\n',
 'dead-builtin-chain': 'function main()\nwhile .T.\nexit\nloop\n? Abs(1)\nenddo\nreturn\n',
 'dead-string-exit': 'function main()\nwhile .T.\nexit\nlocal s := "unsupported"\n? s\nenddo\nreturn\n',
 'dead-division-loop': 'function main()\nlocal x := 4\nwhile .T.\nloop\n? x / 2\nenddo\nreturn\n',
 'dead-string-if': 'function main()\nwhile .T.\nif .T.\nexit\nelse\nloop\nendif\nlocal s := "unsupported"\n? s\nenddo\nreturn\n',
 'exit-outside': 'function main()\nexit\nreturn\n',
 'loop-outside': 'function main()\nloop\nreturn\n'
}
for name,source in cases.items():
 p=pathlib.Path('run/reject-'+name+'.hb');p.write_text(source)
 for target in ['linux','windows']:
  r=subprocess.run(['run/hbc',str(p),'run/reject.ll','--experimental-llvm','--target='+target],capture_output=True)
  assert r.returncode==1,(name,target,r.stdout,r.stderr)
  assert b'error:' in r.stderr
  if name in ('array-logical','array-mixed-logical','array-dead-logical'):
   assert b'tagged logical/mixed array literals unsupported' in r.stderr, (name,r.stderr)
 print('PASS fail-closed',name)
r=subprocess.run(['run/hbc','corpus.hb','run/reject.ll','--experimental-llvm','--instrument'],capture_output=True)
assert r.returncode==1 and b'--instrument is not supported' in r.stderr
print('PASS fail-closed instrument')

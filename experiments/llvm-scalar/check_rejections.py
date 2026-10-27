import pathlib,subprocess,os
os.chdir(pathlib.Path(__file__).resolve().parent)
cases={
 'bool-branch': 'function main()\nlocal b := .T.\nlocal z := .F.\nif b\nz := .T.\nendif\n? If(b,z,.F.)\nreturn\n',
 'float': 'function main()\n? 1.2\nreturn\n',
 'array': 'function main()\nlocal a := {1,2}\n? a[1]\nreturn\n',
 'nil': 'function main()\n? nil\nreturn\n',
 'string-var': 'function main()\nlocal a := "x"\n? a\nreturn\n',
 'byref': 'function f(x)\nreturn x+1\nfunction main()\nlocal a := 1\n? f(@a)\nreturn\n',
 'builtin': 'function main()\n? Min(1,2)\nreturn\n',
 'logic-op': 'function main()\nif .T. .AND. .F.\n? 1\nendif\nreturn\n',
 'exit': 'function main()\nwhile .T.\nexit\nenddo\nreturn\n'
}
for name,source in cases.items():
 p=pathlib.Path('run/reject-'+name+'.hb');p.write_text(source)
 for target in ['linux','windows']:
  r=subprocess.run(['run/hbc',str(p),'run/reject.ll','--experimental-llvm','--target='+target],capture_output=True)
  assert r.returncode==1,(name,target,r.stdout,r.stderr)
  assert b'error:' in r.stderr
 print('PASS fail-closed',name)
r=subprocess.run(['run/hbc','corpus.hb','run/reject.ll','--experimental-llvm','--instrument'],capture_output=True)
assert r.returncode==1 and b'--instrument is not supported' in r.stderr
print('PASS fail-closed instrument')

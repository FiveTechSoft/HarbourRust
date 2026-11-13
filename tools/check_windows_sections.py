#!/usr/bin/env python3
"""Compile Windows assembly with a real PE/COFF GNU assembler.

Usage: python3 tools/check_windows_sections.py --compiler ./hbc \
  --assembler x86_64-w64-mingw32-as --objdump x86_64-w64-mingw32-objdump
No Wine is needed for this assembly-format regression check.
"""
import argparse
from pathlib import Path
import subprocess
import tempfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--compiler', required=True)
p.add_argument('--assembler', default='x86_64-w64-mingw32-as')
p.add_argument('--objdump', default='x86_64-w64-mingw32-objdump')
a = p.parse_args()
compiler = str(Path(a.compiler).resolve())
fixtures = {
    'hello': 'function Main()\n? "Hello"\nreturn nil\n',
    'array_hash': '''function Main()
local a := {}
local h := { "key" => 11 }
AAdd( a, 3 )
? Len( a ), a[ 1 ], h[ "key" ]
return nil
''',
    # OutErr forces the private stderr numeric-helper clone as well.
    'date_stderr': '''function Main()
local d := CToD( "02/29/2024" )
local n := 1.5
? d, CToD( "" ), ValType( d ), n
OutErr( n )
return nil
''',
}
with tempfile.TemporaryDirectory(prefix='hbc-windows-sections-') as tmp:
    root = Path(tmp)
    count = 0
    for name, source in fixtures.items():
        src = root / (name + '.prg')
        src.write_text(source)
        for instrument in (False, True):
            asm = root / (name + ('-instrument' if instrument else '') + '.s')
            obj = asm.with_suffix('.o')
            subprocess.run([compiler, str(src), str(asm), '--target=windows'] +
                           (['--instrument'] if instrument else []), check=True,
                           capture_output=True)
            text = asm.read_text()
            assert '.pushsection' not in text and '.popsection' not in text, name
            assert '.section .rdata,"r"' in text, name
            if name == 'date_stderr':
                assert '.Lenum_decimal_zeros:' in text, 'stderr constants missing'
            subprocess.run([a.assembler, '-o', str(obj), str(asm)], check=True,
                           capture_output=True)
            info = subprocess.run([a.objdump, '-f', str(obj)], check=True,
                                  capture_output=True, text=True).stdout
            assert 'file format pe-x86-64' in info, info
            count += 1
    print(f'PASS: {count} Windows assemblies accepted as PE/COFF x86-64')

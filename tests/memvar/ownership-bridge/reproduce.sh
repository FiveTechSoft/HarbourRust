#!/usr/bin/env bash
set -eu
ulimit -c 0
cd "$(dirname "$0")"
CCW=${HB_CCW:-/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-gcc-posix}
ASW=${HB_ASW:-/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-as}
NMW=${HB_NMW:-/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-nm}
ODW=${HB_ODW:-/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-objdump}
WINE=${HB_WINE:-/tmp/hr-wine11/opt/wine-stable/bin/wine}
export WINEPREFIX=${WINEPREFIX:-/tmp/hr-win11-prefix} WINEDEBUG=-all
mkdir -p evidence/linux evidence/windows
python3 real/make-runtime.py
python3 real/make-abi.py
python3 - <<'PYID'
from pathlib import Path
import hashlib,json
r=Path('real');rows=[]
for target in ['linux','windows']:
 a=(r/(target+'.s')).read_text();b=(r/(target+'-linked.s')).read_text();expected=a.replace('.globl _start','.globl hrbt_unused_start').replace('\n_start:','\nhrbt_unused_start:');assert b.startswith(expected)
 assert 'call hbc_str_f64' in a[:a.index('hbc_persistent_release:')]
 rows.append({'target':target,'template_sha256':hashlib.sha256(a.encode()).hexdigest(),'all_production_helper_bodies_unchanged':True,'Str_F64_codegen_calls':'hbc_str_f64','bridge_constructor':'hbc_float_new','unpack':'hbc_float_unpack'})
 (r/(target+'-codegen-Str-fragment.s')).write_text(a[a.index('hbc_fn_main:'):a.index('hbc_persistent_release:')])
(r/'identity-check.json').write_text(json.dumps(rows,indent=2)+'\n')
PYID
if [ -n "${HB_ORACLE_CORE:-}" ];then
 for target in linux windows;do
  if [ "$target" = linux ];then d=oracle;else d=oracle/windows;fi
  (cd "$d"
   if [ "$target" = linux ];then
    "$HB_ORACLE_CORE/bin/linux/gcc/hbmk2" render.prg -gtstd >build.stdout 2>build.stderr
    echo 0 >build.rc;./render >run.stdout 2>run.stderr;echo 0 >run.rc;sha256sum render >binary.sha;rm render
   else
    export PATH="$(dirname "$CCW"):$PATH" HB_CCPATH="$(dirname "$CCW")/" HB_CCPREFIX=x86_64-w64-mingw32- HB_CCSUFFIX=-posix
    "$HB_ORACLE_CORE/bin/linux/gcc/hbmk2" render.prg -plat=win -comp=mingw64 -gtstd >build.stdout 2>build.stderr
    echo 0 >build.rc;"$WINE" "$PWD/render.exe" >run.stdout 2>run.stderr;echo 0 >run.rc;sha256sum render.exe >binary.sha;rm render.exe
   fi)
 done
else
 echo 'Official oracle rebuild skipped: set HB_ORACLE_CORE. Comparing supplied raw oracle only.'
fi
for target in linux windows;do
 if [ "$target" = linux ];then cc=gcc;assembler=as;nm=nm;od=objdump;ext=;else cc=$CCW;assembler=$ASW;nm=$NMW;od=$ODW;ext=.exe;fi
 "$cc" -std=c11 -O2 -Wall -Wextra -Werror tests/bridge-client.c runtime/hrmemvar.c runtime/hrmembridge.c -o evidence/$target/client$ext
 if [ "$target" = linux ];then evidence/$target/client >evidence/$target/run.stdout 2>evidence/$target/run.stderr;else "$WINE" "$PWD/evidence/$target/client$ext" >evidence/$target/run.stdout 2>evidence/$target/run.stderr;fi
 echo 0 >evidence/$target/run.rc
 sha256sum evidence/$target/client$ext >evidence/$target/binary.sha
 rm evidence/$target/client$ext
 "$cc" -std=c11 -O2 -Wall -Wextra -Werror tests/storage-regression.c runtime/hrmemvar.c -o evidence/$target/regression$ext
 if [ "$target" = linux ];then evidence/$target/regression faults >evidence/$target/storage-faults.stdout 2>evidence/$target/storage-faults.stderr;else "$WINE" "$PWD/evidence/$target/regression$ext" faults >evidence/$target/storage-faults.stdout 2>evidence/$target/storage-faults.stderr;fi
 echo 0 >evidence/$target/storage-faults.rc
 if [ "$target" = linux ];then evidence/$target/regression >evidence/$target/storage-semantic.stdout 2>evidence/$target/storage-semantic.stderr;else "$WINE" "$PWD/evidence/$target/regression$ext" >evidence/$target/storage-semantic.stdout 2>evidence/$target/storage-semantic.stderr;fi
 echo 0 >evidence/$target/storage-semantic.rc
 sha256sum evidence/$target/regression$ext >evidence/$target/regression-binary.sha
 rm evidence/$target/regression$ext
 "$assembler" real/$target-linked.s -o real/$target.o
 "$assembler" real/$target-abi.s -o real/$target-abi.o
 "$cc" -std=c11 -O2 -Wall -Wextra -Werror real/client.c runtime/hrmemvar.c runtime/hrmembridge.c real/$target.o real/$target-abi.o -lm -o real/$target-client$ext
 if [ "$target" = linux ];then real/$target-client >real/$target-run.stdout 2>real/$target-run.stderr;else "$WINE" "$PWD/real/$target-client$ext" >real/$target-run.stdout 2>real/$target-run.stderr;fi
 echo 0 >real/$target-run.rc
 sha256sum real/$target-client$ext >real/$target-binary.sha
 "$nm" real/$target.o | grep -E ' hbc_float_new$| hbc_float_unpack$| hbc_str_f64$| hrbt_(new|format)$' >real/symbols-$target.txt
 "$od" -d real/$target.o | sed -n '/<hrbt_new>:/,/<hrbt_string>:/p' >real/objdump-$target-callchain.txt
 rm real/$target-client$ext real/$target.o real/$target-abi.o
 done
gcc -std=c11 -g -fsanitize=address,undefined -Wall -Wextra -Werror tests/bridge-client.c runtime/hrmemvar.c runtime/hrmembridge.c -o evidence/linux/sanitize
ASAN_OPTIONS=detect_leaks=1 evidence/linux/sanitize >evidence/linux/sanitize.stdout 2>evidence/linux/sanitize.stderr
echo 0 >evidence/linux/sanitize.rc
sha256sum evidence/linux/sanitize >evidence/linux/sanitize-binary.sha
rm evidence/linux/sanitize
cmp evidence/linux/run.stdout evidence/windows/run.stdout
cmp evidence/linux/storage-faults.stdout evidence/windows/storage-faults.stdout
cmp real/linux-run.stdout real/windows-run.stdout
cmp evidence/linux/storage-semantic.stdout evidence/windows/storage-semantic.stdout
python3 - <<'PY'
from pathlib import Path
for p in Path('evidence').rglob('*.stderr'): assert not p.read_bytes(),p
for target in ['linux','windows']:
 assert not Path('real/'+target+'-run.stderr').read_bytes()
 lines=Path('real/'+target+'-run.stdout').read_bytes().splitlines(keepends=True)
 assert b''.join(lines[1:5])==Path('oracle/run.stdout').read_bytes()
 assert b''.join(lines[1:5])==Path('oracle/windows/run.stdout').read_bytes()
print('fake pool, production helper/render, ABI and storage-regression gates PASS ELF/PE; sanitizer clean')
PY

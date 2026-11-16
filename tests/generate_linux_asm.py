#!/usr/bin/env python3
"""Generate own DBF embedded assembly. Run from spike/repo root.
All generation happens during development, never when hbc compiles a program.
"""
from pathlib import Path
import subprocess,re,json,hashlib
root=Path(__file__).resolve().parents[1]
flags=['-std=c99','-O2','-S','-ffreestanding','-fno-builtin','-fno-stack-protector','-fno-pic','-fno-pie','-fno-asynchronous-unwind-tables','-fno-unwind-tables','-fno-ident','-mno-red-zone','-Wall','-Wextra','-Werror','-Wno-misleading-indentation']
# Additional flags: no builtin helpers, no synchronous unwind tables/ident,
# no red-zone reliance while sharing a runtime, strict warnings. We deliberately
# keep ordinary integer/floating ABI conventions, with no architecture tuning.
out=root/'generated/hrdbf_linux.s';raw=root/'generated/hrdbf_linux.raw.s'
p=subprocess.run(['gcc',*flags,'runtime/hrdbf_embedded_linux.c','-o',str(raw)],cwd=root,capture_output=True);assert p.returncode==0,p.stderr
s=raw.read_text();s=re.sub(r'\.section[^\n]*\.rodata\.str1\.[18][^\n]*', '.section\t.rodata', s)
s=re.sub(r'\.section[^\n]*\.rodata\.[A-Za-z0-9]+[^\n]*', '.section\t.rodata', s)  # cst8/stra pools: hbc's assembler knows plain .rodata only
s=re.sub(r'\.L([A-Za-z0-9_.$]+)',r'.Lhrdbf_\1',s);s=s.replace('movabsq','movabs')
s=re.sub(r'^(\s*(?:sal|sar|shl|shr|rol|ror)[bwlq]?)\s+(%\w+)\s*$',r'\1 $1, \2',s,flags=re.M)  # one-operand shift -> explicit $1 (same as the Windows blob step)

# D5: gcc may label the second half of a 16-byte constant pool entry with
# `.set A,B+8` (rodata.cst16); hbc's assembler takes integer .set only.
# Plant the alias label at its real offset inside the 4x .long body.
def _resolve_set8(s):
    pat=re.compile(r'^\t\.set\t(\.[A-Za-z0-9_.$]+),(\.[A-Za-z0-9_.$]+)\+8\n((?:^\t\.section\t\.rodata\n)?^\t\.align 16\n)(\2:\n(?:\t\.long\t[^\n]+\n){2})((?:\t\.long\t[^\n]+\n){2})',re.M)
    def repl(m):
        return m.group(3)+m.group(4)+m.group(1)+':\n'+m.group(5)
    s2=pat.sub(repl,s)
    leftover=re.findall(r'^\t\.set\t(\.[A-Za-z0-9_.$]+),(.+)$',s2,re.M)
    bad=[(a,b) for a,b in leftover if not re.fullmatch(r'-?\d+',b.strip())]
    assert not bad,f"unresolved .set expressions: {bad}"
    return s2
s=_resolve_set8(s)
s=re.sub(r'^\s*#?\s*/?(?:NO_)?APP\s*\n','',s,flags=re.M)  # D5: GAS (linux) / GAS-PE (mingw) inline-asm markers
s=re.sub(r'^\s*# \d+ "[^\n]*" \d+\s*\n','',s,flags=re.M)  # and their cpp line markers
s=re.sub(r'^\s*\.file\s+.*\n','',s,flags=re.M)
s=re.sub(r'^\s*\.local\s+.*\n','',s,flags=re.M)
s=re.sub(r'^\s*\.comm\s+(\S+),(\d+),(\d+)\s*$',lambda m: '\n.bss\n.balign '+m[3]+'\n'+m[1]+':\n.zero '+m[2]+'\n.text',s,flags=re.M)  # hbc's assembler takes no .comm; emit ordinary BSS storage  # gcc may declare new statics .local; hbc's assembler takes no .local
assert not re.search(r'\.cfi|\.eh_frame|@GOT|@PLT|\.got|\.plt',s)
# GCC may emit unprefixed static switch/date tables, not just .L labels.
for label in re.findall(r'^([A-Za-z_.$][A-Za-z0-9_.$]*):',s,re.M):
 if not label.startswith(('hrdbf_','hrv_','hrntx_','hrcdx_','.Lhrdbf_')):
  s=re.sub(r'(?<![A-Za-z0-9_.$])'+re.escape(label)+r'(?![A-Za-z0-9_.$])','hrdbf_local_'+label,s)
labels=re.findall(r'^([A-Za-z_.$][A-Za-z0-9_.$]*):',s,re.M)
assert len(labels)==len(set(labels))
assert all(n.startswith(('hrdbf_','hrv_','hrntx_','hrcdx_','.Lhrdbf_')) for n in labels),[n for n in labels if not n.startswith(('hrdbf_','hrv_','hrntx_','hrcdx_','.Lhrdbf_'))]
# Direct local entry aliases prevent GAS PLT32 relocations even for calls
# to our globally exported entrypoints. No external names are admitted.
for label in labels:
 if label.startswith(('hrdbf_','hrv_','hrntx_','hrcdx_')):
  s=s.replace(label+':',label+':\n.Lhrdbf_entry_'+label+':')
  s=re.sub(r'\b(call|jmp)\s+'+re.escape(label)+r'(?![A-Za-z0-9_.$])',r'\1 .Lhrdbf_entry_'+label,s)
# hbc's internal assembler takes no escape sequences inside string
# directives: rewrite .string/.ascii payloads with escapes as .byte lists
# (.string keeps its terminating NUL).
import ast as _ast
def _deescape(m):
    directive, payload = m.group(1), m.group(2)
    bs = _ast.literal_eval('b' + payload)
    if directive == 'string': bs = bs + b'\0'
    return '\t.byte ' + ','.join(str(b) for b in bs)
s = re.sub(r'^\s*\.(string|ascii)\s+("(?:[^"\\]|\\.)*")\s*$', lambda m: _deescape(m) if '\\' in m.group(2) else m.group(0), s, flags=re.M)
assert not re.search(r'^\s*\.(string|ascii)\s+".*\\', s, flags=re.M)
out.write_text(s)
obj=root/'generated/hrdbf_linux.o';subprocess.run(['as',str(out),'-o',str(obj)],check=True)
u=subprocess.check_output(['nm','-u',str(obj)],text=True);assert not u,u
sections=subprocess.check_output(['readelf','-SW',str(obj)],text=True);assert '.eh_frame' not in sections and '.got' not in sections and '.plt' not in sections
relocs=subprocess.check_output(['objdump','-r',str(obj)],text=True)
# Normal internal text/rodata/BSS relocations are expected in a relocatable
# assembler object. No external/PLT/GOT relocation is admitted.
assert not re.search(r'GOT|PLT|JUMP_SLOT|GLOB_DAT',relocs),relocs
version=subprocess.check_output(['gcc','--version'],text=True).splitlines()[0]
# Bind the actual unity translation unit, including its transitive headers.
deps=subprocess.check_output(['gcc',*flags,'-MM','runtime/hrdbf_embedded_linux.c'],cwd=root,text=True)
dep_paths=sorted(set(deps.replace('\\\n',' ').split(':',1)[1].split()))
source_hashes={name:hashlib.sha256((root/name).read_bytes()).hexdigest() for name in dep_paths}
ledger={'compiler':version,'flags':flags,'source_sha256':hashlib.sha256((root/'runtime/hrdbf_embedded_linux.c').read_bytes()).hexdigest(),'source_dependencies_sha256':source_hashes,'asm_sha256':hashlib.sha256(s.encode()).hexdigest(),'labels':len(labels),'undefined_symbols':[],'local_label_namespace':'.Lhrdbf_','notes':'Experimental compiler integration; separate non-DBF byte-identity evidence required. CWD-independent output: .file stripped.'}
(root/'generated/recipe.json').write_text(json.dumps(ledger,indent=2)+'\n');(root/'generated/relocations.txt').write_text(relocs);print(json.dumps(ledger,indent=2))

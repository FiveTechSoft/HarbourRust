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
s=raw.read_text();s=re.sub(r'\.L([A-Za-z0-9_.$]+)',r'.Lhrdbf_\1',s);s=re.sub(r'^\s*\.file .*\n','',s,flags=re.M)
assert not re.search(r'\.cfi|\.eh_frame|@GOT|@PLT|\.got|\.plt',s)
# GCC may emit unprefixed static switch/date tables, not just .L labels.
for label in re.findall(r'^([A-Za-z_.$][A-Za-z0-9_.$]*):',s,re.M):
 if not label.startswith(('hrdbf_','hrv_','hrntx_','.Lhrdbf_')):
  s=re.sub(r'(?<![A-Za-z0-9_.$])'+re.escape(label)+r'(?![A-Za-z0-9_.$])','hrdbf_local_'+label,s)
labels=re.findall(r'^([A-Za-z_.$][A-Za-z0-9_.$]*):',s,re.M)
assert len(labels)==len(set(labels))
assert all(n.startswith(('hrdbf_','hrv_','hrntx_','.Lhrdbf_')) for n in labels),[n for n in labels if not n.startswith(('hrdbf_','hrv_','hrntx_','.Lhrdbf_'))]
# Direct local entry aliases prevent GAS PLT32 relocations even for calls
# to our globally exported entrypoints. No external names are admitted.
for label in labels:
 if label.startswith(('hrdbf_','hrv_','hrntx_')):
  s=s.replace(label+':',label+':\n.Lhrdbf_entry_'+label+':')
  s=re.sub(r'\b(call|jmp)\s+'+re.escape(label)+r'(?![A-Za-z0-9_.$])',r'\1 .Lhrdbf_entry_'+label,s)
out.write_text(s)
obj=root/'generated/hrdbf_linux.o';subprocess.run(['as',str(out),'-o',str(obj)],check=True)
u=subprocess.check_output(['nm','-u',str(obj)],text=True);assert not u,u
sections=subprocess.check_output(['readelf','-SW',str(obj)],text=True);assert '.eh_frame' not in sections and '.got' not in sections and '.plt' not in sections
relocs=subprocess.check_output(['objdump','-r',str(obj)],text=True)
# Normal internal text/rodata/BSS relocations are expected in a relocatable
# assembler object. No external/PLT/GOT relocation is admitted.
assert not re.search(r'GOT|PLT|JUMP_SLOT|GLOB_DAT',relocs),relocs
version=subprocess.check_output(['gcc','--version'],text=True).splitlines()[0]
ledger={'compiler':version,'flags':flags,'source_sha256':hashlib.sha256((root/'runtime/hrdbf_embedded_linux.c').read_bytes()).hexdigest(),'asm_sha256':hashlib.sha256(s.encode()).hexdigest(),'labels':len(labels),'undefined_symbols':[],'local_label_namespace':'.Lhrdbf_','notes':'Experimental compiler integration; separate non-DBF byte-identity evidence required. CWD-independent output: .file stripped.'}
(root/'generated/recipe.json').write_text(json.dumps(ledger,indent=2)+'\n');(root/'generated/relocations.txt').write_text(relocs);print(json.dumps(ledger,indent=2))

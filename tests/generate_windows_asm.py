#!/usr/bin/env python3
"""Generate independent Windows DBF runtime, developer-only cross GCC step."""
from pathlib import Path
import subprocess,re,json,hashlib,os
root=Path(__file__).resolve().parents[1]
cc=os.environ.get('HR_MINGW_CC','x86_64-w64-mingw32-gcc')
flags=['-std=c99','-O2','-S','-ffreestanding','-fno-builtin','-fno-stack-protector','-fno-asynchronous-unwind-tables','-fno-unwind-tables','-fno-ident','-mno-red-zone','-fno-jump-tables','-Wall','-Wextra','-Werror','-Wno-misleading-indentation']
raw=root/'generated/hrdbf_windows.raw.s'
subprocess.run([cc,*flags,'runtime/hrdbf_embedded_windows.c','-o',raw],cwd=root,check=True)
s=raw.read_text();s=re.sub(r'^\s*\.(file|def)\s+.*\n','',s,flags=re.M)
s=re.sub(r'\.L([A-Za-z0-9_.$]+)',r'.Lhrdbfw_\1',s)
# MinGW dllimport pointers: use ordinary named import thunks, which both the
# native PE writer and development binutils understand.
s=re.sub(r'call\s+\*__imp_(\w+)\(%rip\)',r'call \1',s)
s=re.sub(r'movq\s+__imp_(\w+)\(%rip\),\s*(%\w+)',r'leaq \1(%rip), \2',s)
s=re.sub(r'jmp\s+\*__imp_(\w+)\(%rip\)',r'jmp \1',s)
s=re.sub(r'(?<![A-Za-z0-9_.$])(\d+)\+([A-Za-z_.$][A-Za-z0-9_.$]*)',r'\2+\1',s)
s=re.sub(r'^(\s*(?:sal|sar|shl|shr|rol|ror)[bwlq]?)\s+(%\w+)\s*$',r'\1 $1, \2',s,flags=re.M)

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
s=s.replace('movabsq','movabs')
assert '__imp_' not in s
# Normalise BSS and escaped literal bytes without changing bytes/alignments.
s=re.sub(r'^\s*\.lcomm\s+(\S+),(\d+),(\d+)',lambda m: '\n.bss\n.balign '+m[3]+'\n'+m[1]+':\n.zero '+m[2]+'\n.text',s,flags=re.M)
import ast
s=re.sub(r'^\s*\.ascii\s+(".*")\s*$',lambda m: '\n.byte '+','.join(str(ord(c)) for c in ast.literal_eval(m[1])),s,flags=re.M)
for label in re.findall(r'^([A-Za-z_.$][A-Za-z0-9_.$]*):',s,re.M):
 if not label.startswith(('hrdbf_','hrdbfw_','hrv_','hrntx_','hrcdx_','.Lhrdbfw_')):
  s=re.sub(r'(?<![A-Za-z0-9_.$])'+re.escape(label)+r'(?![A-Za-z0-9_.$])','hrdbfw_local_'+label,s)
assert not re.search(r'__chkstk|__stack_chk|GOT|PLT|\.seh|\.cfi|\.eh_frame',s)
# Export compiler-facing internal ABI wrappers. The C bodies use Win64.
arity={'close':0,'open':5,'top':0,'bottom':0,'skip':1,'order_add':2,'order_clear':0,'found':0,'seek':4,'seek_dyn':4,'recno':0,'lastrec':0,'fcount':0,'goto':1,'ordselect':1,'bof':0,'eof':0,'deleted':0,'fieldput':3,'append':0,'delete':0,'recall':0,'commit':0,'render':3,'integer':2,'equal':4,'compare':4,'empty':2,'unsupported':0}
s+='\n.text\n'
for name,n in arity.items():
 s+='\nhrdbf_app_'+name+':\n    push %rbp\n    mov %rsp, %rbp\n    sub $'+str(48 if n>=5 else 32)+', %rsp\n'
 # Copy from the last source first, so rcx/rdx inputs survive reassignment.
 # The fifth argument arrives in r8 and moves to the Win64 stack slot before
 # r8 is reassigned; 32-byte shadow space plus one 8-byte outgoing slot.
 if n>=5:s+='    mov %r8, 32(%rsp)\n'
 if n>=4:s+='    mov %rcx, %r9\n'
 if n>=3:s+='    mov %rdx, %r8\n'
 if n>=2:s+='    mov %rsi, %rdx\n'
 if n>=1:s+='    mov %rdi, %rcx\n'
 s+='    call hrdbfw_app_'+name+'\n    leave\n    ret\n'
s+='''
hrdbf_app_get:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rsi, 48(%rsp)
    mov %rdi, %rdx
    lea 32(%rsp), %rcx
    lea hrdbfw_copy_callback(%rip), %r8
    call hrdbfw_app_get
    mov 32(%rsp), %rax
    mov 40(%rsp), %rdx
    leave
    ret
hrdbf_app_get_name:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rdx, 48(%rsp)
    mov %rsi, %r8
    mov %rdi, %rdx
    lea 32(%rsp), %rcx
    lea hrdbfw_copy_callback(%rip), %r9
    call hrdbfw_app_get_name
    mov 32(%rsp), %rax
    mov 40(%rsp), %rdx
    leave
    ret
hrdbf_app_arith:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rcx, 32(%rsp)
    mov %r8, 40(%rsp)
    mov %rdx, %r9
    mov %rsi, %r8
    mov %rdi, %rdx
    lea 48(%rsp), %rcx
    call hrdbfw_app_arith
    mov 48(%rsp), %rax
    mov 56(%rsp), %rdx
    leave
    ret
hrdbfw_copy_callback:
    push %rbp
    mov %rsp, %rbp
    push %rdi
    push %rsi
    sub $192, %rsp
    movdqu %xmm6, 32(%rsp)
    movdqu %xmm7, 48(%rsp)
    movdqu %xmm8, 64(%rsp)
    movdqu %xmm9, 80(%rsp)
    movdqu %xmm10, 96(%rsp)
    movdqu %xmm11, 112(%rsp)
    movdqu %xmm12, 128(%rsp)
    movdqu %xmm13, 144(%rsp)
    movdqu %xmm14, 160(%rsp)
    movdqu %xmm15, 176(%rsp)
    mov %rcx, %rdi
    mov %rdx, %rsi
    call hbc_strcpy
    movdqu 32(%rsp), %xmm6
    movdqu 48(%rsp), %xmm7
    movdqu 64(%rsp), %xmm8
    movdqu 80(%rsp), %xmm9
    movdqu 96(%rsp), %xmm10
    movdqu 112(%rsp), %xmm11
    movdqu 128(%rsp), %xmm12
    movdqu 144(%rsp), %xmm13
    movdqu 160(%rsp), %xmm14
    movdqu 176(%rsp), %xmm15
    add $192, %rsp
    pop %rsi
    pop %rdi
    pop %rbp
    ret
'''
# The only callback passed by the compiler is hbc_strcpy. Its supplied pointer
# is deliberately replaced with the Win64 bridge above; no generic callback API.
(root/'generated/hrdbf_windows.s').write_text(s)
deps=subprocess.check_output([cc,*flags,'-MM','runtime/hrdbf_embedded_windows.c'],cwd=root,text=True)
paths=sorted(set(deps.replace('\\\n',' ').split(':',1)[1].split()))
ledger=dict(compiler=subprocess.check_output([cc,'--version'],text=True).splitlines()[0],flags=flags,source_dependencies_sha256={x:hashlib.sha256((root/x).read_bytes()).hexdigest() for x in paths},asm_sha256=hashlib.sha256(s.encode()).hexdigest(),notes='Win64 C bodies; explicit internal ABI and copy callback bridges; DLL import pointer references normalised to named thunks')
(root/'generated/windows-recipe.json').write_text(json.dumps(ledger,indent=2)+'\n')
print('generated',len(s),'bytes')

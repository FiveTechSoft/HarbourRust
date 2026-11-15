from pathlib import Path
import subprocess,os,json
import argparse
ap=argparse.ArgumentParser();ap.add_argument('--compiler',default='hbc-final');ap.add_argument('--wine',required=True);ap.add_argument('--wine-prefix',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
r=Path(__file__).resolve().parents[2];compiler=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
s='''.text
.globl _start
_start:
    and $-16, %rsp
    sub $32, %rsp
    mov $0x1122334455667788, %rdi
    mov $0x2233445566778899, %rsi
'''
for x in range(6,16):s+=f'    movdqu sentinel(%rip), %xmm{x}\n'
s+='''    lea path(%rip), %rcx
    mov $12, %edx
    call hrdbfw_copy_callback
    mov $0x1122334455667788, %r10
    cmp %r10, %rdi
    jne failed
    mov $0x2233445566778899, %r10
    cmp %r10, %rsi
    jne failed
'''
for x in range(6,16):
 s+=f'    movdqu %xmm{x}, saved(%rip)\n    mov saved(%rip), %r10\n    cmp sentinel(%rip), %r10\n    jne failed\n    mov saved+8(%rip), %r10\n    cmp sentinel+8(%rip), %r10\n    jne failed\n'
s+='''    lea path(%rip), %rdi
    mov $12, %esi
    mov $1, %edx
    mov $1, %ecx
    call hrdbf_app_open
    mov $1, %edi
    xor %esi, %esi
    call hrdbf_app_get
    cmp $4, %rax
    jne failed
    cmpb $75, (%rdx)
    jne failed
    call hrdbf_app_close
    cmpq $0, bad(%rip)
    jne failed
    xor %ecx, %ecx
    call ExitProcess
failed:
    mov $1, %ecx
    call ExitProcess
hbc_strcpy:
    mov %rsp, %r10
    and $15, %r10
    cmp $8, %r10
    je 1f
    movq $1, bad(%rip)
1:
    mov %rsi, %rcx
    mov %rdi, %rsi
    lea copybuf(%rip), %rdi
    rep movsb
'''
for x in range(6,16):s+=f'    pxor %xmm{x}, %xmm{x}\n'
s+='''    lea copybuf(%rip), %rax
    ret
.section .rdata,"r"
sentinel:
.quad 0x123456789abcdef0,0x1122334455667788
path:
.byte 99,100,120,112,114,111,98,101,46,100,98,102
.bss
.balign 16
copybuf:
.zero 256
saved:
.zero 16
bad:
.zero 8
'''
s+='\n'+(r/'generated/hrdbf_windows.s').read_text();(out/'probe.s').write_text(s)
# Use the owning compiler's native assembler via a small driver.
(out/'driver.rs').write_text('#[path='+json.dumps(str(r/'src/hasm.rs'))+'] mod hasm;\n#[path='+json.dumps(str(r/'src/hpe.rs'))+'] mod hpe;\nfn main(){let a:Vec<String>=std::env::args().collect();std::fs::write(&a[2],hasm::assemble_pe(&std::fs::read_to_string(&a[1]).unwrap()).unwrap()).unwrap();}')
subprocess.run([str(Path.home()/'.cargo/bin/rustc'),'--edition=2021',out/'driver.rs','-o',out/'driver'],check=True,capture_output=True)
subprocess.run([out/'driver',out/'probe.s',out/'probe.exe'],check=True,capture_output=True)
env={**os.environ,'WINEPREFIX':a.wine_prefix,'WINEDEBUG':'-all'}
p=subprocess.run([a.wine,out/'probe.exe'],cwd=r,env=env,capture_output=True,timeout=30)
for x,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(out/('run.'+x)).write_bytes(b)
assert p.returncode==0 and not p.stdout and not p.stderr,(p.returncode,p.stdout,p.stderr)
print('PASS native PE callback preserves rdi/rsi+xmm6..15 (all128bits), shadow/alignment, hidden aggregate return FieldGet, DBF open/close')

#!/usr/bin/env python3
"""Developer-only regeneration of own freestanding FILE runtime."""
from pathlib import Path
import subprocess,re,json,hashlib,os,ast
root=Path(__file__).resolve().parents[1]
flags=['-std=c99','-O2','-S','-ffreestanding','-fno-builtin','-fno-stack-protector','-fno-asynchronous-unwind-tables','-fno-unwind-tables','-fno-ident','-fno-jump-tables','-mno-red-zone']
for platform,cc,extra in [('linux','gcc',['-fPIC']),('windows',os.environ.get('HR_MINGW_CC','x86_64-w64-mingw32-gcc'),[])]:
 raw=root/'generated'/('hrfile_'+platform+'.raw.s');dest=root/'generated'/('hrfile_'+platform+'.s')
 subprocess.run([cc,*flags,*extra,'runtime/hrfile.c','-o',raw],cwd=root,check=True)
 s=raw.read_text();s=re.sub(r'^\s*\.(file|def|local)\s+.*\n','',s,flags=re.M)
 s=re.sub(r'^\s*#?\s*/?(?:NO_)?APP\s*\n','',s,flags=re.M);s=re.sub(r'^\s*# \d+ "[^\n]*" \d+\s*\n','',s,flags=re.M)
 s=re.sub(r'\.L([A-Za-z0-9_.$]+)',r'.Lhrfile_\1',s)
 s=re.sub(r'\.section[^\n]*\.rodata\.[A-Za-z0-9.]+[^\n]*','.section .rodata',s)
 s=re.sub(r'^\s*\.(?:lcomm|comm)\s+(\S+),(\d+),(\d+)\s*$',lambda m:'\n.bss\n.balign '+m[3]+'\n'+m[1]+':\n.zero '+m[2]+'\n.text',s,flags=re.M)
 s=re.sub(r'^(\s*(?:sal|sar|shl|shr|rol|ror)[bwlq]?)\s+(%\w+)\s*$',r'\1 $1, \2',s,flags=re.M)
 s=re.sub(r'^\s*\.(string|ascii)\s+("(?:[^"\\]|\\.)*")\s*$',lambda m:'.byte '+','.join(str(b)for b in ast.literal_eval('b'+m[2])+(b'\0'if m[1]=='string'else b'')),s,flags=re.M)
 s=re.sub(r'^\s*\.word\s+(\d+)\s*$',lambda m:'.byte '+str(int(m[1])&255)+','+str(int(m[1])>>8),s,flags=re.M)
 s=s.replace('movabsq','movabs')
 assert not re.search(r'__chkstk|\.seh|\.cfi|GOT|PLT|memcpy|memset',s),s
 # No symbolic absolute pointers in generated data, all code uses RIP addressing.
 assert not re.search(r'\.(?:quad|long)\s+[A-Za-z_.$]',s)
 if platform=='windows':
  s+='\n.text\n'
  for name,n in [('exists',2),('set',3)]:
   s+='hrfile_app_'+name+':\n    push %rbp\n    mov %rsp, %rbp\n    sub $32, %rsp\n'
   if n==3:s+='    mov %rdx, %r8\n'
   s+='    mov %rsi, %rdx\n    mov %rdi, %rcx\n    call hrfile_'+name+'\n    leave\n    ret\n'
 else:
  s+='\n.text\nhrfile_app_exists:\n    jmp hrfile_exists\nhrfile_app_set:\n    jmp hrfile_set\n'
 dest.write_text(s)
 ledger={'compiler':subprocess.check_output([cc,'--version'],text=True).splitlines()[0],'flags':flags+extra,'source_sha256':hashlib.sha256((root/'runtime/hrfile.c').read_bytes()).hexdigest(),'asm_sha256':hashlib.sha256(s.encode()).hexdigest()}
 (root/'generated'/('hrfile_'+platform+'.recipe.json')).write_text(json.dumps(ledger,indent=2)+'\n')
 raw.unlink()
 print(platform,ledger)

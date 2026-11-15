#!/usr/bin/env python3
"""Direct shared fill ABI/guard/all-byte canaries, GNU and native ELF/PE.
DF is clear under the x64 ABI. Wine is not native Windows.
"""
import argparse,subprocess,json,os
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for k in ['compiler','output']:p.add_argument('--'+k,type=Path,required=True)
for k in ['wine','wine-prefix','mingw','mlib']:p.add_argument('--'+k,type=Path)
a=p.parse_args();a.output=a.output.resolve();a.compiler=a.compiler.resolve();a.output.mkdir(parents=True,exist_ok=False)
root=Path(__file__).resolve().parents[2];env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=str(a.wine_prefix.resolve())
def run(cmd):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=90)
 assert(q.returncode,q.stderr)==(0,b''),(cmd,q.returncode,q.stdout,q.stderr)
 if not (len(cmd)>0 and str(cmd[0])==str(a.compiler)):assert q.stdout==b'',(cmd,q.stdout)
 return q
# The independent assembly input is also assembled by the native assembler.
rs=a.output/'assemble.rs'
rs.write_text(f'#[path="{root}/src/hasm.rs"]mod hasm;\n#[path="{root}/src/hpe.rs"]mod hpe;\nfn main(){{let a:Vec<String>=std::env::args().collect();let s=std::fs::read_to_string(&a[1]).unwrap();let b=if a[3]=="windows"{{hasm::assemble_pe(&s)}}else{{hasm::assemble(&s)}}.unwrap();std::fs::write(&a[2],b).unwrap();}}\n')
assembler=a.output/'assemble'
q=subprocess.run([os.environ.get('RUSTC','rustc'),'--edition=2021','-O','-C','strip=symbols',str(rs),'-o',str(assembler)],capture_output=True);assert q.returncode==0,q.stderr
sizes=[0,1,7,8,9,63,64,65,255,256,257,2047,2048,2049,4095,4096,4097,16383,16384,16385,65535,65536,65537,1048576]
rows=[]
for target in ['linux','windows'] if a.wine else ['linux']:
 for instrument in [False,True]:
  src=a.output/'probe.prg';asm=a.output/'probe.s';obj=a.output/'probe.o';src.write_text('function Main()\nreturn nil\n')
  run([a.compiler,src,asm,'--target='+target]+(['--instrument'] if instrument else []))
  code=asm.read_text().replace('call hbc_fn_main','call fill_probe',1)
  body=['.text','fill_probe:','push %rbp','mov %rsp,%rbp','push %rbx','push %r12','push %r13','push %r14','push %r15','sub $8,%rsp','mov $101,%ebx','mov $102,%r12d','mov $103,%r13d','mov $104,%r14d','mov $105,%r15d']
  count=0
  for n in sizes:
   for off in [0,1,7,15]:
    for byte in [0,32,65,255]:
     count+=1;label=f'.Lfill_{count}'
     body += ['lea fill_buffer(%rip),%rdi','mov $0xcccccccccccccccc,%rax',f'mov ${n+64},%rcx','rep stosb',f'lea fill_buffer+{16+off}(%rip),%rdi',f'mov ${n},%rcx',f'mov ${byte*0x0101010101010101},%rax','mov $901,%r10','mov $902,%rsi','mov $903,%rdx','call hbc_strfill','cmp $901,%r10','jne fill_fail','cmp $902,%rsi','jne fill_fail','cmp $903,%rdx','jne fill_fail',f'lea fill_buffer+{16+off+n}(%rip),%r8','cmp %r8,%rdi','jne fill_fail','test %rcx,%rcx','jnz fill_fail',f'cmpb $204,fill_buffer+{15+off}(%rip)','jne fill_fail',f'cmpb $204,fill_buffer+{16+off+n}(%rip)','jne fill_fail',f'lea fill_buffer+{16+off}(%rip),%r8',f'mov ${n},%r9',f'{label}:','test %r9,%r9',f'jz {label}_done',f'cmpb ${byte},(%r8)','jne fill_fail','inc %r8','dec %r9',f'jmp {label}',f'{label}_done:','cmp $101,%rbx','jne fill_fail','cmp $102,%r12','jne fill_fail','cmp $103,%r13','jne fill_fail','cmp $104,%r14','jne fill_fail','cmp $105,%r15','jne fill_fail','mov %rsp,%rax','and $15,%eax','jnz fill_fail']
  body += ['add $8,%rsp','pop %r15','pop %r14','pop %r13','pop %r12','pop %rbx','pop %rbp','ret','fill_fail:']
  body += ['sub $40,%rsp','mov $99,%ecx','call ExitProcess'] if target=='windows' else ['mov $60,%eax','mov $99,%edi','syscall']
  body += ['.bss','.align 16','fill_buffer: .zero 1048640']
  # Keep the canary within native assembler's existing address grammar:
  # RIP label plus numeric offset is spelled as LEA then ADD.
  import re
  fixed=[]
  for line in body:
   m=re.fullmatch(r'lea fill_buffer\+(\d+)\(%rip\),(%r\w+)',line)
   if m:fixed += ['lea fill_buffer(%rip),'+m[2],f'add ${m[1]},'+m[2]];continue
   m=re.fullmatch(r'cmpb \$204,fill_buffer\+(\d+)\(%rip\)',line)
   if m:fixed += ['lea fill_buffer(%rip),%r11',f'cmpb $204,{m[1]}(%r11)'];continue
   fixed.append(line)
  asm.write_text(code+'\n'+'\n'.join(fixed)+'\n')
  for backend in ['GNU','native']:
   exe=a.output/'probe.program'
   if backend=='native':run([assembler,asm,exe,target])
   elif target=='linux':run(['as',asm,'-o',obj]);run(['ld',obj,'-o',exe])
   else:
    run([a.mingw/'x86_64-w64-mingw32-as',asm,'-o',obj]);run([a.mingw/'x86_64-w64-mingw32-ld',obj,'-o',exe,'-e','_start','--subsystem','console','-L'+str(a.mlib),'-lkernel32'])
   exe.chmod(0o755);run([a.wine,exe] if target=='windows' else [exe]);exe.unlink()
   rows.append(dict(target=target,instrument=instrument,backend=backend,cases=count,all_bytes=True,guard_bytes=True,callee_saved=True,r10=True,rsi_rdx=True,stack=True))
  asm.unlink();src.unlink();obj.unlink(missing_ok=True)
assembler.unlink()
(a.output/'summary.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',count,'fill canaries x',len(rows),'target/mode/backend runs')

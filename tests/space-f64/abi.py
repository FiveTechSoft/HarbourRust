#!/usr/bin/env python3
"""Exact-bit F64 conversion-only oracle domain and nonallocating range guard.
Large positive admitted conversions are NOT passed to Space allocation.
"""
import argparse,subprocess,json,os,struct,math
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for k in ['compiler','output']:p.add_argument('--'+k,required=True,type=Path)
for k in ['wine','wine-prefix','mingw','mlib']:p.add_argument('--'+k,type=Path)
a=p.parse_args();a.compiler=a.compiler.resolve();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
patterns=['0000000000000000','8000000000000000','0000000000000001','8000000000000001','3fefffffffffffff','3ff0000000000000','3fffffffffffffff','bfffffffffffffff','43dfffffffffffff','43e0000000000000','43e0000000000001','c3dfffffffffffff','c3e0000000000000','c3e0000000000001','7ff0000000000000','fff0000000000000','7ff8000000000000','fff8000000000000','7ff0000000000001']
rows=[];env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=str(a.wine_prefix.resolve())
for target in ['linux','windows'] if a.wine else ['linux']:
 for instrument in [False,True]:
  for bits in patterns:
   label=target+'-'+str(instrument)+'-'+bits
   src=a.output/'case.prg';asm=a.output/'case.s';obj=a.output/'case.o';exe=a.output/'case.program'
   src.write_text('function Main()\nreturn nil\n');q=subprocess.run([str(a.compiler),str(src),str(asm),'--target='+target]+(['--instrument'] if instrument else []),capture_output=True);assert q.returncode==0,q.stderr
   value=struct.unpack('>d',bytes.fromhex(bits))[0];admit=math.isfinite(value) and -(2**63)<=value<2**63
   code=asm.read_text().replace('call hbc_fn_main','call space_test',1)
   body=['.text','space_test:','push %rbp','mov %rsp,%rbp','push %rbx','push %r12','push %r13','push %r14','push %r15','sub $8,%rsp','mov $101,%ebx','mov $102,%r12d','mov $103,%r13d','mov $104,%r14d','mov $105,%r15d',f'movabs $0x{bits},%rax','movq %rax,%xmm0','call hbc_space_count_f64']
   if admit:body += [f'movabs ${int(value)},%rdx','cmp %rdx,%rax','jne space_fail','mov hbc_mem_allocs(%rip),%rax','cmp hbc_mem_frees(%rip),%rax','jne space_fail','cmp $101,%rbx','jne space_fail','cmp $102,%r12','jne space_fail','cmp $103,%r13','jne space_fail','cmp $104,%r14','jne space_fail','cmp $105,%r15','jne space_fail','mov %rsp,%rcx','and $15,%ecx','jnz space_fail','add $8,%rsp','pop %r15','pop %r14','pop %r13','pop %r12','pop %rbx','leave','ret']
   else:body+=['jmp space_fail']
   body+=['space_fail:']
   body+=(['mov $60,%eax','mov $99,%edi','syscall'] if target=='linux' else ['sub $48,%rsp','mov $99,%ecx','call ExitProcess'])
   asm.write_text(code+'\n'+'\n'.join(body)+'\n')
   cmds=([['as',str(asm),'-o',str(obj)],['ld',str(obj),'-o',str(exe)]] if target=='linux' else [[str(a.mingw/'x86_64-w64-mingw32-as'),str(asm),'-o',str(obj)],[str(a.mingw/'x86_64-w64-mingw32-ld'),str(obj),'-o',str(exe),'-e','_start','--subsystem','console','-L'+str(a.mlib),'-lkernel32']])
   for cmd in cmds:
    q=subprocess.run(cmd,capture_output=True);assert q.returncode==0,q.stderr
   q=subprocess.run([str(a.wine),str(exe)] if target=='windows' else [str(exe)],capture_output=True,env=env,timeout=30)
   if admit:assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(label,q.returncode,q.stdout,q.stderr)
   else:assert q.returncode==1 and q.stdout.startswith(b'Error: Space F64 count out of I64 range\n') and not q.stderr,(label,q.returncode,q.stdout,q.stderr)
   rows.append(dict(bits=bits,target=target,instrument=instrument,admitted=admit,expected_i64=str(int(value)) if admit else None,range_guard=not admit,allocation_attempted=False))
   for f in [exe,obj,asm,src]:f.unlink()
(a.output/'summary.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',len(rows),'bit-exact conversion-only cases; no huge allocation')

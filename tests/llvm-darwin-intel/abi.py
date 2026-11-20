#!/usr/bin/env python3
"""Own MIT SysV Intel ABI canary and assembly counterfactuals, emulated only."""
from pathlib import Path
import subprocess,json,argparse,hashlib
ap=argparse.ArgumentParser();ap.add_argument('--lld',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();gate=Path(__file__).resolve().parent;repo=gate.parents[1];out=Path(a.output).resolve();out.mkdir(exist_ok=False);rt=(repo/'src/llvm_darwin_intel.s').read_text();rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=30)
 for ext,b in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(b)
 assert not r.returncode,(label,r.stderr)
 return r
body='.text\n.p2align 4\n.globl _ll_main\n_ll_main:\n    sub $8, %rsp\n'
for n,v in [('rbx',19),('rbp',20),('r12',21),('r13',22),('r14',23)]:body+=f'    mov ${v}, %{n}\n'
body+='    mov %rsp, %r15\n'
for helper in ['_rt_nl','_rt_sep','_rt_pdrop','_rt_psep','_rt_pflush','_rt_str','_rt_pstrt','_rt_int','_rt_computed']:
 if helper in ['_rt_str','_rt_pstrt']:body+='    lea Lbytes(%rip), %rdi\n    mov $5, %esi\n'
 else:body+='    mov $42, %edi\n'
 body+=f'    call {helper}\n'
 for n,v in [('rbx',19),('rbp',20),('r12',21),('r13',22),('r14',23)]:body+=f'    cmp ${v}, %{n}\n    jne Lbad\n'
 body+='    cmp %rsp, %r15\n    jne Lbad\n'
body+='    xor %edi, %edi\n    mov $0x2000001, %eax\n    syscall\nLbad:\n    mov $2, %edi\n    mov $0x2000001, %eax\n    syscall\n.section __TEXT,__const\nLbytes: .ascii "abc  "\n'
expected=b'\n  abc  abc        42        42'
mutations={'control':rt,'no-r12-restore':rt.replace('    pop %r12\n    pop %rbp','    add $8, %rsp\n    pop %rbp',1),'wrong-number-width':rt.replace('    mov $10, %esi\n    test %r9d','    mov $9, %esi\n    test %r9d',1)}
for name,s in mutations.items():
 w=out/name;w.mkdir();(w/'runtime.s').write_text(s);(w/'abi.s').write_text(body)
 for f in ['runtime','abi']:run(['python3',gate/'cross.py',w/(f+'.s'),w/(f+'.o')],w,f+'-assemble')
 run([a.lld,'-arch','x86_64','-platform_version','macos','14.0','14.0','-e','_main',w/'runtime.o',w/'abi.o','-o',w/'test'],w,'link')
 for mode,flags in [('normal',[]),('short-eintr',['--short-writes','--eintr-once'])]:
  run(['python3',gate/'emulate.py',w/'test',*flags],w,'emulate-'+mode);rc=(w/'test.rc').read_text();stdout=(w/'test.stdout').read_bytes();stderr=(w/'test.stderr').read_bytes();same=rc=='0' and stdout==expected and not stderr
  rows.append(dict(name=name,mode=mode,runtime_sha256=h(w/'runtime.s'),binary_sha256=h(w/'test'),actual_rc=rc,ok=same if name=='control' else not same,kind='ABI+output-control' if name=='control' else 'counterfactual-runtime-difference'));print(name,mode,rc,stdout,same)
report=dict(runner_sha256=h(Path(__file__)),scope='SysV rbx/rbp/r12-r15 and RSP preservation across every returning scalar rt helper. Output canary, synthetic short writes+EINTR and two own isolated runtime counterfactuals. SYSCALL clobbers rcx/r11. Instruction emulation only.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));assert all(x['ok'] for x in rows)

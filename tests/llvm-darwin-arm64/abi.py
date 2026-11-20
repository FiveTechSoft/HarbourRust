#!/usr/bin/env python3
"""Own MIT ABI canary and assembly counterfactuals, emulated only."""
from pathlib import Path
import subprocess,json,os,argparse,hashlib
ap=argparse.ArgumentParser();ap.add_argument('--lld',required=True);ap.add_argument('--output',required=True);a=ap.parse_args();gate=Path(__file__).resolve().parent;repo=gate.parents[1];out=Path(a.output).resolve();out.mkdir(exist_ok=False);rt=(repo/'src/llvm_darwin_arm64.s').read_text();rows=[]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=30)
 for ext,b in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(b)
 assert not r.returncode,(label,r.stderr)
 return r
body='.text\n.p2align 2\n.globl _ll_main\n_ll_main:\n'
for n in range(19,30):body+=f'    mov x{n}, #{n}\n'
body+='    mov x27, sp\n'
for n in range(8,16):body+=f'    mov x9, #{n}\n    fmov d{n}, x9\n'
for helper in ['_rt_nl','_rt_sep','_rt_pdrop','_rt_psep','_rt_pflush','_rt_str','_rt_pstrt','_rt_int','_rt_computed']:
 if helper in ['_rt_str','_rt_pstrt']:body+='    adrp x0, Lbytes@PAGE\n    add x0, x0, Lbytes@PAGEOFF\n    mov x1, #5\n'
 else:body+='    mov x0, #42\n'
 body+=f'    bl {helper}\n'
 for n in range(19,30):
  if n==27:continue
  body+=f'    cmp x{n}, #{n}\n    b.ne Lbad\n'
 body+='    mov x9, sp\n    cmp x9, x27\n    b.ne Lbad\n'
 for n in range(8,16):body+=f'    fmov x9, d{n}\n    cmp x9, #{n}\n    b.ne Lbad\n'
body+='    mov x0, #0\n    mov x16, #1\n    svc #0x80\nLbad:\n    mov x0, #2\n    mov x16, #1\n    svc #0x80\n.section __TEXT,__const\nLbytes: .ascii "abc  "\n'
expected=b'\n  abc  abc        42        42'
mutations={'control':rt,'no-x19-restore':rt.replace('    ldp x19, x20, [sp, #16]','    nop\n    nop',1),'wrong-number-width':rt.replace('    mov x1, #10\n    cbnz x22','    mov x1, #9\n    cbnz x22',1)}
for name,s in mutations.items():
 w=out/name;w.mkdir();(w/'runtime.s').write_text(s);(w/'abi.s').write_text(body)
 for f in ['runtime','abi']:run(['python3',gate/'cross.py',w/(f+'.s'),w/(f+'.o')],w,f+'-assemble')
 run([a.lld,'-arch','arm64','-platform_version','macos','14.0','14.0','-e','_main',w/'runtime.o',w/'abi.o','-o',w/'test'],w,'link')
 for mode,flags in [('normal',[]),('short-eintr',['--short-writes','--eintr-once'])]:
  run(['python3',gate/'emulate.py',w/'test',*flags],w,'emulate-'+mode);rc=(w/'test.rc').read_text();stdout=(w/'test.stdout').read_bytes();stderr=(w/'test.stderr').read_bytes();same=rc=='0' and stdout==expected and not stderr
  rows.append(dict(name=name,mode=mode,runtime_sha256=h(w/'runtime.s'),binary_sha256=h(w/'test'),actual_rc=rc,ok=same if name=='control' else not same,kind='ABI+output-control' if name=='control' else 'counterfactual-runtime-difference'));print(name,mode,rc,stdout,same)
report=dict(runner_sha256=h(Path(__file__)),scope='x19-x29, SP and d8-d15 lower64 preservation across every returning scalar rt helper. Output canary, synthetic short writes+EINTR and two own isolated runtime counterfactuals. Instruction emulation only.',rows=rows);(out/'results.json').write_text(json.dumps(report,indent=2));assert all(x['ok'] for x in rows)

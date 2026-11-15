"""Test-only API wrapper instrumentation of the actual compiler-produced PE.
No product imports/builtin/snapshot accounting paths are changed by this gate.
"""
from pathlib import Path
import argparse,subprocess,os,json,shutil
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--wine',required=True);ap.add_argument('--wine-prefix',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
r=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
for name in ['cdxprobe.dbf','names.cdx']:shutil.copyfile(r/name,out/name)
(out/'bad.cdx').write_bytes(bytes((r/'names.cdx').stat().st_size))
(out/'bad.dbf').write_bytes(bytes(40))
wrappers='''
.text
api_CreateFileW:
 push %rbp
 mov %rsp,%rbp
 sub $64,%rsp
 mov 48(%rbp),%rax
 mov %rax,32(%rsp)
 mov 56(%rbp),%rax
 mov %rax,40(%rsp)
 mov 64(%rbp),%rax
 mov %rax,48(%rsp)
 call CreateFileW
 cmp $-1,%rax
 je 1f
 incq api_handles(%rip)
1: leave
 ret
api_CloseHandle:
 push %rbp
 mov %rsp,%rbp
 sub $32,%rsp
 call CloseHandle
 test %eax,%eax
 je 1f
 decq api_handles(%rip)
1: leave
 ret
api_VirtualAlloc:
 push %rbp
 mov %rsp,%rbp
 sub $32,%rsp
 call VirtualAlloc
 test %rax,%rax
 je 1f
 incq api_snapshots(%rip)
1: leave
 ret
api_VirtualFree:
 push %rbp
 mov %rsp,%rbp
 sub $32,%rsp
 call VirtualFree
 test %eax,%eax
 je 1f
 decq api_snapshots(%rip)
1: leave
 ret
api_ExitProcess:
 cmpq $0,api_handles(%rip)
 jne 1f
 cmpq $0,api_snapshots(%rip)
 jne 1f
 jmp ExitProcess
1: mov $99,%ecx
 jmp ExitProcess
.bss
.balign 8
api_handles:
.zero 8
api_snapshots:
.zero 8
'''
(out/'driver.rs').write_text('#[path='+json.dumps(str(r/'src/hasm.rs'))+'] mod hasm;\n#[path='+json.dumps(str(r/'src/hpe.rs'))+'] mod hpe;\nfn main(){let a:Vec<String>=std::env::args().collect();std::fs::write(&a[2],hasm::assemble_pe(&std::fs::read_to_string(&a[1]).unwrap()).unwrap()).unwrap();}')
subprocess.run([str(Path.home()/'.cargo/bin/rustc'),'--edition=2021',out/'driver.rs','-o',out/'driver'],check=True,capture_output=True)
rows=[]
for name,want in [('stress',0),('implicit',0),('failure',1),('bad-index',1),('bad-dbf',1)]:
 if name=='stress':text=(r/'tests/windows-dbf/memcheck.prg').read_text()
 else:
  dbf='bad.dbf' if name=='bad-dbf' else 'cdxprobe.dbf'
  index='missing.cdx' if name=='failure' else 'bad.cdx' if name=='bad-index' else 'names.cdx'
  text='request DBFCDX\nfunction Main()\ndbUseArea(.T.,"DBFCDX","'+dbf+'","P",.F.,.T.)\nOrdListAdd("'+index+'")\nreturn nil\n'
 p=out/(name+'.prg');p.write_text(text);subprocess.run([str(Path(a.compiler).resolve()),p,out/(name+'.s'),'--target=windows','--instrument'],check=True,capture_output=True)
 s=(out/(name+'.s')).read_text()
 for api in ['CreateFileW','CloseHandle','VirtualAlloc','VirtualFree','ExitProcess']:
  s=s.replace('call '+api,'call api_'+api).replace('leaq '+api+'(%rip)','leaq api_'+api+'(%rip)')
 (out/(name+'-counted.s')).write_text(s+wrappers)
 subprocess.run([out/'driver',out/(name+'-counted.s'),out/(name+'.exe')],check=True,capture_output=True)
 q=subprocess.run([a.wine,str(out/(name+'.exe'))],cwd=out,env={**os.environ,'WINEPREFIX':a.wine_prefix,'WINEDEBUG':'-all'},capture_output=True,timeout=30)
 for x,b in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode())]:(out/(name+'.'+x)).write_bytes(b)
 assert q.returncode==want,(name,q.returncode,q.stderr)
 if name=='stress':assert q.stdout.strip()==b'0' and not q.stderr
 rows.append(dict(case=name,exit=q.returncode,handles_zero=True,snapshots_zero=True));print(rows[-1])
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
print('PASS native PE API-accounted100cycles,implicit close,fatal cleanup; explicit hb_memcheck0')

from pathlib import Path
import subprocess,json
import argparse,os,shutil
ap=argparse.ArgumentParser();ap.add_argument('--output',required=True);a=ap.parse_args()
root=Path(__file__).resolve().parents[1];r=Path(a.output).resolve();r.mkdir(parents=True,exist_ok=False);rows=[]
(r/'driver.rs').write_text('#[path='+json.dumps(str(root/'src/hasm.rs'))+'] mod hasm;\n#[path='+json.dumps(str(root/'src/hpe.rs'))+'] mod hpe;\nfn main(){let a:Vec<String>=std::env::args().collect();std::fs::write(&a[2],hasm::assemble(&std::fs::read_to_string(&a[1]).unwrap()).unwrap()).unwrap();}')
rustc=os.environ.get('RUSTC') or shutil.which('rustc') or str(Path.home()/'.cargo/bin/rustc')
subprocess.run([rustc,'--edition=2021',str(r/'driver.rs'),'-o',str(r/'driver')],check=True,capture_output=True)

cases=['rorb $2,%r9b','rolw $2,%r12w','shlb $2,(%r12)','ud2','setne (%r12)','setnp 4(%rsp)','btq %r9,%r12','btl %eax,%r9d','bswap %eax','bswap %r12','adcl $0,%r9d','sbbq %r9,%rcx','rorl $2,%r9d','rolq $4,%r12','movslq 8(%r12),%r9','rep movsq','movw $300,%r9w','movw $300,8(%r12)','movw %r9w,(%r12)','movw (%r12),%r9w','cmpw $300,%r9w','cmpw $6,(%r12)','cmpw %r9w,8(%r12)','testw $300,%r9w','testw %r9w,8(%r12)','shrw $2,%r9w','idivq %r12','mulq %r9','movq data+8(%rip),%r9\ndata:\n.quad 0,1','movq 8+data(%rip),%r9\ndata:\n.quad 0,1']
for i,body in enumerate(cases):
 d=r/str(i);d.mkdir(exist_ok=True);p=d/'probe.s';p.write_text('.text\n.globl _start\n_start:\n'+body+'\nret\n')
 def run(cmd):subprocess.run([str(x) for x in cmd],check=True,capture_output=True)
 run([r/'driver',p,d/'native']);run(['as',p,'-o',d/'gas.o']);run(['ld',d/'gas.o','-o',d/'gas'])
 for x in ['native','gas']:run(['objcopy','--only-section=.text','-O','binary',d/x,d/(x+'.bin')])
 a=(d/'native.bin').read_bytes();b=(d/'gas.bin').read_bytes();ok=a==b
 rows.append(dict(body=body,byte_exact=ok,native=a.hex(),gas=b.hex()));print(i,ok,body)
 assert ok,rows[-1]
(r/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('PASS',len(rows))

"""Byte-compare the candidate with the pinned pre-optimization assembler.
Run from any directory: python3 check.py --repo CHECKOUT --output NEW_DIR.
No compiler source, executable or working-tree state is mutated.
"""
from pathlib import Path
import argparse,json,os,random,subprocess
p=argparse.ArgumentParser();p.add_argument('--repo',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
repo=a.repo.resolve();r=a.output.resolve();r.mkdir(parents=True,exist_ok=False)
def run(*args,**kw):return subprocess.run(list(map(str,args)),check=True,**kw)
def blob(f):return subprocess.check_output(['git','show','710a3cb:'+f],cwd=repo)
assert blob('src/hpe.rs')==(repo/'src/hpe.rs').read_bytes(),'PE writer changed: review the baseline deliberately'
(r/'base.rs').write_bytes(blob('src/hasm.rs'))
(r/'candidate.rs').write_bytes((repo/'src/hasm.rs').read_bytes());(r/'hpe.rs').write_bytes(blob('src/hpe.rs'))
(r/'compare.rs').write_text('''#[path="base.rs"]mod base;
#[path="candidate.rs"]mod safe;
#[path="hpe.rs"]mod hpe;
fn main(){let a:Vec<String>=std::env::args().collect();let list=std::fs::read_to_string(&a[1]).unwrap();let mut ok=0;let mut rejected=0;for name in list.lines(){let s=std::fs::read_to_string(name).unwrap();for pe in [false,true]{let input=if pe{format!("{}\\n.text\\ncall ExitProcess\\n",s)}else{s.clone()};let s=input;let b=if pe{base::assemble_pe(&s)}else{base::assemble(&s)};let n=if pe{safe::assemble_pe(&s)}else{safe::assemble(&s)};match(b,n){(Ok(mut b),Ok(mut n))=>{if pe{for q in [0x88..0x8c,0xd8..0xdc]{b[q.clone()].fill(0);n[q].fill(0);}}assert_eq!(b,n,"{} pe={}",name,pe);ok+=1;},(Err(b),Err(n))=>{assert_eq!(b,n,"{} error",name);rejected+=1;},_=>panic!("outcome mismatch {}",name)}}}assert_eq!(ok,328);assert_eq!(rejected,6);println!("{} byte-exact outputs; {} identical rejections",ok,rejected);}
''')
(r/'unit.rs').write_text('#[path="candidate.rs"]mod hasm;\n#[path="hpe.rs"]mod hpe;\n')
rustc=os.environ.get('RUSTC','rustc');run(rustc,'--edition=2021','-O',r/'compare.rs','-o',r/'compare');run(rustc,'--edition=2021','--test','-O',r/'unit.rs','-o',r/'unit');run(r/'unit')
fixtures=r/'fixtures';fixtures.mkdir();names=[];random.seed(7409)
def add(name,text):
 q=fixtures/(name+'.s');q.write_text(text);names.append(str(q))
for i in range(160):
 lines=['.text','.globl _start','_start:','jmp begin','back:','ret','begin:']
 for j in range(5):
  lines += [f'L{j}:','cmp $0, %rax',random.choice(['je','jne','jmp'])+' '+random.choice(['back','done','L'+str(random.randrange(j+1))]),f'.rept {random.choice([0,1,2,30,60,120,126,127,128,129,200])}','nop','.endr']
  if random.choice([True,False]):lines.append('.p2align '+str(random.choice([1,2,3,4,5,6]))+random.choice(['',',,3',',,7',',,15']))
 lines+=['done:','xor %eax, %eax','ret'];add(f'random-{i}','\n'.join(lines)+'\n')
for name,target in [('numeric','1f'),('expression','$done+0'),('constant','ALIAS')]:
 s='.text\n.globl _start\n_start:\njmp '+target+'\n.rept 180\nmov $7, %rax\n.endr\n1:\ndone:\nret\n'
 if name=='constant':s+='.set ALIAS, 0x401000\n'
 add(name,s)
add('layout-dependent','.text\n.globl _start\n_start:\nmov $target, %rax\njmp target\n.rept 200\nnop\n.endr\ntarget:\nret\n')
for i,s in enumerate(['.text\n_start:\njmp missing\n','.text\n_start:\nnonsense %rax\n','.text\n_start:\njmp 7f\n']):add('reject-'+str(i),s)
(r/'list.txt').write_text('\n'.join(names)+'\n');run(r/'compare',r/'list.txt');(r/'summary.json').write_text(json.dumps({'fixtures':len(names),'baseline':'710a3cb','targets':['ELF','PE'],'normalization':'only PE timestamp and checksum'},indent=2)+'\n')

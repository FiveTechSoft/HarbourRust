from common import *
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','rustc','output']:p.add_argument('--'+n,type=Path,required=True)
a=p.parse_args();a.output=a.output.resolve();a.output.mkdir();repo=Path(__file__).resolve().parents[2];rust=(repo/'src/hbc.rs').read_text();asm=(repo/'src/strtohex_linux.s').read_text();cases=json.loads(Path(__file__).with_name('cases.json').read_text());rows=[]
for name,old,new,case in [('wrong-high-nibble','    shr $4, %r8d','    shr $3, %r8d','relative'),('wrong-low-nibble','    and $15, %r9d','    and $7, %r9d','trailing'),('lowercase-high','    add $7, %r8d','    add $39, %r8d','utf8')]:
 w=a.output/name;w.mkdir();control=w/'control';control.mkdir();c=exact(a,control,cases[case]);assert asm.count(old)==1;ma=w/'helper.s';ma.write_text(asm.replace(old,new));src=repo/'src/hbc_strtohex_mutant.rs';src.write_text(rust.replace('include_str!("strtohex_linux.s")','include_str!('+json.dumps(str(ma))+')'))
 try:b=run([a.rustc,'--edition','2021','-C','link-arg=-s',src,'-o',w/'compiler'],w,'rust-build',60)
 finally:src.unlink()
 row=dict(name=name,compiler_build_rc=b.returncode,mutated_helper_sha256=h(ma),caught=False)
 if b.returncode==0:
  row['mutant_compiler_sha256']=h(w/'compiler');b=run([w/'compiler',control/'p.prg',w/'mutant','--target=linux'],w,'mutant-build');row['program_build_rc']=b.returncode
  if b.returncode==0:
   q=run([w/'mutant'],w,'mutant-run');row.update(run_rc=q.returncode,binary_sha256=h(w/'mutant'),caught=q.returncode==0 and not q.stderr and q.stdout!=(control/'oracle-run.stdout').read_bytes());(w/'mutant').unlink()
  (w/'compiler').unlink()
 rows.append(row);print(name,row,flush=True)
finish(a,rows,'3own Rust-valid functional StrToHex mutants. Compiler+program build0 and run0 required,then different stdout from fresh exact oracle controls. No rejection/signal/timeout/identical output counts.')
assert len(rows)==3 and all(x['compiler_build_rc']==x.get('program_build_rc')==x.get('run_rc')==0 and x['caught'] for x in rows)

#!/usr/bin/env python3
"""Assert final hb_memcheck-equivalent zero AFTER persistent cleanup/cache flush.
Own test-only assembly hook; does not change the compiler or approved programs.
Needs external as/ld (GNU + MinGW for optional PE), fresh check.py evidence.
"""
import argparse,pathlib,subprocess,os,json,hashlib
P=pathlib.Path
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--oracle-evidence',required=True);ap.add_argument('--output',required=True);ap.add_argument('--wine');a=ap.parse_args();root=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);rows=[];env=os.environ.copy();env['WINEDEBUG']='-all'
def run(cmd,w,label):
 r=subprocess.run(list(map(str,cmd)),cwd=w,env=env,capture_output=True,timeout=60)
 for k,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return r
for src in sorted((root/'programs').glob('*.prg')):
 if src.stem in ('methods','sequenced_method'): continue # object runtime retains its existing chunk/template pool; not a zero-balance assertion
 for target in ['linux']+(['windows']if a.wine else[]):
  w=out/src.stem/target;w.mkdir(parents=True);s=w/'checked.s';r=run([a.compiler,src,s,'--target='+target,'--instrument','--no-prune'],w,'emit');assert r.returncode==0,(src,r.stderr)
  text=s.read_text();anchor='    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n';assert text.count(anchor)==1
  # Flush any retained arena segments before the final whole-process balance.
  if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor)+200]: anchor += '    call hbc_arena_flush\n'
  guard='    mov hbc_mem_allocs(%rip), %rax\n    sub hbc_mem_frees(%rip), %rax\n    test %rax, %rax\n    je .Lprobe_zero\n'
  guard+=('    mov $60, %eax\n    mov $99, %edi\n    syscall\n'if target=='linux'else'    mov $99, %ecx\n    call ExitProcess\n')+'.Lprobe_zero:\n'
  s.write_text(text.replace(anchor,anchor+guard));obj=w/'checked.o';exe=w/('checked.exe'if target=='windows'else'checked')
  if target=='linux':cmds=[['as','--64','-o',obj,s],['ld','-s','-o',exe,obj]]
  else:cmds=[['x86_64-w64-mingw32-as','-o',obj,s],['x86_64-w64-mingw32-ld',obj,'-o',exe,'-e','_start','--subsystem','console','-L'+env['HBC_MINGW_LIB'],'-lkernel32']]
  for i,cmd in enumerate(cmds):r=run(cmd,w,'link'+str(i));assert r.returncode==0,(src,r.stderr)
  r=run(([a.wine]if target=='windows'else[])+[exe],w,'run');oracle=P(a.oracle_evidence)/src.stem/target;okay=r.returncode==0 and r.stdout==(oracle/'harbour-run.stdout').read_bytes()and r.stderr==(oracle/'harbour-run.stderr').read_bytes()
  rows.append({'source':src.name,'target':target,'pass':okay,'exit':r.returncode});print(('PASS 'if okay else'FAIL ')+src.stem+' '+target+' final-memcheck0',flush=True)
(out/'results.json').write_text(json.dumps({'compiler_sha256':hashlib.sha256(P(a.compiler).read_bytes()).hexdigest(),'rows':rows},indent=2));assert all(x['pass']for x in rows)

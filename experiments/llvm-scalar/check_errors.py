import pathlib,subprocess,os
os.chdir(pathlib.Path(__file__).resolve().parent);h='./run/hbc';env=os.environ
for case in ['error-inc','error-recursive','error-after-call','error-include','error-bound','error-bound-write','error-logic-and','error-logic-or','error-loopcontrol','error-loop-test','error-sequence','error-minmax']:
 for target in ['linux']+(['windows'] if env.get('M') and env.get('WINE') else []):
  for backend in ['current','llvm']:
   p=f'run/{case}-{backend}-{target}';cmd=[h,case+'.hb',p+'.ll' if backend=='llvm' else p+'.s','--target='+target]
   if backend=='llvm':cmd+=['--experimental-llvm']
   subprocess.run(cmd,check=True,stdout=subprocess.DEVNULL)
   if backend=='llvm':
    subprocess.run(['python3','llvm_aot.py',p+'.ll',p+'.o']+(['windows']if target=='windows'else[]),check=True);subprocess.run(['python3','link_runtime.py',p+'.ll.runtime.s']+(['windows']if target=='windows'else[]),check=True);asm=p+'.ll.runtime.s';rt=p+'-rt.o'
   else:asm=p+'.s';rt=p+'.o'
   a='as' if target=='linux' else env['M']+'/x86_64-w64-mingw32-as';ld='ld' if target=='linux' else env['M']+'/x86_64-w64-mingw32-ld';subprocess.run([a,'-o',rt,asm],check=True)
   exe=p+('.exe'if target=='windows'else'');objects=[p+'.o',rt]if backend=='llvm'else[rt];subprocess.run([ld,'-o',exe]+objects+(['-e','_start','--subsystem','console','-L'+env['MLIB'],'-lkernel32']if target=='windows'else[]),check=True)
   r=subprocess.run(([env['WINE'],exe] if target=='windows' else [exe]),capture_output=True);pathlib.Path(p+'.out').write_bytes(r.stdout);print(target,backend,'exit',r.returncode,'stderr',r.stderr[:70]);assert r.returncode==1;assert r.stderr==b''
  c=pathlib.Path(f'run/{case}-current-{target}.out').read_bytes();l=pathlib.Path(f'run/{case}-llvm-{target}.out').read_bytes();assert c==l,(c,l)
  print(target,'ERROR TRACE EXACT',c.decode())

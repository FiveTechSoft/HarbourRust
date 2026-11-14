#!/usr/bin/env python3
"""I3 flat-array regression gate, no private fixtures. Normal/instrument ×
enabled/runtime-off/compile-off, exact stdout/stderr/rc, plus emitted-helper
state/failure probes. Windows uses --wine and explicit MinGW --assembler,
--linker, --kernel-lib for patched-assembly probes, own PE writer otherwise.
Probe checks patch test assembly only, never production PRGs or runtime.
"""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,tempfile

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True)
    ap.add_argument('--target',choices=['linux','windows'],default='linux');ap.add_argument('--wine')
    ap.add_argument('--assembler',default='as');ap.add_argument('--linker',default='ld');ap.add_argument('--kernel-lib')
    a=ap.parse_args();repo=Path(__file__).resolve().parents[2];here=Path(__file__).resolve().parent
    compiler=Path(a.compiler).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
    win=a.target=='windows'
    if win and not(a.wine and a.kernel_lib):ap.error('windows requires --wine and --kernel-lib for probe links')
    rows=[];exe=out/('scratch.exe'if win else'scratch.x');asm=out/'scratch.s';obj=out/'scratch.o'
    def run(cmd,label,env=None):
        p=subprocess.run([str(x)for x in cmd],cwd=repo,capture_output=True,timeout=60,env=env)
        for ext,b in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(out/(label+'.'+ext)).write_bytes(b)
        return p
    def env(mode):
        e=dict(os.environ);e.pop('HB_VAS_ARRAYS',None)
        if mode=='runtime-off':e['HB_VAS_ARRAYS']='off'
        return e
    def execute(label,mode='enabled'):
        return run(([a.wine]if win else[])+[exe],label+'.run',env(mode))
    def failcode(n):
        return ('    mov $%d, %%ecx\n    call ExitProcess\n'%n if win else '    mov $%d, %%edi\n    mov $60, %%eax\n    syscall\n'%n)
    def checkzero(symbol,label):
        return f'    cmpq $0, {symbol}(%rip)\n    je .Lprobe_{label}\n'+failcode(77)+f'.Lprobe_{label}:\n'
    def assemble(text,label):
        asm.write_text(text)
        p=run([a.assembler,asm,'-o',obj],label+'.as');assert not p.returncode,(label,p.stderr)
        flags=['-e','_start','--subsystem','console','-L'+a.kernel_lib,'-lkernel32']if win else[]
        p=run([a.linker,obj,'-o',exe,*flags],label+'.ld');assert not p.returncode,(label,p.stderr)
    sources=sorted((here/'programs').glob('*.prg'))
    for src in sources:
        reference=None
        for instrument in [False,True]:
            for mode in ['compile-off','enabled','runtime-off']:
                label=f'{src.stem}-{int(instrument)}-{mode}'
                flags=['--target='+a.target]+(['--instrument']if instrument else[])+(['--no-vas-arrays']if mode=='compile-off'else[])
                p=run([compiler,src.relative_to(repo),exe,*flags],label+'.build');assert not p.returncode,(label,p.stderr)
                p=execute(label,mode);state=(p.returncode,p.stdout,p.stderr)
                if reference is None:reference=state
                assert state==reference,(label,state,reference)
                want=1 if src.stem in ['negative','overflow']else 0
                assert p.returncode==want,(label,p.returncode,p.stderr)
                rows.append({'source':str(src.relative_to(repo)),'instrument':instrument,'mode':mode,'rc':p.returncode,'stdout_sha256':hashlib.sha256(p.stdout).hexdigest()})
                if mode!='compile-off' and want==0:
                    # State check after Main, before teardown could hide leaks.
                    p=run([compiler,src.relative_to(repo),asm,*flags],label+'.probe-build');assert not p.returncode
                    text=asm.read_text();assert'hbc_vlive:'in text,(label,'not admitted')
                    check=''.join(checkzero(s,label.replace('-','_')+s)for s in ['hbc_vlive','hbc_vreserved','hbc_vcommitted']+(['hbc_vreg_n']if instrument else[]))
                    if mode=='runtime-off':check+=''.join(checkzero(s,label.replace('-','_')+s)for s in ['hbc_vreserve_calls','hbc_vcommit_calls'])
                    assemble(text.replace('    call hbc_fn_main\n','    call hbc_fn_main\n'+check,1),label+'.probe')
                    pp=execute(label+'.probe',mode);assert(pp.returncode,pp.stdout,pp.stderr)==state,(label,'state probe',pp.returncode,pp.stderr)
    # Force reserve/initial/later commit failure in emitted helpers. Grow
    # reaches page crossing after first array allocation under normal VAS.
    for fault in [1,2,3]:
        label='fault-'+str(fault);src=here/'programs/grow.prg'
        p=run([compiler,src.relative_to(repo),asm,'--instrument','--target='+a.target],label+'.build');assert not p.returncode
        text=asm.read_text();text=text.replace('    call hbc_fn_main\n',f'    movq ${fault}, hbc_vfault(%rip)\n    call hbc_fn_main\n'+''.join(checkzero(s,label.replace('-','_')+s)for s in ['hbc_vlive','hbc_vreserved','hbc_vcommitted','hbc_vreg_n']),1)
        # A dead injection must fail: after a forced transition no live VAS
        # backing may remain at the first owner free (fallback reserved=0).
        assert '@VFAIL' not in text and '@VREG' not in text
        text=text.replace('hbc_vfree:\n','hbc_vfree:\n    test %rdi, %rdi\n    je .Lprobe_fault_null\n    cmpq $0, -24(%rdi)\n    je .Lprobe_fault_null\n'+failcode(78)+'.Lprobe_fault_null:\n',1) if fault in [1,2] else text
        if fault==3:
            text=text.replace('.Lvensure_move:\n','.Lvensure_move:\n    incq hbc_test_moves(%rip)\n',1)
            check='    cmpq $0, hbc_test_moves(%rip)\n    jne .Lprobe_moved\n'+failcode(80)+'.Lprobe_moved:\n'
            text=text.replace('    call hbc_fn_main\n','    call hbc_fn_main\n'+check,1)+'\n.bss\n.align 8\nhbc_test_moves: .quad 0\n'
        assemble(text,label);p=execute(label);assert p.returncode==0 and not p.stderr,(label,p.returncode,p.stderr)
        rows.append({'fault':fault,'rc':p.returncode})
    # Force fallback OOM after first allocated/populated array. Before the
    # ordinary OOM message, assert vensure's saved old pointer/len and owner
    # pair are still intact. This probe intentionally knows the helper frame.
    for fault,src in [(4,here/'programs/exhaust.prg'),(5,here/'programs/grow.prg')]:
        label='fault-'+str(fault);p=run([compiler,src.relative_to(repo),asm,'--instrument','--target='+a.target],label+'.build');assert not p.returncode
        text=asm.read_text().replace('    call hbc_fn_main\n',f'    movq ${fault}, hbc_vfault(%rip)\n    call hbc_fn_main\n',1)
        if fault==4:
            guard='''    mov (%rbp), %rcx
    mov -8(%rcx), %rdx
    mov -24(%rcx), %rax
    cmp (%rdx), %rax
    jne .Lprobe_oom_bad
    mov -32(%rcx), %r8
    cmp 8(%rdx), %r8
    jne .Lprobe_oom_bad
    cmpq $17, 8(%rax)
    jne .Lprobe_oom_bad
    cmpq $1, hbc_vlive(%rip)
    jne .Lprobe_oom_bad
    jmp .Lprobe_oom_good
.Lprobe_oom_bad:
'''+failcode(79)+'.Lprobe_oom_good:\n'
            text=text.replace('hbc_oom:\n','hbc_oom:\n'+guard,1)
        assemble(text,label);p=execute(label);assert p.returncode==1,(label,p.returncode,p.stderr,p.stdout)
        rows.append({'fault':fault,'rc':p.returncode})
    # Overflow must fail before a new reserve/commit, with the old live
    # block still intact. Constructor+first AAdd share their initial page.
    label='overflow-no-os';src=here/'programs/overflow.prg'
    p=run([compiler,src.relative_to(repo),asm,'--instrument','--target='+a.target],label+'.build');assert not p.returncode
    text=asm.read_text();guard=''
    for symbol in ['hbc_vreserve_calls','hbc_vcommit_calls','hbc_vlive']:
        guard+=f'    cmpq $1, {symbol}(%rip)\n    jne .Lprobe_overflow_bad\n'
    guard+='    jmp .Lprobe_overflow_good\n.Lprobe_overflow_bad:\n'+failcode(81)+'.Lprobe_overflow_good:\n'
    assemble(text.replace('hbc_oom:\n','hbc_oom:\n'+guard,1),label);p=execute(label);assert p.returncode==1,(label,p.returncode)
    rows.append({'overflow_no_os':True,'rc':p.returncode})
    # I1/I2 opt-outs are independent of array admission and ownership.
    src=here/'programs/arena_coexist.prg';reference=None
    for n,flags in enumerate([[],['--no-arena'],['--no-escape-analysis'],['--no-arena','--no-escape-analysis']]):
        for arenaoff in [False,True]:
            label=f'independence-{n}-{int(arenaoff)}';p=run([compiler,src.relative_to(repo),exe,'--target='+a.target,*flags],label+'.build');assert not p.returncode
            e=env('enabled');e.pop('HB_ARENA',None)
            if arenaoff:e['HB_ARENA']='off'
            p=run(([a.wine]if win else[])+[exe],label+'.run',e);state=(p.returncode,p.stdout,p.stderr)
            if reference is None:reference=state
            assert state==reference and not p.returncode,(label,state,reference)
            rows.append({'independence':flags,'arena_runtime_off':arenaoff,'rc':p.returncode})
    # Negative controls prove gates reject known-bad emitted helpers.
    for name,source in [('nil','regrow'),('registry','grow'),('leak','grow')]:
        label='negative-control-'+name;src=here/('programs/'+source+'.prg')
        p=run([compiler,src.relative_to(repo),asm,'--instrument','--target='+a.target],label+'.build');assert not p.returncode
        text=asm.read_text()
        if name=='nil':
            changed=text.replace('    movq $1, (%rdi,%rax)\n    movq $0, 8(%rdi,%rax)\n','    nop\n',1)
        elif name=='registry':changed=text.replace('hbc_vfree:\n','hbc_vfree:\n    incq -8(%rdi)\n',1)
        else:changed=text.replace('hbc_vfree:\n','hbc_vfree:\n    ret\n',1)
        assert changed!=text;assemble(changed,label);p=execute(label)
        caught=(p.returncode==0 and b'77'in p.stdout)if name=='nil'else((p.returncode==1 and b'registry'in p.stdout.lower())if name=='registry'else(p.returncode==0 and p.stdout.endswith(b'         1')))
        assert caught,(label,p.returncode,p.stdout,p.stderr)
        rows.append({'negative_control':name,'caught':caught,'rc':p.returncode})
    (out/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
    for p in [exe,asm,obj]:p.unlink(missing_ok=True)
    print('PASS',len(sources)*6,'channel comparisons + state probes + 5 deterministic failures + overflow + 8 independence cases + 3 negative controls;',a.target)
if __name__=='__main__':main()

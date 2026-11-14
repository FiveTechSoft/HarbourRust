#!/usr/bin/env python3
"""Arena regression gate: normal/instrument, arena/no-arena/runtime-off.
Loop-body LOCAL is an admitted HarbourRust extension rejected by real Harbour
(E0004), so these are compiler regressions, not Harbour oracle positives.
Requires GNU as/ld. Optional --target windows requires --wine and uses the
compiler's internal PE writer. No marks are injected into production sources.
"""
from pathlib import Path
import argparse,json,os,subprocess,tempfile

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler',required=True)
    ap.add_argument('--output')
    ap.add_argument('--target',choices=['linux','windows'],default='linux')
    ap.add_argument('--wine')
    args=ap.parse_args();compiler=Path(args.compiler).resolve()
    if args.target=='windows' and not args.wine:ap.error('--wine required for windows')
    here=Path(__file__).resolve().parent;repo=here.parent.parent
    output=Path(args.output).resolve()if args.output else Path(tempfile.mkdtemp(prefix='hr-arena-'))
    output.mkdir(exist_ok=True,parents=True);rows=[]
    def run(cmd,label,env=None):
        p=subprocess.run([str(x)for x in cmd],cwd=repo,capture_output=True,timeout=30,env=env)
        for suffix,data in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(output/(label+'.'+suffix)).write_bytes(data)
        return p
    for src in sorted((here/'programs').glob('*.prg'))+[repo/'tests/t1618_startup_balance.prg']:
        for instrument in [False,True]:
            states=[]
            for mode in ['arena','runtimeoff','noarena']:
                label=src.stem+('-instrument'if instrument else '-normal')+'-'+mode
                exe=output/(label+('.exe'if args.target=='windows'else '.x'))
                opts=['--target='+args.target]+(['--instrument']if instrument else [])+(['--no-arena']if mode=='noarena'else [])
                if args.target=='linux' and mode=='arena':
                    # Probe-only assembly asserts all function/iteration marks
                    # are gone after Main, before exit teardown could hide a leak.
                    asm=output/(label+'.s');obj=output/(label+'.o')
                    p=run([compiler,src.relative_to(repo),asm,*opts],label+'.build')
                    assert p.returncode==0,(label,'build',p.stderr)
                    text=asm.read_text()
                    if 'hbc_arena_marksp:' in text:
                        site='    call hbc_fn_main\n'
                        assert text.count(site)==1,(label,'main call site')
                        check='    cmpq $0, hbc_arena_marksp(%rip)\n    je .Larreg_balanced\n    mov $77, %edi\n    mov $60, %eax\n    syscall\n.Larreg_balanced:\n'
                        asm.write_text(text.replace(site,site+check))
                    for cmd,step in [(['as',asm,'-o',obj],'as'),(['ld',obj,'-o',exe],'ld')]:
                        p=run(cmd,label+'.'+step);assert p.returncode==0,(label,step,p.stderr)
                else:
                    p=run([compiler,src.relative_to(repo),exe,*opts],label+'.build')
                    assert p.returncode==0,(label,'build',p.stderr)
                env=dict(os.environ)
                if mode=='runtimeoff':env['HB_ARENA']='off'
                else:env.pop('HB_ARENA',None)
                p=run(([args.wine]if args.target=='windows'else [])+[exe],label+'.run',env)
                assert p.returncode==0 and not p.stderr,(label,p.returncode,p.stderr)
                if src.stem=='t1618_startup_balance':assert p.stdout.endswith(b'.T.'),(label,p.stdout)
                states.append((p.returncode,p.stdout,p.stderr));rows.append({'source':str(src.relative_to(repo)),'instrument':instrument,'mode':mode,'rc':p.returncode,'stdout_hex':p.stdout.hex()})
            assert len(set(states))==1,(src,states)
            (output/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
    print('PASS',len(rows),'executions;',len(rows)//6,'sources; normal/instrument, arena/runtime-off/no-arena channels exact')
if __name__=='__main__':main()

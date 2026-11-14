#!/usr/bin/env python3
"""Linux real flat-array paired wall/RSS benchmark. Each source runs nine
interleaved triples (rotating order), identical stdout/stderr/rc required.
Peak RSS is wait4 from measure.c, a small native benchmark-only parent.
No performance threshold: report all raw samples, medians and spread.
"""
from pathlib import Path
import argparse,json,os,statistics,subprocess,time,hashlib

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);ap.add_argument('--pairs',type=int,default=9);a=ap.parse_args()
    repo=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True);compiler=Path(a.compiler).resolve();rows=[]
    measure=out/'measure';subprocess.run(['cc','-O2',str(Path(__file__).with_name('measure.c')),'-o',str(measure)],check=True)
    for src in sorted((Path(__file__).parent/'benchmarks').glob('*.prg')):
        exes={}
        for mode in ['enabled','runtime-off','compile-off']:
            exe=out/(mode+'.x');cmd=[str(compiler),str(src.relative_to(repo)),str(exe)]+(['--no-vas-arrays']if mode=='compile-off'else[])
            p=subprocess.run(cmd,cwd=repo,capture_output=True);assert not p.returncode,p.stderr;exes[mode]=exe
        reference=None
        for pair in range(a.pairs):
            modes=['enabled','runtime-off','compile-off'];modes=modes[pair%3:]+modes[:pair%3]
            for mode in modes:
                env=dict(os.environ);env.pop('HB_VAS_ARRAYS',None)
                if mode=='runtime-off':env['HB_VAS_ARRAYS']='off'
                stdout=out/'stdout';stderr=out/'stderr';measurement=out/'measurement.json'
                # A small native parent gives per-program wait4 RSS without
                # inheriting Python's current resident set at fork time.
                subprocess.run([str(measure),str(exes[mode]),str(stdout),str(stderr),str(measurement)],env=env,check=True,cwd=repo)
                sample=json.loads(measurement.read_text());elapsed=sample['seconds'];peak_rss=sample['peak_rss_kib'];state=(sample['rc'],stdout.read_bytes(),stderr.read_bytes())
                assert state[0]==0 and not state[2],state
                if reference is None:reference=state
                assert state==reference,(src,mode,state,reference)
                rows.append({'source':src.name,'pair':pair,'mode':mode,'seconds':elapsed,'peak_rss_kib':peak_rss,'stdout_sha256':hashlib.sha256(state[1]).hexdigest()})
        for exe in exes.values():exe.unlink()
    summary=[]
    for src in sorted({x['source']for x in rows}):
        for mode in ['enabled','runtime-off','compile-off']:
            xs=[x for x in rows if x['source']==src and x['mode']==mode];ts=[x['seconds']for x in xs];rss=[x['peak_rss_kib']for x in xs];summary.append({'source':src,'mode':mode,'samples':len(xs),'median_seconds':statistics.median(ts),'min_seconds':min(ts),'max_seconds':max(ts),'median_rss_kib':statistics.median(rss),'min_rss_kib':min(rss),'max_rss_kib':max(rss)})
    report={'compiler_sha256':hashlib.sha256(compiler.read_bytes()).hexdigest(),'summary':summary,'rows':rows};(out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(summary,indent=2))
if __name__=='__main__':main()

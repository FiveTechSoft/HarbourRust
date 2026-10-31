import subprocess, textwrap, types, contextlib, io, json, pathlib, hashlib
root=pathlib.Path('/downloads/verify-harness5835276')
src=subprocess.check_output(['git','-C','/downloads/alias-remote','show','5835276:experiments/llvm-scalar/check_regressions.py']).decode()
block=textwrap.dedent('\n'.join(src.splitlines()[69:94]))
(root/'reviewed-loop.py').write_text(block+'\n')
def r(out=b'OK',err=b'',rc=0): return subprocess.CompletedProcess(['mock'],rc,out,err)
def run(name,results,target='windows',kind='pos',expected=b'OK'):
    calls=[]
    def mock(*a,**k):
        calls.append((a,k)); return results[len(calls)-1]
    ns=dict(subprocess=types.SimpleNamespace(run=mock),target=target,env={'WINE':'mock-wine'},exe='mock-exe',want_rc=0,case='mock-case',backend='current',kind=kind,expected=expected,current_bytes=None)
    log=io.StringIO(); status='PASS'; failure=None
    try:
        with contextlib.redirect_stdout(log):exec(block,ns)
    except AssertionError as e: status='FAIL';failure=str(e)
    return dict(name=name,target=target,status=status,calls=len(calls),log=log.getvalue(),failure=failure,attempts=[dict(rc=x.returncode,stdout=x.stdout.decode(),stderr=x.stderr.decode()) for x in results[:len(calls)]])
rows=[run('wrong_stdout_debugger_then_clean',[r(b'WRONG',b'Unhandled page fault: starting debugger'),r()]),run('linux_program_stderr_then_clean',[r(err=b'application says starting debugger'),r()],target='linux'),run('windows_real_program_stderr_then_clean',[r(err=b'REAL ERROR: starting debugger'),r()]),run('wrong_rc_debugger',[r(err=b'starting debugger',rc=1),r()]),run('wrong_stdout_without_stderr',[r(b'WRONG'),r()]),run('persistent_debugger',[r(err=b'starting debugger')]*3),run('other_stderr',[r(err=b'real error'),r()]),run('final_bad_stdout',[r(err=b'starting debugger'),r(b'WRONG')])]
report=dict(commit=subprocess.check_output(['git','-C','/downloads/alias-remote','rev-parse','5835276']).decode().strip(),method='Exec exact lines70-94 with mocked subprocess results; no compiler or Wine execution',reviewed_block_sha256=hashlib.sha256(block.encode()).hexdigest(),results=rows)
(root/'mock-results.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))

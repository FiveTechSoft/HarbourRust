"""Guard the current freestanding executable linkage, not a DSO contract."""
import os,pathlib,subprocess
for case in ['corpus','arraywork']:
    ir=pathlib.Path('run',case+'.ll').read_text()
    assert '@hbc_trace_top = external dso_local global ptr' in ir
    rel=subprocess.check_output(['objdump','-r',f'run/{case}.o'],text=True)
    assert not any('hbc_trace_top' in line and 'GOT' in line for line in rel.splitlines()),rel
    if os.environ.get('M'):
        ir=pathlib.Path('run',case+'_w.ll').read_text()
        assert '@hbc_trace_top = external dso_local global ptr' in ir
        rel=subprocess.check_output([os.environ['M']+'/x86_64-w64-mingw32-objdump','-r',f'run/{case}_w.o'],text=True)
        assert not any('IMAGE_REL_AMD64_ADDR32 ' in line and '.rdata' in line for line in rel.splitlines()),rel
print('PASS direct trace-global executable linkage and target relocations')

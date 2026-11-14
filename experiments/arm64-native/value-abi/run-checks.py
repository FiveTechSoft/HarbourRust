"""Run in a copy of the entire arm64-native experiment outside the checkout."""
from pathlib import Path
import os,subprocess,sys
r=Path(__file__).resolve().parent
assert not (r.parents[2]/'.git').exists(), 'Copy the entire arm64-native experiment outside the checkout first'
os.chdir(r)
rustc=os.environ.get('RUSTC','rustc')
def run(*args):subprocess.run(list(map(str,args)),check=True)
run(rustc,'--edition=2021','-O','-C','strip=symbols','build-pair-abi.rs','-o','build-pair-abi')
run(r/'build-pair-abi')
run(rustc,'--edition=2021','-O','-C','strip=symbols','fp-env-probe.rs','-o','fp-env-probe')
run(r/'fp-env-probe')
run(rustc,'--edition=2021','--test','-O','-C','strip=symbols','../arm64-code.rs','-o','abi-code-tests')
run(r/'abi-code-tests')
run(sys.executable,'test-fp-env.py')
run(sys.executable,'test-pair-abi.py')
print('Own isolated native ABI/FP/status/trace-snapshot checks complete. Not source arithmetic admission, language exceptions, TRY/unwinding, or actual macOS execution.')

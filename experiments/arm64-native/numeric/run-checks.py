"""Run in a COPY of the parent experiment directory, not inside checkout."""
from pathlib import Path
import argparse,subprocess,os,sys,hashlib
p=argparse.ArgumentParser();p.add_argument('--repo',type=Path,required=True);a=p.parse_args()
r=Path(__file__).resolve().parent;repo=a.repo.resolve()
assert r!=repo/'experiments'/'arm64-native'/'numeric','Copy the entire arm64-native experiment outside the checkout first'
assert hashlib.sha256((repo/'src'/'hbc.rs').read_bytes()).hexdigest()=='6408c8e7845d0e461aa5f9fdec7b7cd99839b6df54f48c0387ae56c4fe1f487d','Frontend helper changed; rebase the x86-reference extraction deliberately'
os.environ['HARBOURRUST_REPO']=str(repo);os.chdir(r);rustc=os.environ.get('RUSTC','rustc')
def run(*args):subprocess.run(list(map(str,args)),check=True)
run(rustc,'--edition=2021','-O','-C','strip=symbols','build-kernels.rs','-o','build-kernels')
run(r/'build-kernels')
run(rustc,'--edition=2021','-O','-C','strip=symbols','decimal-model.rs','-o','decimal-model')
run(rustc,'--edition=2021','--test','-O','-C','strip=symbols','../arm64-code.rs','-o','numeric-code-tests')
run(r/'numeric-code-tests')
for name in ['numeric','mixed-numeric','metadata','value-format','decimal-model','decimal-image','decimal-compose','decimal-mixed','decimal-x86']:
 run(sys.executable,'test-'+name+'.py')
if os.environ.get('LLVM_SHARED_LIBRARY'):run(sys.executable,'check-encodings.py')
print('Numeric kernels, value-format glue and formatter controls complete. No AST arithmetic admission, actual Mac execution, language exception or trace runtime was tested.')

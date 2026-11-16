#!/usr/bin/env python3
"""Native Windows threads differential gate.

Same probes and comparison as check_oracle.py (Linux): every probe is built
by real Harbour 3.2 (mingw64, MT VM, GTCGI) and by hbc --target=windows from
the same source; both run and stdout, stderr and exit code compare byte for
byte (stdout CR LF normalised to LF on both sides). mt20 is the declared
prefix oracle (Harbour's BASE/1302 destructor artifact).

usage: check_oracle_windows.py --compiler hbc.exe --harbour <hb dir> --mingw-bin <dir>
"""
from pathlib import Path
import argparse, subprocess, sys, tempfile, importlib.util

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("lin", HERE / "check_oracle.py")
lin = importlib.util.module_from_spec(spec)
spec.loader.exec_module(lin)

LIBS = ("-Wl,--start-group -lhbextern -lhbdebug -lhbvmmt -lhbrtl -lhblang "
        "-lhbcpage -lgtcgi -lgtstd -lgtwin -lhbrdd -lhbuddall -lhbusrrdd -lrddntx "
        "-lrddcdx -lrddnsx -lrddfpt -lhbrdd -lhbhsx -lhbsix -lhbmacro -lhbcplr -lhbpp "
        "-lhbcommon -lhbmainstd -lwinmm -lkernel32 -luser32 -lgdi32 -ladvapi32 "
        "-lws2_32 -liphlpapi -lwinspool -lcomctl32 -lcomdlg32 -lshell32 -luuid "
        "-lole32 -loleaut32 -lmpr -lmapi32 -limm32 -lmsimg32 -lwininet -lhbpcre "
        "-lhbzlib -Wl,--end-group").split()


def run(cmd, cwd, timeout=60):
    try:
        p = subprocess.run([str(c) for c in cmd], cwd=cwd, capture_output=True, timeout=timeout)
        return p.returncode, p.stdout.replace(b"\r\n", b"\n"), p.stderr.replace(b"\r\n", b"\n")
    except subprocess.TimeoutExpired as e:
        return "timeout", (e.stdout or b"").replace(b"\r\n", b"\n"), (e.stderr or b"")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--compiler", required=True)
    ap.add_argument("--harbour", required=True)
    ap.add_argument("--mingw-bin", required=True)
    ap.add_argument("--only", nargs="*")
    ap.add_argument("--programs", help="probe directory (every .prg; default: this gate's list)")
    a = ap.parse_args()
    hb = Path(a.harbour)
    gcc = Path(a.mingw_bin) / "gcc.exe"
    pdir = Path(a.programs).resolve() if a.programs else HERE / "programs"
    names = a.only or ((sorted(f.stem for f in pdir.glob("*.prg"))) if a.programs else (lin.POSITIVE + lin.PREFIX_ORACLE))
    work = Path(tempfile.mkdtemp(prefix="thwin_"))
    ok = 0
    for n in names:
        src = pdir / (n + ".prg")
        hsrc = work / (n + "_hb.prg")
        hsrc.write_bytes(src.read_bytes() + b"\nREQUEST HB_GT_CGI_DEFAULT\n")
        rc, o, e = run([hb / "bin/harbour.exe", "-n2", "-q0", hsrc.name, "-o./", "-i" + str(hb / "include")], work)
        assert rc == 0, (n, o, e)
        rc, o, e = run([gcc, "-c", "-O2", n + "_hb.c", "-I" + str(hb / "include"), "-o", n + "_hb.o"], work)
        assert rc == 0, (n, e)
        rc, o, e = run([gcc, n + "_hb.o", "-mconsole", *LIBS, "-o", n + "_hb.exe", "-L" + str(hb / "lib/win/mingw64")], work)
        assert rc == 0, (n, e)
        rc, o, e = run([a.compiler, src, work / (n + "_rs.exe"), "--target=windows"], work)
        if rc != 0:
            print(f"FAIL {n}: hbc rejected: {e.decode(errors='replace').strip()}")
            continue
        h = run([work / (n + "_hb.exe")], work, timeout=180)
        r = run([work / (n + "_rs.exe")], work, timeout=20)
        if n in lin.PREFIX_ORACLE:
            same = r[0] == 0 and h[1].startswith(r[1])
        else:
            same = h == r
        if same:
            ok += 1
            print(f"ok   {n}")
        else:
            print(f"FAIL {n}\n  harbour {h!r}\n  hbc     {r!r}")
    print(f"{ok}/{len(names)} identical  (work dir {work})")
    sys.exit(0 if ok == len(names) else 1)


if __name__ == "__main__":
    main()

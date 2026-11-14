#!/usr/bin/env python3
"""Linux classes/objects differential gate. Requires an external real Harbour hbmk2.
Every positive probe is compiled by real Harbour and by HarbourRust from the same
source; both executables run and their stdout/stderr are compared byte for byte.
Declared-limit probes must run under Harbour and be a named compile-time
rejection under HarbourRust. Named negatives must be named rejections, never
panics. No network, installed-runtime changes, or repository fixture mutation.
"""
from pathlib import Path
import argparse, subprocess, sys, tempfile

POSITIVE = ["p01_defaults","p02_nil_default","p04_method_ret","p05_method_over_data",
    "p09","p10_init_per_inst","p10b_init_rerun","p11_sharing_assign","p12_sharing_param",
    "p13_virtual","p14_inherit_data","p15_inherit_method","p16","p17_arity","p18_identity",
    "p22_nodata","p23_print_obj","p24_param_virtual","p25_stress","p_sep","neg4",
    "t1","t1b","t2","t3","t4"]
DECLARED_LIMITS = {
    "p03_readwrite":     "compound assignment `+=` is outside the supported expression subset",
    "p07_self_chain":    "compound assignment `+=` is outside the supported expression subset",
    "p21_multi_inherit": "multiple inheritance is a named compile-time rejection",
}
NEGATIVES = ["neg1","neg2","neg3","neg5","neg6","neg7","neg8","neg9","neg10",
    "neg11","neg12","neg13","neg14_ambig_member"]

def run(cmd, cwd, label, timeout=120):
    p = subprocess.run([str(v) for v in cmd], cwd=cwd, capture_output=True, timeout=timeout)
    for suffix, data in [("stdout", p.stdout), ("stderr", p.stderr),
                         ("rc", str(p.returncode).encode())]:
        (cwd / (label + "." + suffix)).write_bytes(data)
    return p

def hbc_compile(hbc, src, work, tag):
    asm = work / (tag + ".s")
    p = run([hbc, src, asm], work, tag + ".hbc")
    if p.returncode != 0:
        return None, p
    run(["as", "-o", work / (tag + ".o"), asm], work, tag + ".as")
    p2 = run(["ld", "-o", work / (tag + ".x"), work / (tag + ".o")], work, tag + ".ld")
    if p2.returncode != 0:
        return None, p2
    return work / (tag + ".x"), p

def harbour_compile(hbmk2, src, work, tag):
    out = work / (tag + "_hb")
    p = run([hbmk2, "-quiet", "-gtstd", "-w0", "-o" + str(out), src], work, tag + ".hbmk2", timeout=300)
    if p.returncode != 0 or not out.exists():
        return None
    return out

def named_rejection(p):
    err = p.stderr.decode("utf-8", "replace")
    if p.returncode == 0:
        return None
    if "panic" in err.lower() or "unwrap" in err.lower():
        return None
    return err

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--compiler", required=True, help="HarbourRust hbc executable")
    ap.add_argument("--hbmk2", required=True, help="external official Harbour hbmk2")
    ap.add_argument("--output", help="new directory for full evidence; defaults to a temporary directory")
    args = ap.parse_args()
    hbc = Path(args.compiler).resolve()
    hbmk2 = Path(args.hbmk2).resolve()
    inputs = Path(__file__).resolve().parent / "programs"
    if args.output:
        output = Path(args.output).resolve()
        output.mkdir(parents=True, exist_ok=False)
    else:
        output = Path(tempfile.mkdtemp(prefix="harbourrust-classes-"))
    print("Evidence:", output, flush=True)

    passed, failed = [], []

    for name in POSITIVE:
        src = inputs / (name + ".prg")
        work = output / name
        work.mkdir()
        hb = harbour_compile(hbmk2, src, work, name)
        if hb is None:
            failed.append((name, "Harbour build failed")); continue
        mine, _ = hbc_compile(hbc, src, work, name)
        if mine is None:
            failed.append((name, "hbc compile/link failed")); continue
        rhb = run([hb], work, name + ".run-harbour")
        rme = run([mine], work, name + ".run-hbc")
        if rhb.stdout == rme.stdout and rhb.stderr == rme.stderr:
            passed.append(name)
        else:
            failed.append((name, "output differs from Harbour"))

    for name, why in DECLARED_LIMITS.items():
        src = inputs / (name + ".prg")
        work = output / name
        work.mkdir()
        hb = harbour_compile(hbmk2, src, work, name)
        if hb is None:
            failed.append((name, "Harbour build failed; limit probe must run under Harbour")); continue
        rhb = run([hb], work, name + ".run-harbour")
        if rhb.returncode != 0:
            failed.append((name, "Harbour run failed; limit probe must run under Harbour")); continue
        _, p = hbc_compile(hbc, src, work, name)
        err = named_rejection(p)
        if err is None:
            failed.append((name, "expected a named hbc rejection: " + why)); continue
        (work / (name + ".limit")).write_text("DECLARED LIMIT: " + why + "\n" + err)
        passed.append(name)

    for name in NEGATIVES:
        src = inputs / (name + ".prg")
        work = output / name
        work.mkdir()
        _, p = hbc_compile(hbc, src, work, name)
        if named_rejection(p) is None:
            failed.append((name, "expected a named hbc rejection, got success or panic"))
        else:
            passed.append(name)

    total = len(POSITIVE) + len(DECLARED_LIMITS) + len(NEGATIVES)
    print(f"classes gate: {len(passed)}/{total} pass "
          f"({len(POSITIVE)} differential, {len(DECLARED_LIMITS)} declared limits, "
          f"{len(NEGATIVES)} named negatives)")
    for name, why in failed:
        print("FAIL", name, "-", why)
    if failed:
        sys.exit(1)

if __name__ == "__main__":
    main()

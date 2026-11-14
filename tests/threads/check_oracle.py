#!/usr/bin/env python3
"""Linux threads differential gate (F1 threads, F2 mutexes, F4 SubscribeNow + threadOnce). Requires an external real Harbour hbmk2.
Every probe is compiled by real Harbour (with -mt) and by HarbourRust from the
same source; both executables run and their stdout/stderr are compared byte for
byte. Probes are written so Harbour itself is deterministic: a thread's output
racing Main's output would be a declared F1 nondeterminism (interleaved QOut),
so probes that print from a worker print nothing from Main until after the join.
No network, installed-runtime changes, or repository fixture mutation.
"""
from pathlib import Path
import argparse, subprocess, sys, tempfile

POSITIVE = ["th01b_start_join", "th03b_args", "th04b_wait", "th05b_join_ret",
    "th11b_wait_to", "th12b_detach", "th18b_exitwait", "th25b_objreturn",
    "th27b_ptrcmp", "th28b_join2",
    "mt01_type", "mt02_lockret", "mt03_recursive", "mt04_race_fixed",
    "mt05_notify_val", "mt06_notify_none", "mt07_notify_one", "mt08_notifyall",
    "mt09_lock_to", "mt10_muteval", "mt11_evalret", "mt12_notify_fifo",
    "mt13_notifyall_late", "mt14_notify_consumed_once",
    # F3: subscribe regression oracles (mt15-mt19), literal threadStart
    # argument, hb_threadID/hb_threadIsMain, hb_mutexQueueInfo.
    "mt15_sub_selfheld", "mt16_sub_otherholds", "mt17_sub_leaves_unlocked",
    "mt18_queueinfo", "mt19_sub_acquire_timeout",
    "th29b_literal", "th30b_tid",
    # F4: hb_mutexSubscribeNow (flush + future-only wait, delivery by
    # notify and by notifyAll) and hb_threadOnce (basic/state,
    # concurrent blocking, 1-arg claim).
    "mt21_subnow_future", "mt22_subnow_bcast",
    "ton01_once_basic", "ton02_once_concurrent", "ton03_once_1arg"]

# F4 special case: mt20 proves SubscribeNow's FLUSH (a queued "a" must
# NOT be delivered; a future "b" must). Any flushed queued value (or an
# expired SubscribeNow) poisons Harbour's mutex destructor: at exit
# Harbour shows BASE/1302 "Object destructor failure", an interactive
# box that hangs headless (declared divergence family; HarbourRust
# exits cleanly). The oracle is therefore a stdout-PREFIX comparison:
# Harbour runs under `timeout` and its stdout must start with
# HarbourRust's complete output, which must end rc=0.
PREFIX_ORACLE = ["mt20_subnow_flush"]

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
    p = run([hbmk2, "-gtstd", "-w0", "-mt", "-o" + str(out), src], work, tag + ".hbmk2", timeout=300)
    if p.returncode != 0 or not out.exists():
        return None
    return out

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
        output = Path(tempfile.mkdtemp(prefix="harbourrust-threads-"))
    print("Evidence:", output, flush=True)

    passed, failed = [], []

    for name in POSITIVE + PREFIX_ORACLE:
        src = inputs / (name + ".prg")
        work = output / name
        work.mkdir()
        hb = harbour_compile(hbmk2, src, work, name)
        if hb is None:
            failed.append((name, "Harbour build failed")); continue
        mine, _ = hbc_compile(hbc, src, work, name)
        if mine is None:
            failed.append((name, "hbc compile/link failed")); continue
        if name in PREFIX_ORACLE:
            rhb = run(["timeout", "15", hb], work, name + ".run-harbour", timeout=30)
            rme = run([mine], work, name + ".run-hbc", timeout=180)
            if (rme.returncode == 0 and rme.stderr == b""
                    and rhb.returncode == 124 and rhb.stdout.startswith(rme.stdout)
                    and len(rme.stdout) > 0):
                passed.append(name)
            else:
                failed.append((name, "prefix oracle mismatch (expected Harbour rc=124 + stdout prefix, HarbourRust rc=0)"))
            continue
        rhb = run([hb], work, name + ".run-harbour", timeout=180)
        rme = run([mine], work, name + ".run-hbc", timeout=180)
        if rhb.stdout == rme.stdout and rhb.stderr == rme.stderr:
            passed.append(name)
        else:
            failed.append((name, "output differs from Harbour"))

    total = len(POSITIVE) + len(PREFIX_ORACLE)
    for name, why in failed:
        print("FAIL", name, "-", why)
    print(f"threads gate: {len(passed)}/{total} pass ({total} differential)")
    sys.exit(0 if not failed else 1)

if __name__ == "__main__":
    main()

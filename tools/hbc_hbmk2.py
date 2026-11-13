#!/usr/bin/env python3
"""MIT frontend: one Harbour source -> hbc/as objects -> external official hbmk2.

Not an hbmk2 replacement. Linux x86-64 only. No Harbour implementation is copied.
"""
import argparse
import json
import os
import platform
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def tool(value):
    found = shutil.which(value)
    if found is None:
        raise ValueError(f"tool not found or not executable: {value}")
    return str(Path(found).resolve())


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("sources", nargs="+", help="one .prg/.prg, plus optional .c/.o files")
    p.add_argument("-o", "--output", required=True, help="native output executable")
    p.add_argument("-I", "--include", action="append", default=[])
    p.add_argument("--hbc", default=str(ROOT / "hbc"))
    p.add_argument("--hbmk2", default="hbmk2", help="external official hbmk2 executable")
    p.add_argument("--assembler", default="as")
    p.add_argument("--cc", default="gcc", help="C compiler for freestanding extensions")
    p.add_argument("--bridge", action="store_true", help="include scalar Extend bridge (automatic with .c)")
    p.add_argument("--instrument", action="store_true")
    p.add_argument("--work-dir", help="new directory for objects, project and logs; must not exist")
    a = p.parse_args(argv)
    work = None
    keep = bool(a.work_dir)
    try:
        if sys.platform != "linux" or platform.machine().lower() not in {"x86_64", "amd64"}:
            raise ValueError("this adapter currently supports Linux x86-64 hosts only")
        files = [Path(s).resolve(strict=True) for s in a.sources]
        if any(not s.is_file() for s in files):
            raise ValueError("all sources must be regular files")
        if any(s.suffix.lower() not in {".prg", ".prg", ".c", ".o"} for s in files):
            raise ValueError("only .prg/.prg, .c and .o inputs are supported; .hbp/.hbc options are not imported")
        harbour = [s for s in files if s.suffix.lower() in {".prg", ".prg"}]
        if len(harbour) != 1:
            raise ValueError("exactly one Harbour module is supported: current hbc embeds its own entry/runtime")
        output = Path(a.output).absolute()
        if output in files or output.resolve() in files:
            raise ValueError("output must not replace an input")
        if not output.parent.is_dir():
            raise ValueError("output parent directory does not exist")
        include = [str(Path(s).resolve(strict=True)) for s in a.include]
        if any(not Path(s).is_dir() for s in include):
            raise ValueError("include paths must be directories")
        hbc, assembler, hbmk2 = tool(a.hbc), tool(a.assembler), tool(a.hbmk2)
        cfiles = [s for s in files if s.suffix.lower() == ".c"]
        bridge = a.bridge or bool(cfiles)
        cc = tool(a.cc) if bridge else None
        if a.work_dir:
            work = Path(a.work_dir).absolute()
            work.mkdir(parents=False, exist_ok=False)
        else:
            work = Path(tempfile.mkdtemp(prefix="hbc-hbmk2-", dir=output.parent))
        commands = []

        def run(cmd, stage):
            commands.append({"stage": stage, "argv": [str(x) for x in cmd]})
            (work / "commands.json").write_text(json.dumps(commands, indent=2) + "\n")
            r = subprocess.run(cmd, cwd=work, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            (work / (stage + ".stdout")).write_bytes(r.stdout)
            (work / (stage + ".stderr")).write_bytes(r.stderr)
            if r.returncode:
                sys.stderr.buffer.write(r.stdout + r.stderr)
                raise ValueError(f"{stage} failed (exit {r.returncode}); output not replaced")

        # Passing the original source directory also preserves sibling #includes.
        cmd = [hbc, str(harbour[0]), "program.s", "--target=linux"]
        if a.instrument:
            cmd.append("--instrument")
        for inc in [str(harbour[0].parent)] + include:
            cmd.extend(["-I", inc])
        run(cmd, "hbc")
        run([assembler, "program.s", "-o", "program.o"], "assemble")
        objects = ["program.o"]
        for i, source in enumerate(s for s in files if s.suffix.lower() in {".c", ".o"}):
            obj = f"extension{i}.o"
            if source.suffix.lower() == ".o":
                shutil.copyfile(source, work / obj)
            else:
                cmd = [cc, "-c", "-O2", "-ffreestanding", "-fno-stack-protector",
                       "-I", str(ROOT / "extend")]
                for inc in include:
                    cmd.extend(["-I", inc])
                cmd.extend([str(source), "-o", obj])
                run(cmd, f"c{i}")
            objects.append(obj)
        if bridge:
            run([cc, "-c", "-O2", "-ffreestanding", "-fno-stack-protector", "-I",
                 str(ROOT / "extend"), str(ROOT / "extend/hbhbr.c"), "-o", "bridge.o"], "bridge")
            objects.append("bridge.o")
        # Only generated filenames enter the project. No source can accidentally
        # become a first-argument .prg script, and path quoting is not a shell job.
        project = objects + ["-nohblib", "-ldflag=-nostdlib", "-ldflag=-no-pie",
                             "-ldflag=-Wl,-e,_start", "-oresult"]
        (work / "native.hbp").write_text("\n".join(project) + "\n")
        run([hbmk2, "native.hbp", "-trace"], "hbmk2")
        result = work / "result"
        if not result.is_file() or result.read_bytes()[:5] != b"\x7fELF\x02":
            raise ValueError("hbmk2 did not produce a 64-bit ELF executable")
        if not os.access(result, os.X_OK):
            raise ValueError("hbmk2 output is not executable")
        # Same filesystem: mkdtemp defaults beside output. Explicit work-dir may
        # be elsewhere, so stage a copy beside output before an atomic replace.
        fd, staged = tempfile.mkstemp(prefix=".hbc-result-", dir=output.parent)
        os.close(fd)
        try:
            shutil.copy2(result, staged)
            os.replace(staged, output)
        finally:
            if os.path.exists(staged):
                os.unlink(staged)
        print(f"Built {output}")
        if keep:
            print(f"Build evidence: {work}")
        return 0
    except (OSError, ValueError) as e:
        print(f"error: {e}", file=sys.stderr)
        if work is not None and keep:
            print(f"Build evidence: {work}", file=sys.stderr)
        return 1
    finally:
        if work is not None and not keep:
            shutil.rmtree(work)


if __name__ == "__main__":
    sys.exit(main())

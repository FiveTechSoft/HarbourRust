# t528_hget: preserved artifacts of battery run 2 (the second failure)

- t528_hget.linux.bin / .exe: the exact binaries the battery built and
  ran in the failed run. The linux binary, re-executed after the run,
  produced output matching the manifest expectation.
- t528_hget.linux.s / t528_hget.windows.s: the generated assembly.
- sha256sums.txt: hashes of these files. hashes.txt (parent dir):
  compiler binary and git tree.
- Manifest expectation: `\n         1\n         2\n         1\nNIL\nNIL`.
- The harness does not retain failing-run stdout; the actual bytes of
  the two failed executions are not recoverable from this repository.
  Everything else needed for a bounded diagnosis is here.

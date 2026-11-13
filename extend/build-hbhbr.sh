#!/bin/sh
# Build the Extend-System bridge runtime (docs/EXTEND-BRIDGE.md).
set -e
cd "$(dirname "$0")"
${CC:-gcc} -c -O2 -ffreestanding -fno-stack-protector -I. hbhbr.c -o hbhbr.o
echo "hbhbr.o built"

#!/bin/bash
set -euo pipefail
# Usage: ./scripts/run_asm_test.sh tests_asm/name.asm   (expects tests_asm/name.expected)
asm=$1
exp="${asm%.asm}.expected"
[ -f test/input/test0.in ] || (cd test && python3 generator.py 1 --seed 1)
./scripts/encode_assembly.sh "$asm" test/program.hex
./scripts/build.sh > /dev/null
rm -f test_result.out
timeout 20 vvp convolution_testbench +X=0 > /dev/null || { echo "TIMEOUT/ERROR: $asm"; exit 1; }
head -n "$(wc -l < "$exp")" test_result.out > /tmp/got.out
if diff /tmp/got.out "$exp"; then echo "PASS: $asm"; else echo "FAIL: $asm (< got, > expected)"; fi

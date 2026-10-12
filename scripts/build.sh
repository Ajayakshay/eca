#!/bin/bash
set -euo pipefail

# Must be run from the project root.
OUT="./convolution_testbench"

# Core RTL files
CORE_FILES=(
    source/core.v
    source/alu.v
    source/decoder.v
    source/regfile.v
    source/forwarding_unit.v
    source/hazard_unit.v
)

# Testbench infrastructure (RAM, ROM) and the convolution testbench
TB_FILES=(
    test/source/ram.v
    test/source/rom.v
    test/testbench.v
)

iverilog -g2012 -s tb -o "$OUT" "${CORE_FILES[@]}" "${TB_FILES[@]}"
echo "Built: $OUT"

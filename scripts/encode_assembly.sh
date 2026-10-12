#!/bin/bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <input.asm> <output.hex>" >&2
  exit 1
fi

asm_path="$1"
out_path="$2"

if [[ ! -f "$asm_path" ]]; then
  echo "Input .asm not found: $asm_path" >&2
  exit 1
fi

# Auto-detect toolchain prefix: prefer xPack, fall back to apt/system GNU
find_toolchain() {
    local xpack_bin
    xpack_bin=$(ls -d "$HOME/.local/xpack-riscv/xpack-riscv-none-elf-gcc-"*/bin 2>/dev/null | head -1)
    if [[ -n "$xpack_bin" && -x "$xpack_bin/riscv-none-elf-as" ]]; then
        echo "riscv-none-elf"
        export PATH="$xpack_bin:$PATH"
        return
    fi
    if command -v riscv-none-elf-as &>/dev/null; then
        echo "riscv-none-elf"
        return
    fi
    if command -v riscv64-unknown-elf-as &>/dev/null; then
        echo "riscv64-unknown-elf"
        return
    fi
    echo "" # not found
}

PREFIX=$(find_toolchain)
if [[ -z "$PREFIX" ]]; then
  echo "ERROR: No RISC-V toolchain found." >&2
  echo "  Install with:  sudo apt install binutils-riscv64-unknown-elf" >&2
  echo "  Or xPack:      https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases" >&2
  exit 1
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

conv_o="$workdir/out.o"
conv_bin="$workdir/out.bin"

"${PREFIX}-as" -march=rv32im -mabi=ilp32 -o "$conv_o" "$asm_path"
"${PREFIX}-objcopy" -O binary -j .text "$conv_o" "$conv_bin"

od -An -tx4 -w4 -v "$conv_bin" | sed 's/^ *//' > "$out_path"

echo "Encoded: $asm_path -> $out_path ($(wc -l < "$out_path") instructions)"

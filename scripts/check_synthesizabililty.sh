#!/bin/bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <top_module>"
  exit 1
fi

TOP="$1"

WORKDIR="${WORKDIR:-./.yosys_check}"
mkdir -p "$WORKDIR"
LOG="$WORKDIR/yosys.log"

# Collect both .v and .sv
mapfile -t FILES < <(find "$(pwd)/source" -type f \( -name "*.v" -o -name "*.sv" \) | sort)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "FAIL: No Verilog/SystemVerilog files found under $(pwd)/source"
  exit 2
fi

: > "$LOG"

# If any .sv is present, use -sv (safe even if some are .v in most Yosys builds)
USE_SV=false
for f in "${FILES[@]}"; do
  [[ "$f" == *.sv ]] && USE_SV=true && break
done

READ="read_verilog"
if $USE_SV; then
  READ="read_verilog -sv"
fi

# Build one read_verilog call with all files
READ_CMD="$READ"
for f in "${FILES[@]}"; do
  READ_CMD+=" \"${f}\""
done

CMD="${READ_CMD}; \
hierarchy -top ${TOP}; \
proc; opt; check; \
synth -top ${TOP}; \
opt; opt_clean; \
stat;"

: > "$LOG"

if yosys -q -l "$LOG" -p "$CMD" ; then
  echo "OK: '${TOP}' passes Yosys parse/elab/compatibility checks."
  exit 0
else
  echo "FAIL: Yosys reported an error while checking '${TOP}'."
  echo "---- Yosys log tail ----"
  tail -n 120 "$LOG" || true
  exit 2
fi

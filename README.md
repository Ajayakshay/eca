\# CustomCore: pipelined RISC-V core for 2D convolution



Embedded Computer Architectures I project. A 5-stage pipelined RISC-V core (`CustomCore`, Verilog) that runs a 13×13 by 2×2 convolution program and is checked by the provided testbench.



> \*\*Status: under development.\*\* See \[Project status](#project-status) for what is done and what is left. Update the checkboxes as you go.



\---



\## Project status



Legend: `\[x]` done, `\[ ]` to do. Items marked \*(unverified)\* are written but have not been run yet.



\### Baseline core

\- \[x] 5-stage pipeline (IF, ID, EX, MEM, WB) in `source/core.v`

\- \[x] Modules split out: `decoder`, `alu`, `regfile`, `forwarding\_unit`, `hazard\_unit`

\- \[x] Data forwarding (EX/MEM and WB to EX) and register-file write-through

\- \[x] Load-use hazard stall (1 cycle)

\- \[x] Branch and `jalr` resolved in EX with a 2-instruction flush

\- \[x] `ret` to address 0 raises `core\_finish\_signal`

\- \[x] Instructions used by `convolution.asm`: `addi, add, mul, slli, lw, sw, blt, ret`

\- \[x] Build, test and encode scripts in `scripts/`

\- \[ ] First full run: `./scripts/run\_tests.sh 10` gives 10/10 \*(unverified)\*

\- \[ ] Commit and tag the known-good state (`baseline-v0`)



\### Instruction coverage fixes

\- \[ ] `beq`, `bne`, `bge` (and `bltu`, `bgeu`): decode `funct3` instead of treating every branch as `blt`

\- \[ ] `jal` / `j`: J-type decode, jump in EX, link value to `rd`

\- \[ ] Pseudo-ops `ble`, `bgt`, `bleu`, `bgtu` checked through the assembler (no hardware needed)

\- \[ ] Optional hardening: check `funct3`/`funct7` in the decoder, add `sub` and `lui`



\### Verification

\- \[ ] Per-instruction tests (each branch taken and not taken, `jal`, `ret` with non-zero `ra`, `lw`/`sw` offsets, `mul` signed and overflow, `slli`)

\- \[ ] Hazard tests (load-use, back-to-back dependences, branch right after an ALU op, forwarding from EX/MEM and WB)

\- \[ ] Optional: small Python RV32 reference simulator to compare against the RTL

\- \[ ] Re-run the convolution suite after every RTL change



\### Synthesis

\- \[ ] `scripts/check\_synthesizabililty.sh CustomCore` exits 0 \*(unverified)\*

\- \[ ] `grep -i warning .yosys\_check/yosys.log` shows no warnings



\### Measurement and optimization

\- \[ ] Cycle counter added in a private copy of the testbench (the graded testbench stays unmodified)

\- \[ ] Baseline cycle count for the convolution recorded: `\_\_\_\_` cycles

\- \[ ] Optimization chosen: `\_\_\_\_`

\- \[ ] Optimization implemented and still passing all convolution tests

\- \[ ] Optimized cycle count recorded: `\_\_\_\_` cycles



\---



\## Repository layout



```

source/

&#x20; core.v              top module CustomCore: pipeline registers, stages, control glue

&#x20; decoder.v           instruction decode: control signals and immediates

&#x20; alu.v               ADD, SLL, MUL

&#x20; regfile.v           32x32 register file, x0 = 0, async read with write-through

&#x20; forwarding\_unit.v   EX/MEM and WB forwarding select

&#x20; hazard\_unit.v       load-use stall detection

test/

&#x20; testbench.v         provided testbench (do not modify; graded version is the original)

&#x20; source/ram.v, rom.v data and program memory models used by the testbench

&#x20; convolution.asm     the convolution program

&#x20; generator.py        random test and expected-output generator

scripts/

&#x20; encode\_assembly.sh  .asm to hex

&#x20; build.sh            compile RTL + testbench with iverilog

&#x20; run\_tests.sh        encode, generate, build, simulate and diff N tests

&#x20; check\_synthesizabililty.sh   yosys check

```



\## Architecture summary



\- \*\*Pipeline:\*\* IF, ID, EX, MEM, WB. The ROM reads asynchronously. The RAM has a 1-cycle read latency, so load data is consumed in WB.

\- \*\*Forwarding:\*\* results are forwarded from EX/MEM and WB into EX. The register file also bypasses WB to ID in the same cycle.

\- \*\*Load-use hazard:\*\* one stall cycle, then WB forwarding.

\- \*\*Control flow:\*\* branches and `jalr` are resolved in EX and flush IF/ID and ID/EX (2-cycle penalty).

\- \*\*Finish:\*\* a `jalr` whose target is address 0 (`ret` with `ra = 0`) sets `core\_finish\_signal`, after which the PC and memory writes stop.



\## Supported instructions



| Group | Implemented | Planned |

|---|---|---|

| Memory | `lw`, `sw` | |

| Arithmetic | `add`, `mul` | `sub` (optional) |

| Immediate | `addi`, `slli` | `lui` (optional) |

| Branch | `blt` (all branches currently decode as `blt`) | `beq`, `bne`, `bge`, `bltu`, `bgeu` |

| Jump | `jalr` / `ret` | `jal` / `j` |



The assembler turns `ble`, `bgt`, `bleu`, `bgtu` into the real branches above, so they need no extra hardware.



\## Memory map used by the convolution program



| Words | Contents |

|---|---|

| 0 to 168 | 13×13 input matrix (row-major) |

| 169 to 172 | 2×2 kernel |

| 173 to 293 | 11×11 output |



\## Prerequisites



Ubuntu / WSL:



```bash

sudo apt update

sudo apt install iverilog gtkwave yosys binutils-riscv64-unknown-elf gcc-riscv64-unknown-elf

```



macOS: `brew install icarus-verilog gtkwave yosys`, plus a RISC-V toolchain such as xPack.



\## Build and run



Run everything from the project root.



```bash

chmod +x scripts/\*.sh

./scripts/run\_tests.sh 10        # expect: Passed 10 / 10

```



Run and debug a single test:



```bash

vvp convolution\_testbench +X=0

diff test\_result.out test/output/test0.out

gtkwave wave.vcd

```



\## Synthesizability check



```bash

scripts/check\_synthesizabililty.sh CustomCore

grep -i warning .yosys\_check/yosys.log

```



\## Known limitations



\- Every branch currently behaves as `blt` until the `funct3` fix lands.

\- `jal` is decoded as a no-op until it is implemented.

\- No `sub`, `lui`, byte or halfword memory access.

\- Only the convolution program has been tested so far.



\## Team



\- Group: `\_\_`

\- Members: `\_\_`, `\_\_`, `\_\_`



\## Acknowledgements



AI assistance used during development: `\_\_` (describe what it was used for, as the course requires).


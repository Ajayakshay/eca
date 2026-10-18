    addi a0, x0, 692
    addi t0, x0, 1
    addi t2, x0, -1

    # 1: bge signed, 1 >= -1 taken -> 0
    addi t4, x0, 0
    bge  t0, t2, d1
    addi t4, x0, 99
    addi t4, x0, 98
d1: sw   t4, 0(a0)

    # 2: bge signed, -1 >= 1 false, not taken -> 1
    addi t4, x0, 0
    bge  t2, t0, d2
    addi t4, x0, 1
d2: sw   t4, 4(a0)

    # 3: bge equal operands, taken -> 0
    addi t4, x0, 0
    bge  t0, t0, d3
    addi t4, x0, 99
    addi t4, x0, 98
d3: sw   t4, 8(a0)

    # 4: bltu, 1 < 0xFFFFFFFF taken -> 0
    addi t4, x0, 0
    bltu t0, t2, d4
    addi t4, x0, 99
    addi t4, x0, 98
d4: sw   t4, 12(a0)

    # 5: bltu, 0xFFFFFFFF < 1 false, not taken -> 1
    addi t4, x0, 0
    bltu t2, t0, d5
    addi t4, x0, 1
d5: sw   t4, 16(a0)

    # 6: bgeu, 0xFFFFFFFF >= 1 taken -> 0
    addi t4, x0, 0
    bgeu t2, t0, d6
    addi t4, x0, 99
    addi t4, x0, 98
d6: sw   t4, 20(a0)

    # 7: bgeu, 1 >= 0xFFFFFFFF false, not taken -> 1
    addi t4, x0, 0
    bgeu t0, t2, d7
    addi t4, x0, 1
d7: sw   t4, 24(a0)

    # 8: blt signed, -1 < 1 taken -> 0
    addi t4, x0, 0
    blt  t2, t0, d8
    addi t4, x0, 99
    addi t4, x0, 98
d8: sw   t4, 28(a0)

    ret

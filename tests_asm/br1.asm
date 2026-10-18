    addi a0, x0, 692
    addi t0, x0, 5
    addi t1, x0, 7
    addi t2, x0, -1

    # 1: beq taken -> flushed instrs must not run -> expect 0
    addi t4, x0, 0
    beq  t0, t0, c1
    addi t4, x0, 99
    addi t4, x0, 98
c1: sw   t4, 0(a0)

    # 2: beq not taken -> fall-through runs -> expect 1
    addi t4, x0, 0
    beq  t0, t1, c2
    addi t4, x0, 1
c2: sw   t4, 4(a0)

    # 3: bne taken -> expect 0
    addi t4, x0, 0
    bne  t0, t1, c3
    addi t4, x0, 99
    addi t4, x0, 98
c3: sw   t4, 8(a0)

    # 4: bne not taken -> expect 1
    addi t4, x0, 0
    bne  t0, t0, c4
    addi t4, x0, 1
c4: sw   t4, 12(a0)

    # 5: blt taken (5 < 7) -> expect 0
    addi t4, x0, 0
    blt  t0, t1, c5
    addi t4, x0, 99
    addi t4, x0, 98
c5: sw   t4, 16(a0)

    # 6: blt not taken (7 < 5 false) -> expect 1
    addi t4, x0, 0
    blt  t1, t0, c6
    addi t4, x0, 1
c6: sw   t4, 20(a0)

    # 7: blt signed taken (-1 < 0) -> expect 0
    addi t4, x0, 0
    blt  t2, x0, c7
    addi t4, x0, 99
    addi t4, x0, 98
c7: sw   t4, 24(a0)

    ret

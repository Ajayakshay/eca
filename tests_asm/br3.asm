    addi a0, x0, 692
    addi t0, x0, 1
    addi t2, x0, -1

    # 1: ble equal, taken -> 0
    addi t4, x0, 0
    ble  t0, t0, e1
    addi t4, x0, 99
    addi t4, x0, 98
e1: sw   t4, 0(a0)

    # 2: ble, 1 <= -1 false, not taken -> 1
    addi t4, x0, 0
    ble  t0, t2, e2
    addi t4, x0, 1
e2: sw   t4, 4(a0)

    # 3: ble, -1 <= 1 taken -> 0
    addi t4, x0, 0
    ble  t2, t0, e3
    addi t4, x0, 99
    addi t4, x0, 98
e3: sw   t4, 8(a0)

    # 4: bgt, 1 > -1 taken -> 0
    addi t4, x0, 0
    bgt  t0, t2, e4
    addi t4, x0, 99
    addi t4, x0, 98
e4: sw   t4, 12(a0)

    # 5: bgt, -1 > 1 false, not taken -> 1
    addi t4, x0, 0
    bgt  t2, t0, e5
    addi t4, x0, 1
e5: sw   t4, 16(a0)

    # 6: bgt equal, not taken -> 1
    addi t4, x0, 0
    bgt  t0, t0, e6
    addi t4, x0, 1
e6: sw   t4, 20(a0)

    ret

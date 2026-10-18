    addi t0, x0, 692
    addi t1, x0, 3
    addi t2, x0, 5
    sub  t3, t1, t2
    sw   t3, 0(t0)
    sub  t3, t2, t1
    sw   t3, 4(t0)
    lui  t4, 0x12345
    sw   t4, 8(t0)
    addi t4, t4, 0x678
    sw   t4, 12(t0)
    addi t5, x0, -4
    mul  t5, t5, t2
    sw   t5, 16(t0)
    slli t6, t2, 4
    sw   t6, 20(t0)
    ret
